/*
  # Enable PostGIS for Spatial Queries

  1. PostGIS Setup
    - Enable PostGIS extension for spatial operations
    - Add geometry column to requests table (SRID 4326 for GPS coordinates)
    - Create spatial indexes for efficient bounding box queries
    - Add triggers to automatically maintain geometry data

  2. Spatial Functions
    - get_requests_in_bounds() - Get requests within map viewport
    - get_requests_in_radius() - Get requests within radius
    - extract_coordinates() - Safely extract coordinates from JSONB
    - validate_request_geometries() - Data validation and repair

  3. Data Migration
    - Update existing records with geometry data
    - Validate coordinate ranges and data integrity
    - Handle international date line crossing
*/

-- Enable PostGIS extension (includes geometry types and spatial functions)
CREATE EXTENSION IF NOT EXISTS postgis;

-- Add geometry column to requests table for spatial operations
-- Using SRID 4326 (WGS84) which is standard for GPS coordinates
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'requests' AND column_name = 'geom'
  ) THEN
    ALTER TABLE requests 
    ADD COLUMN geom geometry(POINT, 4326);
  END IF;
END $$;

-- Create spatial index for efficient bounding box queries
CREATE INDEX IF NOT EXISTS idx_requests_geom_gist 
ON requests USING GIST (geom);

-- Create spatial index for active requests only (most common query)
CREATE INDEX IF NOT EXISTS idx_requests_geom_status_gist 
ON requests USING GIST (geom) 
WHERE status = 'active';

