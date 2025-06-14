/*
  # Enhanced User Tracking for Requests

  1. Verify and enhance user tracking
    - Ensure user_id column exists with proper constraints
    - Add additional indexes for performance
    - Add user profile joins for better data retrieval
    - Ensure RLS policies are optimized

  2. Performance Optimizations
    - Add composite indexes for common query patterns
    - Optimize user-request relationship queries
    - Add indexes for filtering and sorting

  3. Data Integrity
    - Ensure all requests have valid user associations
    - Add constraints for data consistency
    - Verify foreign key relationships
*/

-- Verify user_id column exists (should already exist from initial migration)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'requests' AND column_name = 'user_id'
  ) THEN
    -- Add user_id column if it doesn't exist (fallback)
    ALTER TABLE requests ADD COLUMN user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL;
  END IF;
END $$;

-- Ensure foreign key constraint exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'requests_user_id_fkey' AND table_name = 'requests'
  ) THEN
    ALTER TABLE requests 
    ADD CONSTRAINT requests_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Add performance indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_requests_user_id ON requests(user_id);
CREATE INDEX IF NOT EXISTS idx_requests_user_status ON requests(user_id, status);
CREATE INDEX IF NOT EXISTS idx_requests_category_user ON requests(category, user_id);
CREATE INDEX IF NOT EXISTS idx_requests_created_user ON requests(created_at DESC, user_id);

-- Add composite index for common filtering patterns
CREATE INDEX IF NOT EXISTS idx_requests_status_category_created 
ON requests(status, category, created_at DESC) 
WHERE status = 'active';

-- Add index for location-based queries (if using PostGIS in future)
CREATE INDEX IF NOT EXISTS idx_requests_location_gin ON requests USING gin(location);

-- Ensure RLS policies are optimized for user tracking
-- Drop and recreate policies to ensure they're current

-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can read active requests" ON requests;
DROP POLICY IF EXISTS "Users can read own requests" ON requests;
DROP POLICY IF EXISTS "Users can create requests" ON requests;
DROP POLICY IF EXISTS "Users can update own requests" ON requests;
DROP POLICY IF EXISTS "Users can delete own requests" ON requests;

-- Recreate optimized policies
CREATE POLICY "Anyone can read active requests" ON requests
  FOR SELECT USING (status = 'active');

CREATE POLICY "Users can read own requests" ON requests
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create requests" ON requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own requests" ON requests
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own requests" ON requests
  FOR DELETE USING (auth.uid() = user_id);

-- Add function to get requests with user data (for better performance)
CREATE OR REPLACE FUNCTION get_requests_with_users(
  p_limit integer DEFAULT 50,
  p_offset integer DEFAULT 0,
  p_category text DEFAULT NULL,
  p_status text DEFAULT 'active'
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
  user_avatar_url text
) AS $$
BEGIN
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
    u.avatar_url as user_avatar_url
  FROM requests r
  JOIN users u ON r.user_id = u.id
  WHERE 
    (p_status IS NULL OR r.status = p_status)
    AND (p_category IS NULL OR r.category = p_category)
  ORDER BY r.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_requests_with_users TO authenticated;

-- Add function to get user's own requests
CREATE OR REPLACE FUNCTION get_user_requests(
  p_user_id uuid DEFAULT auth.uid(),
  p_limit integer DEFAULT 50,
  p_offset integer DEFAULT 0
)
RETURNS TABLE (
  id uuid,
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
  expires_at timestamptz
) AS $$
BEGIN
  -- Ensure user can only access their own requests
  IF p_user_id != auth.uid() THEN
    RAISE EXCEPTION 'Access denied: Can only access own requests';
  END IF;

  RETURN QUERY
  SELECT 
    r.id,
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
    r.expires_at
  FROM requests r
  WHERE r.user_id = p_user_id
  ORDER BY r.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_requests TO authenticated;

-- Add trigger to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger if it doesn't exist
DROP TRIGGER IF EXISTS update_requests_updated_at ON requests;
CREATE TRIGGER update_requests_updated_at
  BEFORE UPDATE ON requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add comments for documentation
COMMENT ON INDEX idx_requests_user_id IS 'Index for user-specific request queries';
COMMENT ON INDEX idx_requests_user_status IS 'Composite index for user requests by status';
COMMENT ON INDEX idx_requests_category_user IS 'Index for category filtering by user';
COMMENT ON INDEX idx_requests_created_user IS 'Index for chronological user request ordering';
COMMENT ON FUNCTION get_requests_with_users IS 'Optimized function to fetch requests with user data';
COMMENT ON FUNCTION get_user_requests IS 'Secure function to fetch user-specific requests';