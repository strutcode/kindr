Design and implement a community assistance web application called "Kindr" with the following specifications:

Frontend Requirements:

1. Create a Vue 3 + TypeScript application using Vite, implementing:
   - Responsive layouts with Tailwind CSS
   - Vue Router for navigation
   - Pinia for state management
   - Component-based architecture following Vue 3 Composition API

Core Features:

1. Authentication System:

   - Email/password registration and login using Supabase Auth
   - Social authentication options (Google, Facebook)
   - Profile creation with verification steps
   - User preference settings for notification radius

2. Request Management:

   - Create, edit, and delete assistance requests
   - Rich text editor for request descriptions
   - Category selection (Free stuff, Help needed, Skills offered)
   - Subcategories under main categories (Free stuff -> Hygiene, Food; Help needed -> Transportation, Moving; Skills offered -> Tutoring, Handyman)
   - Duration estimation (15 minutes, 1 hour, 1 day)
   - Skills required tags
   - Optional compensation details
   - Image upload capability

3. Location Services:

   - Geolocation-based filtering
   - Custom radius selection (0.5-10 miles)
   - Map visualization of nearby requests
   - Address privacy controls

4. Reputation System:
   - Users start as an unknown with no points
   - When completing a request, both users are asked to provide feedback
   - Feedback should be presented as a series of options such as "No show"/"Late"/"On Time", "Helpful"/"Unhelpful", "As described"/"Not as described"
   - Positive points are awarded for good behavior, for example 10 good points for providing a free item, 5 good points for being on time
   - Negative points for bad behavior, such as 5 points for being late or not showing up
   - Profiles should display a ratio of positive to negative points as well as an "unknown" ratio if the points are under a threshold of 100
   - Display reputation as a bar with a green section for good points, a red section for bad points and a grey section for unknown

Backend Requirements (Supabase):

1. Database Schema:

   - Users table with profile information
   - Requests table with location data
   - Categories table
   - Reputation tracking table
   - Reviews and ratings table

2. Edge Functions:
   - Geospatial calculations
   - Point system management
   - Notification handling
   - Request matching algorithm

Testing Requirements:

1. Implement comprehensive testing using Vitest:
   - Component unit tests
   - Integration tests for core features
   - API interaction tests
   - Authentication flow tests
   - Geolocation service tests

Security Requirements:

1. Implement:
   - Rate limiting
   - Input validation
   - XSS protection
   - CSRF protection
   - Data encryption
   - Privacy controls

Deliverables:

1. Fully functional web application
2. Comprehensive documentation
3. Test coverage report
4. Security audit report
5. Deployment guide

The application should prioritize user privacy, ease of use, and community building while maintaining high performance and security standards.