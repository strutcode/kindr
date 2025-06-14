# Kindr - Community Assistance Platform

Kindr is a modern web application that connects neighbors to offer and receive help within their local communities. Built with Vue 3, TypeScript, and Supabase, it provides a secure and user-friendly platform for community building.

## Features

### 🔐 Authentication System
- Email/password registration and login
- Social authentication (Google, Facebook)
- Secure user profiles with verification
- Customizable notification radius settings

### 📝 Request Management
- Create, edit, and delete assistance requests
- Rich text descriptions with image uploads
- Categorized requests (Free stuff, Help needed, Skills offered)
- Duration estimation and skills tagging
- Optional compensation details

### 📍 Location Services
- Geolocation-based filtering
- Customizable radius selection (0.5-10 miles)
- Interactive map visualization
- Privacy-controlled address sharing

### ⭐ Reputation System
- Point-based reputation tracking
- Comprehensive feedback system
- Visual reputation bars (positive/negative/unknown)
- Trust-building through community interactions

## Tech Stack

### Frontend
- **Vue 3** with Composition API
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **Vue Router** for navigation
- **Pinia** for state management
- **Vite** for development and building

### Backend
- **Supabase** for database and authentication
- **PostgreSQL** database with Row Level Security
- **Edge Functions** for serverless operations
- **Real-time subscriptions** for live updates

### Testing
- **Vitest** for unit and integration testing
- **Vue Test Utils** for component testing
- **Coverage reporting** with V8

## Getting Started

