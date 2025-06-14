/*
  # Initial Database Setup for LocalHelp

  1. New Tables
    - `users` - User profiles and settings
      - `id` (uuid, primary key, references auth.users)
      - `email` (text, unique)
      - `full_name` (text, optional)
      - `avatar_url` (text, optional)
      - `phone` (text, optional)
      - `location` (jsonb, optional)
      - `notification_radius` (integer, default 2 miles)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
    
    - `requests` - Community assistance requests
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to users)
      - `title` (text)
      - `description` (text)
      - `category` (text, constrained values)
      - `subcategory` (text)
      - `duration_estimate` (text, constrained values)
      - `skills_required` (text array)
      - `compensation` (text, optional)
      - `images` (text array, optional)
      - `location` (jsonb)
      - `status` (text, default 'active')
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      - `expires_at` (timestamptz, optional)
    
    - `reputation` - User reputation tracking
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to users, unique)
      - `positive_points` (integer, default 0)
      - `negative_points` (integer, default 0)
      - `total_interactions` (integer, default 0)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
    
    - `reviews` - User feedback and reviews
      - `id` (uuid, primary key)
      - `request_id` (uuid, foreign key to requests)
      - `reviewer_id` (uuid, foreign key to users)
      - `reviewee_id` (uuid, foreign key to users)
      - `punctuality` (text, constrained values)
      - `helpfulness` (text, constrained values)
      - `accuracy` (text, constrained values)
      - `additional_feedback` (text, optional)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to manage their own data
    - Add policies for public read access where appropriate
    - Add policies for review creation and reading

  3. Functions
    - `update_reputation` function for atomic reputation updates
*/

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id uuid REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email text UNIQUE NOT NULL,
  full_name text,
  avatar_url text,
  phone text,
  location jsonb,
  notification_radius integer DEFAULT 2,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Requests table
CREATE TABLE IF NOT EXISTS requests (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  category text NOT NULL CHECK (category IN ('free-stuff', 'help-needed', 'skills-offered')),
  subcategory text NOT NULL,
  duration_estimate text NOT NULL CHECK (duration_estimate IN ('15min', '1hour', '1day', 'multiple-days')),
  skills_required text[] DEFAULT '{}',
  compensation text,
  images text[] DEFAULT '{}',
  location jsonb NOT NULL,
  status text DEFAULT 'active' CHECK (status IN ('active', 'in-progress', 'completed', 'cancelled')),
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
  request_id uuid REFERENCES requests(id) ON DELETE CASCADE NOT NULL,
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
ALTER TABLE requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE reputation ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "Users can read own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for requests
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
CREATE INDEX IF NOT EXISTS idx_requests_user_id ON requests(user_id);
CREATE INDEX IF NOT EXISTS idx_requests_category ON requests(category);
CREATE INDEX IF NOT EXISTS idx_requests_status ON requests(status);
CREATE INDEX IF NOT EXISTS idx_requests_created_at ON requests(created_at);
CREATE INDEX IF NOT EXISTS idx_reputation_user_id ON reputation(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_request_id ON reviews(request_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer_id ON reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewee_id ON reviews(reviewee_id);