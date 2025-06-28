-- Alerts table - geographical zones for notifications
CREATE TABLE IF NOT EXISTS alerts (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  location geometry(POINT, 4326) NOT NULL,
  radius_meters integer NOT NULL CHECK (radius_meters > 0 AND radius_meters <= 50000), -- Max 50km radius
  category text CHECK (category IN ('free-stuff', 'help-needed', 'skills-offered')),
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Notifications table - notices sent when listings match alerts
CREATE TABLE IF NOT EXISTS notifications (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  alert_id uuid REFERENCES alerts(id) ON DELETE CASCADE NOT NULL,
  listing_id uuid REFERENCES listings(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies for alerts
CREATE POLICY "Users can read own alerts" ON alerts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own alerts" ON alerts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own alerts" ON alerts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own alerts" ON alerts
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for notifications
CREATE POLICY "Users can read own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_alerts_user_id ON alerts(user_id);
CREATE INDEX IF NOT EXISTS idx_alerts_location_gist ON alerts USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_alerts_active ON alerts(active);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_alert_id ON notifications(alert_id);

-- Function to create notifications when new listings are posted
CREATE OR REPLACE FUNCTION create_listing_notifications()
RETURNS TRIGGER AS $$
DECLARE
  alert_record record;
BEGIN
  -- Only create notifications for active listings
  IF NEW.active = true THEN
    -- Find all active alerts that overlap with the new listing's location
    FOR alert_record IN
      SELECT a.id, a.user_id
      FROM alerts a
      WHERE a.active = true
        AND a.user_id != NEW.user_id -- Don't notify the listing creator
        AND (a.category IS NULL OR a.category = NEW.category)
        AND ST_DWithin(
          a.location::geography,
          NEW.location::geography,
          a.radius_meters
        )
    LOOP
      -- Insert notification
      INSERT INTO notifications (alert_id, listing_id, user_id)
      VALUES (alert_record.id, NEW.id, alert_record.user_id);
    END LOOP;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create notifications for new listings
CREATE TRIGGER trigger_create_listing_notifications
  AFTER INSERT ON listings
  FOR EACH ROW
  EXECUTE FUNCTION create_listing_notifications();

-- Function to mark notification as read
CREATE OR REPLACE FUNCTION mark_notification_as_read(p_notification_id uuid)
RETURNS void AS $$
DECLARE
  v_user_id uuid;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  UPDATE notifications 
  SET read = true 
  WHERE id = p_notification_id 
    AND user_id = v_user_id;
    
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Notification not found or access denied';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to mark all notifications as read for a user
CREATE OR REPLACE FUNCTION mark_all_notifications_as_read()
RETURNS void AS $$
DECLARE
  v_user_id uuid;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  UPDATE notifications 
  SET read = true 
  WHERE user_id = v_user_id 
    AND read = false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user notifications with listing details
CREATE OR REPLACE FUNCTION get_user_notifications(
  p_limit integer DEFAULT 20,
  p_offset integer DEFAULT 0,
  p_unread_only boolean DEFAULT false
)
RETURNS TABLE (
  id uuid,
  alert_id uuid,
  alert_name text,
  listing_id uuid,
  listing_title text,
  listing_category text,
  listing_location geometry(POINT, 4326),
  read boolean,
  created_at timestamptz
) AS $$
DECLARE
  v_user_id uuid;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  RETURN QUERY
  SELECT 
    n.id,
    n.alert_id,
    a.name as alert_name,
    n.listing_id,
    l.title as listing_title,
    l.category as listing_category,
    l.location as listing_location,
    n.read,
    n.created_at
  FROM notifications n
  JOIN alerts a ON a.id = n.alert_id
  JOIN listings l ON l.id = n.listing_id
  WHERE n.user_id = v_user_id
    AND (p_unread_only = false OR n.read = false)
    AND l.active = true -- Only show notifications for active listings
  ORDER BY n.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get unread notification count
CREATE OR REPLACE FUNCTION get_unread_notification_count()
RETURNS integer AS $$
DECLARE
  v_user_id uuid;
  v_count integer;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RETURN 0;
  END IF;
  
  SELECT COUNT(*)::integer INTO v_count
  FROM notifications n
  JOIN listings l ON l.id = n.listing_id
  WHERE n.user_id = v_user_id 
    AND n.read = false
    AND l.active = true;
    
  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable Realtime for notifications
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;