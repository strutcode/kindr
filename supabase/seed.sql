-- Users data
SELECT create_seed_user('Testy McTestFace', 'test@test.com');

-- Listings data
SELECT create_seed_listing(
  random_user_id(),
  'Need help moving some furniture this weekend',
  'I have a couch, a bed, and some boxes that need to be moved from my apartment to a storage unit. I can provide pizza and drinks for anyone who helps out!',
  ST_MakePoint(-118.2437, 34.0522),
  'help-needed',
  'moving',
  '1-day',
  '{"truck", "heavy lifting"}',
  'pizza and drinks'
);

-- Chats data
INSERT INTO
  public.chats (
    id,
    listing_id,
    requester_id,
    listing_owner_id,
    last_message_at,
    requester_unread_count,
    owner_unread_count,
    created_at,
    updated_at
  )
VALUES
  (
    uuid_generate_v4(),
    (SELECT id FROM listings LIMIT 1),
    (SELECT id FROM auth.users LIMIT 1),
    (SELECT id FROM auth.users LIMIT 1),
    now(),
    0,
    1,
    now(),
    now()
  );

INSERT INTO
  public.chat_messages (
    id,
    chat_id,
    sender_id,
    message_type,
    content,
    image_url,
    created_at
  )
VALUES
  (
    uuid_generate_v4(),
    (SELECT id FROM public.chats LIMIT 1),
    (SELECT id FROM auth.users LIMIT 1),
    'text',
    'Hello',
    NULL,
    now()
  );
