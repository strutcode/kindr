-- Chats table - represents a conversation between users about a specific listing
CREATE TABLE IF NOT EXISTS chats (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  listing_id uuid REFERENCES listings(id) ON DELETE CASCADE NOT NULL,
  requester_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  listing_owner_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  last_message_at timestamptz DEFAULT now(),
  requester_unread_count integer DEFAULT 0,
  owner_unread_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(listing_id, requester_id) -- Only one chat per listing per requester
);

-- Chat messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  chat_id uuid REFERENCES chats(id) ON DELETE CASCADE NOT NULL,
  sender_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  message_type text NOT NULL DEFAULT 'text' CHECK (message_type IN ('text', 'image')),
  content text, -- For text messages
  image_url text, -- For image messages
  created_at timestamptz DEFAULT now(),
  CONSTRAINT message_content_check CHECK (
    (message_type = 'text' AND content IS NOT NULL AND image_url IS NULL) OR
    (message_type = 'image' AND image_url IS NOT NULL)
  )
);

-- Enable Row Level Security
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies for chats
CREATE POLICY "Users can read chats they participate in" ON chats
  FOR SELECT USING (
    auth.uid() = requester_id OR 
    auth.uid() = listing_owner_id
  );

CREATE POLICY "Users can create chats for listings" ON chats
  FOR INSERT WITH CHECK (
    auth.uid() = requester_id AND 
    auth.uid() != listing_owner_id AND
    EXISTS (SELECT 1 FROM listings WHERE id = listing_id AND active = true)
  );

CREATE POLICY "Users can update chats they participate in" ON chats
  FOR UPDATE USING (
    auth.uid() = requester_id OR 
    auth.uid() = listing_owner_id
  );

-- RLS Policies for chat_messages
CREATE POLICY "Users can read messages from their chats" ON chat_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chats 
      WHERE chats.id = chat_messages.chat_id 
      AND (chats.requester_id = auth.uid() OR chats.listing_owner_id = auth.uid())
    )
  );

CREATE POLICY "Users can insert messages to their chats" ON chat_messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM chats 
      WHERE chats.id = chat_messages.chat_id 
      AND (chats.requester_id = auth.uid() OR chats.listing_owner_id = auth.uid())
    )
  );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_chats_listing_id ON chats(listing_id);
CREATE INDEX IF NOT EXISTS idx_chats_requester_id ON chats(requester_id);
CREATE INDEX IF NOT EXISTS idx_chats_listing_owner_id ON chats(listing_owner_id);
CREATE INDEX IF NOT EXISTS idx_chats_last_message_at ON chats(last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_chat_id ON chat_messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_chat_id_created_at ON chat_messages(chat_id, created_at DESC);

-- Create the chat-images bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'chat-images',
  'chat-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload chat images
CREATE POLICY "Authenticated users can upload chat images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'chat-images');

-- Allow users to update their own chat images
CREATE POLICY "Users can update own chat images" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'chat-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to delete their own chat images
CREATE POLICY "Users can delete own chat images" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'chat-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow participants to view chat images
CREATE POLICY "Chat participants can view chat images" ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'chat-images' AND
    EXISTS (
      SELECT 1 FROM chat_messages cm
      JOIN chats c ON c.id = cm.chat_id
      WHERE cm.image_url LIKE '%' || storage.objects.name || '%'
      AND (c.requester_id = auth.uid() OR c.listing_owner_id = auth.uid())
    )
  );

-- Enable Realtime for chat functionality
ALTER PUBLICATION supabase_realtime ADD TABLE chats;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;

-- Function to send a chat message with security and validation
CREATE OR REPLACE FUNCTION send_chat_message(
  p_chat_id uuid,
  p_message_type text,
  p_content text DEFAULT NULL,
  p_image_url text DEFAULT NULL
)
RETURNS uuid AS $$
DECLARE
  v_message_id uuid;
  v_sender_id uuid;
  v_chat_record record;
  v_other_user_id uuid;
