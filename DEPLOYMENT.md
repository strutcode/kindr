# Deployment Guide

## Overview

This guide covers deploying the Kindr community assistance application to production environments.

## Prerequisites

- Node.js 18+ installed
- Supabase account and project
- Domain name (optional but recommended)
- SSL certificate (handled automatically by most platforms)

## Environment Setup

### 1. Supabase Configuration

1. **Create a Supabase project**:
   - Go to [supabase.com](https://supabase.com)
   - Create a new project
   - Note your project URL and anon key

2. **Run database migrations**:
   ```bash
   # Install Supabase CLI (if not already installed)
   npm install -g supabase
   
   # Link to your project
   supabase link --project-ref your-project-ref
   
   # Run migrations
   supabase db push
   ```

3. **Set up authentication providers**:
   - Go to Authentication > Providers in Supabase dashboard
   - Enable Email provider
   - Configure Google OAuth (optional):
     - Add your domain to authorized origins
     - Set redirect URL to: `https://yourdomain.com/auth/callback`

4. **Configure storage**:
   - The `request-images` bucket should be created automatically
   - Verify RLS policies are in place
   - Set file size limits and allowed MIME types

### 2. Environment Variables

Create production environment variables:

```bash
# Required
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key

# Optional
VITE_API_URL=https://your-api-domain.com
VITE_APP_ENV=production
```

## Deployment Options

### Option 1: Netlify (Recommended)

1. **Connect repository**:
   - Go to [netlify.com](https://netlify.com)
   - Connect your GitHub repository
   - Choose the main branch

2. **Configure build settings**:
   ```yaml
   # netlify.toml
   [build]
     command = "npm run build"
     publish = "dist"
   
   [build.environment]
     NODE_VERSION = "18"
   
   [[redirects]]
     from = "/*"
     to = "/index.html"
     status = 200
   ```

3. **Set environment variables**:
   - Go to Site settings > Environment variables
   - Add your Supabase URL and anon key

4. **Deploy**:
   - Push to main branch or trigger manual deploy
   - Netlify will automatically build and deploy

### Option 2: Vercel

1. **Install Vercel CLI**:
   ```bash
   npm install -g vercel
   ```

2. **Deploy**:
   ```bash
   vercel --prod
   ```

3. **Configure environment variables**:
   ```bash
   vercel env add VITE_SUPABASE_URL
   vercel env add VITE_SUPABASE_ANON_KEY
   ```

### Option 3: Custom Server

1. **Build the application**:
   ```bash
   npm run build
   ```

2. **Serve static files**:
   ```nginx
   # nginx.conf
   server {
       listen 80;
       server_name yourdomain.com;
       
       location / {
           root /path/to/dist;
           try_files $uri $uri/ /index.html;
       }
       
       # Security headers
       add_header X-Frame-Options DENY;
       add_header X-Content-Type-Options nosniff;
       add_header X-XSS-Protection "1; mode=block";
   }
   ```

## Post-Deployment Checklist

### 1. Verify Core Functionality
- [ ] User registration and login
- [ ] Request creation and viewing
- [ ] Image upload functionality
- [ ] Map visualization
- [ ] Location services
- [ ] Email notifications (if configured)

### 2. Security Verification
- [ ] HTTPS enabled
- [ ] Security headers configured
- [ ] RLS policies working
- [ ] Rate limiting functional
- [ ] Input validation active

### 3. Performance Testing
- [ ] Page load times < 3 seconds
- [ ] Image optimization working
- [ ] Map clustering functional
- [ ] Mobile responsiveness
- [ ] Offline functionality (basic)

### 4. Monitoring Setup
- [ ] Error tracking (Sentry, LogRocket, etc.)
- [ ] Analytics (Google Analytics, Plausible, etc.)
- [ ] Uptime monitoring
- [ ] Performance monitoring

## Monitoring and Maintenance

### Application Monitoring

1. **Error Tracking**:
   ```typescript
   // Add to main.ts
   import * as Sentry from '@sentry/vue'
   
   Sentry.init({
     app,
     dsn: 'your-sentry-dsn',
     environment: 'production'
   })
   ```

2. **Performance Monitoring**:
   ```typescript
   // Add performance tracking
   import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals'
   
   getCLS(console.log)
   getFID(console.log)
   getFCP(console.log)
   getLCP(console.log)
   getTTFB(console.log)
   ```

### Database Monitoring

1. **Supabase Dashboard**:
   - Monitor database performance
   - Check API usage
   - Review authentication metrics
   - Monitor storage usage

2. **Custom Monitoring**:
   ```sql
   -- Monitor request creation rate
   SELECT 
     DATE_TRUNC('hour', created_at) as hour,
     COUNT(*) as requests_created
   FROM requests 
   WHERE created_at > NOW() - INTERVAL '24 hours'
   GROUP BY hour
   ORDER BY hour;
   ```

### Regular Maintenance

#### Daily
- [ ] Check error logs
- [ ] Monitor application performance
- [ ] Review user feedback

#### Weekly
- [ ] Update dependencies
- [ ] Review security logs
- [ ] Check database performance
- [ ] Backup verification

#### Monthly
- [ ] Security audit
- [ ] Performance optimization
- [ ] User analytics review
- [ ] Feature usage analysis

## Scaling Considerations

### Database Scaling
- Monitor connection pool usage
- Consider read replicas for heavy read workloads
- Implement database connection pooling
- Optimize slow queries

### CDN and Caching
- Use CDN for static assets
- Implement browser caching
- Consider service worker for offline functionality
- Cache API responses where appropriate

### Geographic Distribution
- Deploy to multiple regions
- Use edge functions for better performance
- Consider database replication for global users

## Troubleshooting

### Common Issues

1. **Build Failures**:
   ```bash
   # Clear cache and reinstall
   rm -rf node_modules package-lock.json
   npm install
   npm run build
   ```

2. **Environment Variable Issues**:
   ```bash
   # Verify variables are set
   echo $VITE_SUPABASE_URL
   echo $VITE_SUPABASE_ANON_KEY
   ```

3. **Database Connection Issues**:
   - Check Supabase project status
   - Verify RLS policies
   - Check API key permissions

4. **Authentication Issues**:
   - Verify redirect URLs
   - Check OAuth provider configuration
   - Review Supabase auth settings

### Support Resources

- **Documentation**: [docs.kindr.app](https://docs.kindr.app)
- **Community**: [community.kindr.app](https://community.kindr.app)
- **Support**: support@kindr.app
- **Status Page**: [status.kindr.app](https://status.kindr.app)

## Rollback Procedures

### Quick Rollback
1. Revert to previous deployment in hosting platform
2. Verify application functionality
3. Investigate and fix issues
4. Redeploy when ready

### Database Rollback
1. **Never rollback database migrations in production**
2. Instead, create new migrations to fix issues
3. Use feature flags to disable problematic features
4. Coordinate with development team

## Contact

For deployment support:
- DevOps Team: devops@kindr.app
- Technical Support: tech@kindr.app
- Emergency: emergency@kindr.app