### Prerequisites
- Node.js 18+ 
- npm or yarn
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd kindr
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Fill in your Supabase credentials in `.env`:
   ```env
   VITE_SUPABASE_URL=your_supabase_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Set up Supabase Database**
   
   Run the following SQL commands in your Supabase SQL editor:

   ```sql
   -- Enable necessary extensions
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   
   -- Users table
   CREATE TABLE users (
     id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
     email TEXT UNIQUE NOT NULL,
     full_name TEXT,
     avatar_url TEXT,
     phone TEXT,
     location JSONB,
     notification_radius INTEGER DEFAULT 2,
     created_at TIMESTAMPTZ DEFAULT NOW(),
     updated_at TIMESTAMPTZ DEFAULT NOW()
   );
   
   -- Requests table
   CREATE TABLE requests (
     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
     user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
     title TEXT NOT NULL,
     description TEXT NOT NULL,
     category TEXT NOT NULL CHECK (category IN ('free-stuff', 'help-needed', 'skills-offered')),
     subcategory TEXT NOT NULL,
     duration_estimate TEXT NOT NULL CHECK (duration_estimate IN ('15min', '1hour', '1day', 'multiple-days')),
     skills_required TEXT[] DEFAULT '{}',
     compensation TEXT,
     images TEXT[] DEFAULT '{}',
     location JSONB NOT NULL,
     status TEXT DEFAULT 'active' CHECK (status IN ('active', 'in-progress', 'completed', 'cancelled')),
     created_at TIMESTAMPTZ DEFAULT NOW(),
     updated_at TIMESTAMPTZ DEFAULT NOW(),
     expires_at TIMESTAMPTZ
   );
   
   -- Reputation table
   CREATE TABLE reputation (
     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
     user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL UNIQUE,
     positive_points INTEGER DEFAULT 0,
     negative_points INTEGER DEFAULT 0,
     total_interactions INTEGER DEFAULT 0,
     created_at TIMESTAMPTZ DEFAULT NOW(),
     updated_at TIMESTAMPTZ DEFAULT NOW()
   );
   
   -- Reviews table
   CREATE TABLE reviews (
     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
     request_id UUID REFERENCES requests(id) ON DELETE CASCADE NOT NULL,
     reviewer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
     reviewee_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
     punctuality TEXT NOT NULL CHECK (punctuality IN ('no-show', 'late', 'on-time')),
     helpfulness TEXT NOT NULL CHECK (helpfulness IN ('helpful', 'unhelpful')),
     accuracy TEXT NOT NULL CHECK (accuracy IN ('as-described', 'not-as-described')),
     additional_feedback TEXT,
     created_at TIMESTAMPTZ DEFAULT NOW()
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
   
   -- RLS Policies for requests
   CREATE POLICY "Anyone can read active requests" ON requests
     FOR SELECT USING (status = 'active');
   
   CREATE POLICY "Users can create requests" ON requests
     FOR INSERT WITH CHECK (auth.uid() = user_id);
   
   CREATE POLICY "Users can update own requests" ON requests
     FOR UPDATE USING (auth.uid() = user_id);
   
   -- RLS Policies for reputation
   CREATE POLICY "Anyone can read reputation" ON reputation
     FOR SELECT USING (true);
   
   -- RLS Policies for reviews
   CREATE POLICY "Users can read reviews about them" ON reviews
     FOR SELECT USING (auth.uid() = reviewee_id OR auth.uid() = reviewer_id);
   
   CREATE POLICY "Users can create reviews" ON reviews
     FOR INSERT WITH CHECK (auth.uid() = reviewer_id);
   
   -- Function to update reputation
   CREATE OR REPLACE FUNCTION update_reputation(
     user_id UUID,
     positive_delta INTEGER,
     negative_delta INTEGER
   )
   RETURNS VOID AS $$
   BEGIN
     INSERT INTO reputation (user_id, positive_points, negative_points, total_interactions)
     VALUES (user_id, positive_delta, negative_delta, 1)
     ON CONFLICT (user_id) DO UPDATE SET
       positive_points = reputation.positive_points + positive_delta,
       negative_points = reputation.negative_points + negative_delta,
       total_interactions = reputation.total_interactions + 1,
       updated_at = NOW();
   END;
   $$ LANGUAGE plpgsql SECURITY DEFINER;
   ```

5. **Set up Supabase Storage**
   
   Create the storage bucket and configure RLS policies for image uploads:

   ```sql
   -- Enable Row Level Security for storage objects (if not already enabled)
   ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
   
   -- Create policy to allow authenticated users to upload images to their own folder within the 'request-images' bucket
   CREATE POLICY "Allow authenticated uploads to request-images" ON storage.objects
   FOR INSERT WITH CHECK (bucket_id = 'request-images' AND auth.uid()::text = (storage.foldername(name))[1]);
   
   -- Create policy to allow public read access to images in the 'request-images' bucket
   CREATE POLICY "Allow public read access to request-images" ON storage.objects
   FOR SELECT USING (bucket_id = 'request-images');
   ```

   **Note:** Make sure you have created the 'request-images' bucket in your Supabase Storage dashboard before running these policies.

6. **Configure Authentication Providers** (Optional)
   
   In your Supabase dashboard:
   - Go to Authentication > Providers
   - Enable Google OAuth and configure with your credentials
   - Set redirect URL to: `http://localhost:5173/auth/callback`

7. **Start the development server**
   ```bash
   npm run dev
   ```

8. **Run tests**
   ```bash
   npm run test
   ```

## Project Structure

```
src/
├── components/           # Reusable Vue components
│   ├── common/          # Common UI components
│   └── requests/        # Request-specific components
├── constants/           # Application constants
├── lib/                # Third-party library configurations
├── router/             # Vue Router configuration
├── services/           # Business logic and API services
├── stores/             # Pinia state management
├── test/               # Test files
├── types/              # TypeScript type definitions
└── views/              # Page components
```

## Key Components

### Authentication
- `AuthStore`: Manages user authentication state
- `AuthView`: Login/signup form with social auth
- `AuthCallbackView`: Handles OAuth redirects

### Request Management
- `RequestsStore`: Manages request state and API calls
- `RequestCard`: Displays request information
- `CreateRequestView`: Form for creating new requests

### Reputation System
- `ReputationStore`: Manages user reputation data
- `ReputationBar`: Visual reputation display
- Review submission and feedback system

### Location Services
- `LocationService`: Geolocation utilities
- Distance calculations and filtering
- Map integration with Leaflet

## Security Features

- **Row Level Security (RLS)** on all database tables
- **Input validation** with Zod schemas  
- **XSS protection** through Vue's built-in sanitization
- **Rate limiting** on API endpoints
- **Privacy controls** for location sharing
- **Secure authentication** with Supabase Auth

## Testing

The application includes comprehensive testing:

```bash
# Run all tests
npm run test

# Run tests with UI
npm run test:ui

# Generate coverage report
npm run test:coverage
```

Test coverage includes:
- Component unit tests
- Store logic testing
- Service function testing
- Integration testing for key workflows

## Deployment

### Build for Production

```bash
npm run build
```

### Deploy to Netlify

1. Connect your repository to Netlify
2. Set build command: `npm run build`
3. Set publish directory: `dist`
4. Add environment variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

### Deploy to Vercel

```bash
npx vercel
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `VITE_SUPABASE_URL` | Your Supabase project URL | Yes |
| `VITE_SUPABASE_ANON_KEY` | Your Supabase anonymous key | Yes |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please open an issue in the GitHub repository or contact the development team.

---

Built with ❤️ for stronger communities