-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id uuid REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name text,
  avatar_url text,
  location geometry(POINT, 4326),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Listings table
CREATE TABLE IF NOT EXISTS listings (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  category text NOT NULL CHECK (
    category IN (
      'free-stuff',
      'help-needed',
      'skills-offered'
    )
  ),
  subcategory text NOT NULL,
  duration_estimate text CHECK (
    duration_estimate IN (
      '15-min',
      '30-min',
      '45-min',
      '1-hour',
      '2-hours',
      '4-hours',
      '6-hours',
      '12-hours',
      '1-day',
      'multiple-days'
    )
  ),
  skills_required text[] DEFAULT '{}',
  compensation text,
  images text[] DEFAULT '{}',
  location geometry(POINT, 4326) NOT NULL,
  active boolean DEFAULT true,
  expiry_seconds integer DEFAULT 604800 CHECK (expiry_seconds IN (3600, 43200, 86400, 259200, 432000, 604800)), -- 1 hour, 12 hours, 1 day, 3 days, 5 days, 7 days
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  expires_at timestamptz
);

-- Reputation table
CREATE TABLE IF NOT EXISTS reputation (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  positive_points integer DEFAULT 0,
  negative_points integer DEFAULT 0,
  total_interactions integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  listing_id uuid REFERENCES listings(id) ON DELETE CASCADE NOT NULL,
  reviewer_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  reviewee_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  punctuality text NOT NULL CHECK (punctuality IN ('no-show', 'late', 'on-time')),
  helpfulness text NOT NULL CHECK (helpfulness IN ('helpful', 'unhelpful')),
  accuracy text NOT NULL CHECK (accuracy IN ('as-described', 'not-as-described')),
  additional_feedback text,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reputation ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "Users can read own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for listings
CREATE POLICY "Anyone can read active listings" ON listings
  FOR SELECT USING (active = true);

CREATE POLICY "Users can read own listings" ON listings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create listings" ON listings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own listings" ON listings
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own listings" ON listings
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for reputation
CREATE POLICY "Anyone can read reputation" ON reputation
  FOR SELECT USING (true);

CREATE POLICY "System can insert reputation" ON reputation
  FOR INSERT WITH CHECK (true);

CREATE POLICY "System can update reputation" ON reputation
  FOR UPDATE USING (true);

-- RLS Policies for reviews
CREATE POLICY "Users can read reviews about them" ON reviews
  FOR SELECT USING (auth.uid() = reviewee_id OR auth.uid() = reviewer_id);

CREATE POLICY "Users can create reviews" ON reviews
  FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- Function to update reputation
CREATE OR REPLACE FUNCTION update_reputation(
  user_id uuid,
  positive_delta integer,
  negative_delta integer
)
RETURNS void AS $$
BEGIN
  INSERT INTO reputation (user_id, positive_points, negative_points, total_interactions)
  VALUES (user_id, positive_delta, negative_delta, 1)
  ON CONFLICT (user_id) DO UPDATE SET
    positive_points = reputation.positive_points + positive_delta,
    negative_points = reputation.negative_points + negative_delta,
    total_interactions = reputation.total_interactions + 1,
    updated_at = now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_listings_category ON listings(category);
CREATE INDEX IF NOT EXISTS idx_listings_active ON listings(active);
CREATE INDEX IF NOT EXISTS idx_listings_created_at ON listings(created_at);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewee_id ON reviews(reviewee_id);

-- Create the listing-images bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'listing-images',
  'listing-images',
  true,
  2097152, -- 2MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
);

-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'listing-images');

-- Allow authenticated users to update their own images
CREATE POLICY "Users can update own images" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'listing-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow authenticated users to delete their own images
CREATE POLICY "Users can delete own images" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'listing-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow public read access to images
CREATE POLICY "Public can view images" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'listing-images');

-- Function to clean up images not associated with a listing
CREATE OR REPLACE FUNCTION cleanup_orphaned_images()
RETURNS void AS $$
BEGIN
  DELETE FROM storage.objects
  WHERE bucket_id = 'listing-images'
    AND NOT EXISTS (
      SELECT 1 FROM listings
      WHERE listings.images @> ARRAY[storage.objects.name]
    );
END;
$$ LANGUAGE plpgsql;

-- Function to mark expired listings as inactive
CREATE OR REPLACE FUNCTION mark_expired_listings_inactive()
RETURNS void AS $$
BEGIN
  UPDATE listings
  SET active = false
  WHERE active = true
    AND expiry_seconds IS NOT NULL
    AND (EXTRACT(EPOCH FROM (now() - created_at)) > expiry_seconds);
END;
$$ LANGUAGE plpgsql;

-- Create spatial index for active listings only (most common query)
CREATE INDEX IF NOT EXISTS idx_listings_location_active_gist 
ON listings USING GIST (location) 
WHERE active = true;

-- Function to get listings within map bounds using PostGIS
CREATE OR REPLACE FUNCTION get_listings_in_bounds(
  north double precision,
  south double precision,
  east double precision,
  west double precision,
  p_search text DEFAULT NULL,
  p_category text DEFAULT NULL,
  p_subcategory text DEFAULT NULL,
  p_active boolean DEFAULT true,
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
  location geometry(POINT, 4326),
  active boolean,
  created_at timestamptz,
  updated_at timestamptz,
  expires_at timestamptz,
  user_full_name text,
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
  
  -- Query listings within bounds with spatial index optimization
  RETURN QUERY
  SELECT 
    l.id,
    l.user_id,
    l.title,
    l.description,
    l.category,
    l.subcategory,
    l.duration_estimate,
    l.skills_required,
    l.compensation,
    l.images,
    l.location,
    l.active,
    l.created_at,
    l.updated_at,
    l.expires_at,
    u.full_name as user_full_name,
    u.avatar_url as user_avatar_url,
    -- Calculate distance from center of bounds for sorting
    ST_Distance(
      l.location::geography,
      ST_Centroid(bounds_geom)::geography
    ) as distance_meters
  FROM listings l
  JOIN users u ON l.user_id = u.id
  WHERE 
    l.location IS NOT NULL
    AND ST_Intersects(l.location::geography, bounds_geom::geography)
    AND (p_search IS NULL OR (to_tsvector(l.title || ' ' || l.description || ' ' || l.category || ' ' || l.subcategory || coalesce(array_to_string(l.skills_required, ' '), '')) @@ to_tsquery(p_search)))
    AND (p_active IS NULL OR l.active = p_active)
    AND (p_category IS NULL OR l.category = p_category)
    AND (p_subcategory IS NULL OR l.subcategory = p_subcategory)
  ORDER BY distance_meters ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;