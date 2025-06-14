/*
  # Create Images Storage Bucket

  1. Storage Setup
    - Create 'request-images' bucket for storing uploaded images (if it doesn't exist)
    - Set up proper access policies for authenticated users
    - Configure bucket settings for image optimization

  2. Security
    - Allow authenticated users to upload images
    - Allow public read access to images
    - Restrict file types and sizes at bucket level
*/

-- Create the request-images bucket only if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'request-images'
  ) THEN
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES (
      'request-images',
      'request-images',
      true,
      2097152, -- 2MB limit
      ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
    );
  ELSE
    -- Update existing bucket settings if needed
    UPDATE storage.buckets 
    SET 
      public = true,
      file_size_limit = 2097152,
      allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif']
    WHERE id = 'request-images';
  END IF;
END $$;

-- Drop existing policies if they exist to avoid conflicts
DROP POLICY IF EXISTS "Authenticated users can upload images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own images" ON storage.objects;
DROP POLICY IF EXISTS "Public can view images" ON storage.objects;

-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'request-images');

-- Allow authenticated users to update their own images
CREATE POLICY "Users can update own images" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'request-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow authenticated users to delete their own images
CREATE POLICY "Users can delete own images" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'request-images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow public read access to images
CREATE POLICY "Public can view images" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'request-images');