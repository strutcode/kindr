INSERT INTO
  auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at,
    is_sso_user,
    deleted_at,
    is_anonymous
  )
VALUES
  (
    '00000000-0000-0000-0000-000000000000',
    'cc4210ac-08ed-45cf-8f45-5548b15c9607',
    'authenticated',
    'authenticated',
    'test@test.com',
    '$2a$10$dBukFqbp/A.iPs9pg0tH5efOCgO4rthD0mwl421cS/kzj7j0HRCmW',
    '2025-06-24 17:57:24.284756+00',
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    '2025-06-23 00:40:19.464921+00',
    '{"provider": "email", "providers": ["email"]}',
    '{"sub": "cc4210ac-08ed-45cf-8f45-5548b15c9607", "email": "test@test.com", "full_name": "Testy McTestFace", "email_verified": true, "phone_verified": false}',
    NULL,
    '2025-06-23 00:40:19.459554+00',
    '2025-06-23 18:42:18.413897+00',
    NULL,
    NULL,
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL,
    false,
    NULL,
    false
  );

INSERT INTO
  auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at,
    id
  )
VALUES
  (
    'cc4210ac-08ed-45cf-8f45-5548b15c9607',
    'cc4210ac-08ed-45cf-8f45-5548b15c9607',
    '{"sub": "cc4210ac-08ed-45cf-8f45-5548b15c9607", "email": "test@test.com", "full_name": "Testy McTestFace", "email_verified": false, "phone_verified": false}',
    'email',
    '2025-06-23 00:40:19.461346+00',
    '2025-06-23 00:40:19.461364+00',
    '2025-06-23 00:40:19.461364+00',
    'b79d9e95-39a8-48ac-9519-107f340a0770'
  );
  
INSERT INTO
  auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at,
    is_sso_user,
    deleted_at,
    is_anonymous
  )
VALUES
  (
    '00000000-0000-0000-0000-000000000000',
    '3e1f7332-507d-4dc9-827c-eb54c3d4187b',
    'authenticated',
    'authenticated',
    'test2@test.com',
    '$2a$10$dBukFqbp/A.iPs9pg0tH5efOCgO4rthD0mwl421cS/kzj7j0HRCmW',
    '2025-06-24 17:57:24.284756+00',
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    '2025-06-24 17:57:24.284756+00',
    '{"provider": "email", "providers": ["email"]}',
    '{"sub": "3e1f7332-507d-4dc9-827c-eb54c3d4187b", "email": "test2@test.com", "full_name": "Tester Toaster", "email_verified": true, "phone_verified": false}',
    NULL,
    '2025-06-24 17:57:24.284756+00',
    '2025-06-24 17:57:24.284756+00',
    NULL,
    NULL,
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL,
    false,
    NULL,
    false
  );

INSERT INTO
  auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at,
    id
  )
VALUES
  (
    '3e1f7332-507d-4dc9-827c-eb54c3d4187b',
    '3e1f7332-507d-4dc9-827c-eb54c3d4187b',
    '{"sub": "3e1f7332-507d-4dc9-827c-eb54c3d4187b", "email": "test2@test.com", "full_name": "Tester Toaster", "email_verified": false, "phone_verified": false}',
    'email',
    '2025-06-24 17:57:24.284756+00',
    '2025-06-24 17:57:24.284756+00',
    '2025-06-24 17:57:24.284756+00',
    uuid_generate_v4()
  );

INSERT INTO
  public.users (
    id,
    full_name,
    avatar_url,
    location,
    created_at,
    updated_at
  )
VALUES
  (
    'cc4210ac-08ed-45cf-8f45-5548b15c9607',
    'Testy McTestFace',
    NULL,
    NULL,
    '2025-06-23 00:40:19.567424+00',
    '2025-06-23 00:40:19.567424+00'
  );

INSERT INTO
  public.users (
    id,
    full_name,
    avatar_url,
    location,
    created_at,
    updated_at
  )
VALUES
  (
    '3e1f7332-507d-4dc9-827c-eb54c3d4187b',
    'Tester Toaster',
    NULL,
    NULL,
    '2025-06-24 17:57:24.284756+00',
    '2025-06-24 17:57:24.284756+00'
  );

INSERT INTO
  public.listings (
    id,
    user_id,
    title,
    description,
    category,
    subcategory,
    duration_estimate,
    skills_required,
    compensation,
    images,
    location,
    active,
    expiry_seconds,
    created_at,
    updated_at,
    expires_at
  )
VALUES
  (
    '4f95670a-ec9e-4703-9fac-ba2832d20f44',
    'cc4210ac-08ed-45cf-8f45-5548b15c9607',
    'Moving help needed',
    'I need help moving some furniture this weekend. If you have a truck and can spare a few hours, I would greatly appreciate it!',
    'help-needed',
    'moving',
    '1-day',
    '{"truck", "heavy lifting"}',
    NULL,
    '{}',
    ST_SetSRID(
      ST_MakePoint(-122.56976069119153, 47.170026057552036),
      4326
    ),
    true,
    604800,
    '2025-06-23 18:42:27.977249+00',
    '2025-06-23 18:42:27.977249+00',
    NULL
  );

INSERT INTO
  public.reputation (
    id,
    user_id,
    positive_points,
    negative_points,
    total_interactions,
    created_at,
    updated_at
  )
VALUES
  (
    '9742fb31-4b76-4039-aaea-98f578b115c5',
    'cc4210ac-08ed-45cf-8f45-5548b15c9607',
    0,
    0,
    0,
    '2025-06-23 00:40:30.907223+00',
    '2025-06-23 00:40:30.907223+00'
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
    '68f4917c-186a-4a67-9b54-458f3c9dca7a',
    '4f95670a-ec9e-4703-9fac-ba2832d20f44',
    '3e1f7332-507d-4dc9-827c-eb54c3d4187b',
    'cc4210ac-08ed-45cf-8f45-5548b15c9607',
    '2025-06-26 06:06:09.169913+00',
    0,
    1,
    '2025-06-26 06:06:03.415135+00',
    '2025-06-26 06:06:09.169913+00'
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
    '5d2e0481-918b-4f70-8ff1-c675a005d74a',
    '68f4917c-186a-4a67-9b54-458f3c9dca7a',
    '3e1f7332-507d-4dc9-827c-eb54c3d4187b',
    'text',
    'Hello',
    NULL,
    '2025-06-26 06:06:09.169913+00'
  );
