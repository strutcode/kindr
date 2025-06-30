
CREATE OR REPLACE FUNCTION create_seed_user(
  p_name text,
  p_email text
)
RETURNS void AS $$
DECLARE
  v_id uuid;
  v_time timestamptz;
  v_meta jsonb;
BEGIN
  v_id := uuid_generate_v4();
  v_time := now() - (interval '1 second' * floor(random() * 30 * 24 * 60 * 60));
  v_meta := jsonb_build_object(
    'sub', v_id,
    'full_name', p_name,
    'email', p_email,
    'email_verified', true,
    'phone_verified', true
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
      v_id,
      'authenticated',
      'authenticated',
      p_email,
      '$2a$10$dBukFqbp/A.iPs9pg0tH5efOCgO4rthD0mwl421cS/kzj7j0HRCmW',
      v_time,
      NULL,
      '',
      NULL,
      '',
      NULL,
      '',
      '',
      NULL,
      v_time,
      '{"provider": "email", "providers": ["email"]}',
      v_meta,
      NULL,
      v_time,
      v_time,
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
      v_id,
      v_id,
      v_meta,
      'email',
      v_time,
      v_time,
      v_time,
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
      v_id,
      p_name,
      NULL,
      NULL,
      v_time,
      v_time
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
      uuid_generate_v4(),
      v_id,
      0,
      0,
      0,
      v_time,
      v_time
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION create_seed_listing(
  p_user_id uuid,
  p_title text,
  p_description text,
  p_location geometry(Point, 4326),
  p_category text,
  p_subcategory text,
  p_duration_estimate text DEFAULT NULL,
  p_skills_required text[] DEFAULT NULL,
  p_compensation text DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  v_id uuid;
  v_time timestamptz;
  v_meta jsonb;
BEGIN
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
      uuid_generate_v4(),
      p_user_id,
      p_title,
      p_description,
      p_category,
      p_subcategory,
      p_duration_estimate,
      p_skills_required,
      p_compensation,
      '{}',
      ST_SetSRID(
        p_location,
        4326
      ),
      true,
      604800,
      now(),
      now(),
      NULL
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION random_user_id()
RETURNS uuid AS $$
DECLARE
  v_user_id uuid;
BEGIN
  SELECT id INTO v_user_id
  FROM auth.users
  ORDER BY random()
  LIMIT 1;

  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION random_listing_id()
RETURNS uuid AS $$
DECLARE
  v_listing_id uuid;
BEGIN
  SELECT id INTO v_listing_id
  FROM public.listings
  ORDER BY random()
  LIMIT 1;

  RETURN v_listing_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;