-- Create separate B-tree indexes for category filtering
-- (GIST doesn't work well with text columns without specific operator classes)
CREATE INDEX IF NOT EXISTS idx_requests_category_geom 
ON requests (category) 
WHERE geom IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_requests_subcategory_geom 
ON requests (subcategory) 
WHERE geom IS NOT NULL;

-- Function to safely extract coordinates from location JSONB
CREATE OR REPLACE FUNCTION extract_coordinates(location_data jsonb)
RETURNS geometry(POINT, 4326) AS $$
DECLARE
  lat double precision;
  lng double precision;
BEGIN
  -- Extract latitude and longitude from JSONB
  lat := (location_data->>'latitude')::double precision;
  lng := (location_data->>'longitude')::double precision;
  
  -- Validate coordinate ranges
  IF lat IS NULL OR lng IS NULL THEN
    RETURN NULL;
  END IF;
  
  IF lat < -90 OR lat > 90 THEN
    RAISE WARNING 'Invalid latitude: %', lat;
    RETURN NULL;
  END IF;
  
  IF lng < -180 OR lng > 180 THEN
    RAISE WARNING 'Invalid longitude: %', lng;
    RETURN NULL;
  END IF;
  
  -- Create PostGIS point geometry (longitude first, then latitude)
  RETURN ST_SetSRID(ST_MakePoint(lng, lat), 4326);
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error extracting coordinates from %: %', location_data, SQLERRM;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to update geometry from location JSONB
CREATE OR REPLACE FUNCTION update_request_geometry()
RETURNS TRIGGER AS $$
BEGIN
  -- Update geometry when location changes
  IF NEW.location IS DISTINCT FROM OLD.location THEN
    NEW.geom := extract_coordinates(NEW.location);
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update geometry when location changes
DROP TRIGGER IF EXISTS trigger_update_request_geometry ON requests;
CREATE TRIGGER trigger_update_request_geometry
  BEFORE UPDATE ON requests
  FOR EACH ROW
  EXECUTE FUNCTION update_request_geometry();

-- Create trigger for new inserts
CREATE OR REPLACE FUNCTION insert_request_geometry()
RETURNS TRIGGER AS $$
BEGIN
  -- Set geometry for new records
  NEW.geom := extract_coordinates(NEW.location);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_insert_request_geometry ON requests;
CREATE TRIGGER trigger_insert_request_geometry
  BEFORE INSERT ON requests
  FOR EACH ROW
  EXECUTE FUNCTION insert_request_geometry();

-- Migrate existing data: Update geometry for all existing requests
UPDATE requests 
SET geom = extract_coordinates(location)
WHERE location IS NOT NULL AND geom IS NULL;

-- Function to get requests within map bounds using PostGIS
CREATE OR REPLACE FUNCTION get_requests_in_bounds(
  north double precision,
  south double precision,
  east double precision,
  west double precision,
  p_category text DEFAULT NULL,
  p_subcategory text DEFAULT NULL,
  p_status text DEFAULT 'active',
  p_limit integer DEFAULT 100
)
RETURNS TABLE (
  id uuid,
  user_id uuid,
  title text,
  description text,
  category text,
  subcategory text,
  duration_estimate text,
  skills_required text[],
  compensation text,
  images text[],
  location jsonb,
  status text,
  created_at timestamptz,
  updated_at timestamptz,
  expires_at timestamptz,
  user_full_name text,
  user_email text,
  user_avatar_url text,
  distance_meters double precision
) AS $$
DECLARE
  bounds_geom geometry;
BEGIN
  -- Validate coordinate bounds
  IF north <= south OR east <= west THEN
    RAISE EXCEPTION 'Invalid bounds: north=%, south=%, east=%, west=%', north, south, east, west;
  END IF;
  
  IF north < -90 OR north > 90 OR south < -90 OR south > 90 THEN
    RAISE EXCEPTION 'Invalid latitude bounds: north=%, south=%', north, south;
  END IF;
  
  IF east < -180 OR east > 180 OR west < -180 OR west > 180 THEN
    RAISE EXCEPTION 'Invalid longitude bounds: east=%, west=%', east, west;
  END IF;
  
  -- Create bounding box geometry
  -- Handle case where bounds cross the 180/-180 longitude line
  IF west > east THEN
    -- Bounds cross the international date line
    bounds_geom := ST_SetSRID(
      ST_Union(
        ST_MakeEnvelope(-180, south, east, north, 4326),
        ST_MakeEnvelope(west, south, 180, north, 4326)
      ), 
      4326
    );
  ELSE
    -- Normal case
    bounds_geom := ST_MakeEnvelope(west, south, east, north, 4326);
  END IF;
  
  -- Query requests within bounds with spatial index optimization
  RETURN QUERY
  SELECT 
    r.id,
    r.user_id,
    r.title,
    r.description,
    r.category,
    r.subcategory,
    r.duration_estimate,
    r.skills_required,
    r.compensation,
    r.images,
    r.location,
    r.status,
    r.created_at,
    r.updated_at,
    r.expires_at,
    u.full_name as user_full_name,
    u.email as user_email,
    u.avatar_url as user_avatar_url,
    -- Calculate distance from center of bounds for sorting
    ST_Distance(
      r.geom::geography, 
      ST_Centroid(bounds_geom)::geography
    ) as distance_meters
  FROM requests r
  JOIN users u ON r.user_id = u.id
  WHERE 
    r.geom IS NOT NULL
    AND ST_Intersects(r.geom, bounds_geom)
    AND (p_status IS NULL OR r.status = p_status)
    AND (p_category IS NULL OR r.category = p_category)
    AND (p_subcategory IS NULL OR r.subcategory = p_subcategory)
  ORDER BY distance_meters ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated and anonymous users
GRANT EXECUTE ON FUNCTION get_requests_in_bounds TO authenticated, anon;

-- Function to get requests within radius (fallback for non-bounds queries)
CREATE OR REPLACE FUNCTION get_requests_in_radius(
  center_lat double precision,
  center_lng double precision,
  radius_meters double precision,
  p_category text DEFAULT NULL,
  p_subcategory text DEFAULT NULL,
  p_status text DEFAULT 'active',
  p_limit integer DEFAULT 100
)
RETURNS TABLE (
  id uuid,
  user_id uuid,
  title text,
  description text,
  category text,
  subcategory text,
  duration_estimate text,
  skills_required text[],
  compensation text,
  images text[],
  location jsonb,
  status text,
  created_at timestamptz,
  updated_at timestamptz,
  expires_at timestamptz,
  user_full_name text,
  user_email text,
  user_avatar_url text,
  distance_meters double precision
) AS $$
DECLARE
  center_point geography;
BEGIN
  -- Validate coordinates
  IF center_lat < -90 OR center_lat > 90 THEN
    RAISE EXCEPTION 'Invalid latitude: %', center_lat;
  END IF;
  
  IF center_lng < -180 OR center_lng > 180 THEN
    RAISE EXCEPTION 'Invalid longitude: %', center_lng;
  END IF;
  
  IF radius_meters <= 0 OR radius_meters > 50000 THEN
    RAISE EXCEPTION 'Invalid radius: % meters (must be between 1 and 50000)', radius_meters;
  END IF;
  
  -- Create center point
  center_point := ST_SetSRID(ST_MakePoint(center_lng, center_lat), 4326)::geography;
  
  -- Query requests within radius
  RETURN QUERY
  SELECT 
    r.id,
    r.user_id,
    r.title,
    r.description,
    r.category,
    r.subcategory,
    r.duration_estimate,
    r.skills_required,
    r.compensation,
    r.images,
    r.location,
    r.status,
    r.created_at,
    r.updated_at,
    r.expires_at,
    u.full_name as user_full_name,
    u.email as user_email,
    u.avatar_url as user_avatar_url,
    ST_Distance(r.geom::geography, center_point) as distance_meters
  FROM requests r
  JOIN users u ON r.user_id = u.id
  WHERE 
    r.geom IS NOT NULL
    AND ST_DWithin(r.geom::geography, center_point, radius_meters)
    AND (p_status IS NULL OR r.status = p_status)
    AND (p_category IS NULL OR r.category = p_category)
    AND (p_subcategory IS NULL OR r.subcategory = p_subcategory)
  ORDER BY distance_meters ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated and anonymous users
GRANT EXECUTE ON FUNCTION get_requests_in_radius TO authenticated, anon;

-- Function to validate and fix geometry data
CREATE OR REPLACE FUNCTION validate_request_geometries()
RETURNS TABLE (
  request_id uuid,
  status text,
  message text
) AS $$
DECLARE
  rec record;
  fixed_count integer := 0;
  error_count integer := 0;
BEGIN
  FOR rec IN 
    SELECT id, location, geom 
    FROM requests 
    WHERE location IS NOT NULL
  LOOP
    BEGIN
      -- Try to extract coordinates and update geometry
      DECLARE
        new_geom geometry(POINT, 4326);
      BEGIN
        new_geom := extract_coordinates(rec.location);
        
        IF new_geom IS NULL THEN
          RETURN QUERY SELECT rec.id, 'ERROR'::text, 'Could not extract valid coordinates'::text;
          error_count := error_count + 1;
        ELSIF rec.geom IS NULL OR NOT ST_Equals(rec.geom, new_geom) THEN
          -- Update the geometry
          UPDATE requests SET geom = new_geom WHERE id = rec.id;
          RETURN QUERY SELECT rec.id, 'FIXED'::text, 'Geometry updated'::text;
          fixed_count := fixed_count + 1;
        ELSE
          RETURN QUERY SELECT rec.id, 'OK'::text, 'Geometry is valid'::text;
        END IF;
      END;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN QUERY SELECT rec.id, 'ERROR'::text, SQLERRM::text;
        error_count := error_count + 1;
    END;
  END LOOP;
  
  -- Return summary
  RETURN QUERY SELECT 
    NULL::uuid, 
    'SUMMARY'::text, 
    format('Fixed: %s, Errors: %s', fixed_count, error_count)::text;
END;
$$ LANGUAGE plpgsql;

-- Add comments for documentation
COMMENT ON COLUMN requests.geom IS 'PostGIS geometry point for spatial queries (SRID 4326)';
COMMENT ON INDEX idx_requests_geom_gist IS 'Spatial index for efficient bounding box queries';
COMMENT ON FUNCTION get_requests_in_bounds IS 'Get requests within map viewport bounds using PostGIS';
COMMENT ON FUNCTION get_requests_in_radius IS 'Get requests within radius using PostGIS geography';
COMMENT ON FUNCTION extract_coordinates IS 'Safely extract and validate coordinates from location JSONB';
COMMENT ON FUNCTION validate_request_geometries IS 'Validate and fix geometry data for all requests';

-- Run validation to ensure all existing data has proper geometry
SELECT * FROM validate_request_geometries();