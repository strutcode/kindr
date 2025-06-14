const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "*",
};

interface LocationResponse {
  latitude: string;
  longitude: string;
  city?: string;
  country?: string;
  countryCode?: string;
  timeZone?: string;
}

/**
 * Extracts the client's real IP address from request headers
 * Prioritizes forwarded headers before falling back to direct connection IP
 */
function extractClientIP(req: Request, connInfo: Deno.ServeHandlerInfo): string {
  // Check X-Forwarded-For header first (most common proxy header)
  const xForwardedFor = req.headers.get('X-Forwarded-For');
  if (xForwardedFor) {
    // X-Forwarded-For can contain multiple IPs: "client, proxy1, proxy2"
    // We want the first one (the original client IP)
    const firstIP = xForwardedFor.split(',')[0].trim();
    if (firstIP && isValidIP(firstIP)) {
      console.log('Using IP from X-Forwarded-For:', firstIP);
      return firstIP;
    }
  }

  // Check X-Real-IP header (used by some proxies/load balancers)
  const xRealIP = req.headers.get('X-Real-IP');
  if (xRealIP && isValidIP(xRealIP.trim())) {
    console.log('Using IP from X-Real-IP:', xRealIP.trim());
    return xRealIP.trim();
  }

  // Check CF-Connecting-IP header (Cloudflare)
  const cfConnectingIP = req.headers.get('CF-Connecting-IP');
  if (cfConnectingIP && isValidIP(cfConnectingIP.trim())) {
    console.log('Using IP from CF-Connecting-IP:', cfConnectingIP.trim());
    return cfConnectingIP.trim();
  }

  // Check X-Client-IP header (some other proxies)
  const xClientIP = req.headers.get('X-Client-IP');
  if (xClientIP && isValidIP(xClientIP.trim())) {
    console.log('Using IP from X-Client-IP:', xClientIP.trim());
    return xClientIP.trim();
  }

  // Fall back to direct connection IP
  try {
    const remoteAddr = connInfo.remoteAddr as Deno.NetAddr;
    const directIP = remoteAddr.hostname;
    console.log('Using direct connection IP:', directIP);
    return directIP;
  } catch (error) {
    console.error('Failed to get direct connection IP:', error);
    // Ultimate fallback - return localhost (will trigger fallback location)
    return '127.0.0.1';
  }
}

/**
 * Validates if a string is a valid IP address (IPv4 or IPv6)
 */
function isValidIP(ip: string): boolean {
  // Basic IPv4 validation
  const ipv4Regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
  
  // Basic IPv6 validation (simplified)
  const ipv6Regex = /^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|^::1$|^::$/;
  
  // Check for private/local IPs that won't work with geolocation
  const privateIPRegex = /^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.|169\.254\.|::1|fc00:|fe80:)/;
  
  if (!ipv4Regex.test(ip) && !ipv6Regex.test(ip)) {
    return false;
  }
  
  // Don't use private/local IPs for geolocation
  if (privateIPRegex.test(ip)) {
    console.log('Skipping private/local IP:', ip);
    return false;
  }
  
  return true;
}

Deno.serve(async (req: Request, connInfo: Deno.ServeHandlerInfo) => {
  try {
    if (req.method === "OPTIONS") {
      return new Response(null, {
        status: 200,
        headers: corsHeaders,
      });
    }

    // Extract client IP from headers with fallback logic
    const clientIP = extractClientIP(req, connInfo);
    
    console.log('Final client IP for geolocation:', clientIP);
    console.log('Request headers:', {
      'X-Forwarded-For': req.headers.get('X-Forwarded-For'),
      'X-Real-IP': req.headers.get('X-Real-IP'),
      'CF-Connecting-IP': req.headers.get('CF-Connecting-IP'),
      'X-Client-IP': req.headers.get('X-Client-IP'),
      'User-Agent': req.headers.get('User-Agent'),
    });

    // Use a free IP geolocation service
    let locationData: LocationResponse;

    try {
      // Skip geolocation for localhost/private IPs
      if (clientIP === '127.0.0.1' || !isValidIP(clientIP)) {
        throw new Error('Invalid or private IP address, using fallback location');
      }

      // Create AbortController with timeout to prevent hanging requests
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000); // 5 second timeout

      try {
        // Try ipapi.co first (free tier: 1000 requests/day)
        const response = await fetch(`https://ipapi.co/${clientIP}/json/`, {
          signal: controller.signal,
          headers: {
            'User-Agent': 'Mozilla/5.0 (compatible; Kindr/1.0)',
            'Accept': 'application/json',
          },
        });
        
        clearTimeout(timeoutId);
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status} ${response.statusText}`);
        }
        
        // Add try-catch around JSON parsing to handle malformed responses
        let data;
        try {
          const responseText = await response.text();
          if (!responseText.trim()) {
            throw new Error('Empty response from geolocation service');
          }
          data = JSON.parse(responseText);
        } catch (jsonError) {
          console.error('Failed to parse JSON response:', jsonError);
          throw new Error('Invalid JSON response from geolocation service');
        }
        
        // Check for API errors
        if (data.error === true || data.error === 'true') {
          throw new Error(data.reason || data.message || 'IP geolocation service error');
        }

        // Validate required fields
        if (!data.latitude || !data.longitude) {
          throw new Error('Missing latitude or longitude in API response');
        }

        locationData = {
          latitude: data.latitude?.toString() || '34.0522',
          longitude: data.longitude?.toString() || '-118.2437',
          city: data.city || 'Los Angeles',
          country: data.country_name || 'United States',
          countryCode: data.country_code || 'US',
          timeZone: data.timezone || 'America/Los_Angeles',
        };

        console.log('Location data from ipapi.co:', locationData);
      } catch (fetchError) {
        clearTimeout(timeoutId);
        throw fetchError;
      }
    } catch (error) {
      console.warn('Geolocation failed, using fallback location:', error);
      
      // Fallback to default Los Angeles location
      locationData = {
        latitude: '34.0522',
        longitude: '-118.2437',
        city: 'Los Angeles',
        country: 'United States',
        countryCode: 'US',
        timeZone: 'America/Los_Angeles',
      };
    }

    return new Response(
      JSON.stringify(locationData),
      {
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    );
  } catch (error) {
    console.error('Edge function error:', error);
    
    // Return proper error response with 500 status code
    return new Response(
      JSON.stringify({
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error occurred',
        fallback: {
          latitude: '34.0522',
          longitude: '-118.2437',
          city: 'Los Angeles',
          country: 'United States',
          countryCode: 'US',
          timeZone: 'America/Los_Angeles',
        }
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    );
  }
});