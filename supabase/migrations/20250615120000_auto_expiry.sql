-- Add expiry_seconds and is_active columns to requests table for auto-expiry
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'requests' AND column_name = 'expiry_seconds'
  ) THEN
    ALTER TABLE requests ADD COLUMN expiry_seconds integer;
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'requests' AND column_name = 'is_active'
  ) THEN
    ALTER TABLE requests ADD COLUMN is_active boolean NOT NULL DEFAULT true;
  END IF;
END $$;

-- Index for efficient lookup of active/expired requests
CREATE INDEX IF NOT EXISTS idx_requests_is_active ON requests(is_active);

-- (Optional) Backfill: Mark all existing requests as active if not already set
UPDATE requests SET is_active = true WHERE is_active IS NULL;

-- Function to mark expired requests as inactive
CREATE OR REPLACE FUNCTION mark_expired_requests_inactive()
RETURNS void AS $$
BEGIN
  UPDATE requests
  SET is_active = false
  WHERE is_active = true
    AND expiry_seconds IS NOT NULL
    AND (EXTRACT(EPOCH FROM (now() - created_at)) > expiry_seconds);
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission to Edge Functions
GRANT EXECUTE ON FUNCTION mark_expired_requests_inactive TO authenticated, anon;