BEGIN
  -- Get current user ID
  v_sender_id := auth.uid();
  
  IF v_sender_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  -- Validate message type
  IF p_message_type NOT IN ('text', 'image') THEN
    RAISE EXCEPTION 'Invalid message type';
  END IF;
  
  -- Validate content based on type
  IF p_message_type = 'text' THEN
    IF p_content IS NULL OR LENGTH(TRIM(p_content)) = 0 THEN
      RAISE EXCEPTION 'Text message content cannot be empty';
    END IF;
    
    IF LENGTH(p_content) > 2000 THEN
      RAISE EXCEPTION 'Message too long (max 2000 characters)';
    END IF;
    
    p_image_url := NULL; -- Ensure no image URL for text messages
  ELSIF p_message_type = 'image' THEN
    IF p_image_url IS NULL OR LENGTH(TRIM(p_image_url)) = 0 THEN
      RAISE EXCEPTION 'Image message must have image URL';
    END IF;
    
    -- Basic URL validation
    IF p_image_url NOT LIKE 'http%' THEN
      RAISE EXCEPTION 'Invalid image URL format';
    END IF;
  END IF;
  
  -- Get chat details and verify user permission
  SELECT * INTO v_chat_record 
  FROM chats 
  WHERE id = p_chat_id 
  AND (requester_id = v_sender_id OR listing_owner_id = v_sender_id);
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Chat not found or access denied';
  END IF;
  
  -- Determine the other user for unread count
  IF v_chat_record.requester_id = v_sender_id THEN
    v_other_user_id := v_chat_record.listing_owner_id;
  ELSE
    v_other_user_id := v_chat_record.requester_id;
  END IF;
  
  -- Insert the message
  INSERT INTO chat_messages (chat_id, sender_id, message_type, content, image_url)
  VALUES (p_chat_id, v_sender_id, p_message_type, p_content, p_image_url)
  RETURNING id INTO v_message_id;
  
  -- Update chat last_message_at and increment unread count for the other user
  IF v_other_user_id = v_chat_record.requester_id THEN
    UPDATE chats 
    SET 
      last_message_at = now(),
      requester_unread_count = requester_unread_count + 1,
      updated_at = now()
    WHERE id = p_chat_id;
  ELSE
    UPDATE chats 
    SET 
      last_message_at = now(),
      owner_unread_count = owner_unread_count + 1,
      updated_at = now()
    WHERE id = p_chat_id;
  END IF;
  
  RETURN v_message_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to mark messages as read
CREATE OR REPLACE FUNCTION mark_chat_as_read(p_chat_id uuid)
RETURNS void AS $$
DECLARE
  v_user_id uuid;
  v_chat_record record;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  -- Get chat details and verify user permission
  SELECT * INTO v_chat_record 
  FROM chats 
  WHERE id = p_chat_id 
  AND (requester_id = v_user_id OR listing_owner_id = v_user_id);
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Chat not found or access denied';
  END IF;
  
  -- Reset unread count for the current user
  IF v_chat_record.requester_id = v_user_id THEN
    UPDATE chats 
    SET requester_unread_count = 0, updated_at = now()
    WHERE id = p_chat_id;
  ELSE
    UPDATE chats 
    SET owner_unread_count = 0, updated_at = now()
    WHERE id = p_chat_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get or create a chat
CREATE OR REPLACE FUNCTION get_or_create_chat(p_listing_id uuid)
RETURNS uuid AS $$
DECLARE
  v_chat_id uuid;
  v_user_id uuid;
  v_listing_owner_id uuid;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  -- Get listing owner
  SELECT user_id INTO v_listing_owner_id 
  FROM listings 
  WHERE id = p_listing_id AND active = true;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Listing not found or inactive';
  END IF;
  
  -- Can't chat with yourself
  IF v_user_id = v_listing_owner_id THEN
    RAISE EXCEPTION 'Cannot create chat with yourself';
  END IF;
  
  -- Try to find existing chat
  SELECT id INTO v_chat_id 
  FROM chats 
  WHERE listing_id = p_listing_id 
  AND requester_id = v_user_id;
  
  -- Create chat if it doesn't exist
  IF NOT FOUND THEN
    INSERT INTO chats (listing_id, requester_id, listing_owner_id)
    VALUES (p_listing_id, v_user_id, v_listing_owner_id)
    RETURNING id INTO v_chat_id;
  END IF;
  
  RETURN v_chat_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get chat messages with pagination
CREATE OR REPLACE FUNCTION get_chat_messages(
  p_chat_id uuid,
  p_limit integer DEFAULT 15,
  p_before_id uuid DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  chat_id uuid,
  sender_id uuid,
  sender_name text,
  sender_avatar_url text,
  message_type text,
  content text,
  image_url text,
  created_at timestamptz
) AS $$
DECLARE
  v_user_id uuid;
BEGIN
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  
  -- Verify user has access to this chat
  IF NOT EXISTS (
    SELECT 1 FROM chats 
    WHERE chats.id = p_chat_id 
    AND (chats.requester_id = v_user_id OR chats.listing_owner_id = v_user_id)
  ) THEN
    RAISE EXCEPTION 'Chat not found or access denied';
  END IF;
  
  -- Return messages with user info
  RETURN QUERY
  SELECT 
    cm.id,
    cm.chat_id,
    cm.sender_id,
    COALESCE(u.full_name, 'Anonymous') as sender_name,
    u.avatar_url as sender_avatar_url,
    cm.message_type,
    cm.content,
    cm.image_url,
    cm.created_at
  FROM chat_messages cm
  JOIN users u ON u.id = cm.sender_id
  WHERE cm.chat_id = p_chat_id
  AND (p_before_id IS NULL OR cm.created_at < (SELECT created_at FROM chat_messages WHERE id = p_before_id))
  ORDER BY cm.created_at DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update chat updated_at when messages are inserted
CREATE OR REPLACE FUNCTION update_chat_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE chats 
  SET updated_at = now() 
  WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_chat_timestamp
  AFTER INSERT ON chat_messages
  FOR EACH ROW
  EXECUTE FUNCTION update_chat_timestamp();