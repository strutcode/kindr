# Kindr - Community Assistance Platform

Kindr is a modern web application that connects neighbors to offer and receive help within their local communities. Built with Vue 3, TypeScript, and Supabase, it provides a secure and user-friendly platform for community building.

## Features

### 🔐 Authentication System

- Email/password registration and login
- Social authentication (Google, Facebook)
- Secure user profiles with verification
- Customizable notification radius settings

### 📝 Listing Management

- Create, edit, and delete assistance listings
- Rich text descriptions with image uploads
- Categorized listings (Free stuff, Help needed, Skills offered)
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

   Run the supabase setup command:

   ```bash
   supabase db reset
   ```

5. **Configure Authentication Providers** (Optional)

   In your Supabase dashboard:

   - Go to Authentication > Providers
   - Enable Google OAuth and configure with your credentials
   - Set redirect URL to: `http://localhost:5173/auth/callback`

6. **Start the development server**

   ```bash
   npm run dev
   ```

7. **Run tests**
   ```bash
   npm run test
   ```

## Project Structure

```
src/
├── components/           # Reusable Vue components
│   ├── common/          # Common UI components
│   └── listings/        # Listing-specific components
├── constants/           # Application constants
├── lib/                # Third-party library configurations
├── router/             # Vue Router configuration
├── services/           # Business logic and API services
├── stores/             # Pinia state management
├── test/               # Test files
├── types/              # TypeScript type definitions
└── views/              # Page components
```

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

| Variable                 | Description                 | Required |
| ------------------------ | --------------------------- | -------- |
| `VITE_SUPABASE_URL`      | Your Supabase project URL   | Yes      |
| `VITE_SUPABASE_ANON_KEY` | Your Supabase anonymous key | Yes      |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Listing

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, please open an issue in the GitHub repository or contact the development team.

---

Built with ❤️ for stronger communities
