import type { LocationFilter } from '@/types'
import { supabase } from '@/lib/supabase'

// Standardized location data interface
interface LocationData {
  latitude: number
  longitude: number
  city: string
  country: string
  countryCode: string
  timeZone: string
  accuracy?: 'high' | 'medium' | 'low'
  source: 'gps' | 'ip' | 'fallback'
}

export class LocationService {
  /**
   * Gets the user's current position using browser geolocation with Supabase fallback
   */
  static async getCurrentPosition(): Promise<LocationData> {
    try {
      // Try GPS/browser geolocation first
      console.log('Attempting to get GPS location...')
      
      if (!navigator.geolocation) {
        throw new Error('Geolocation is not supported by this browser')
      }

      const position = await new Promise<GeolocationPosition>((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(
          resolve,
          reject,
          {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 5 * 60 * 1000, // 5 minutes
          }
        )
      })

      console.log('GPS location successful:', position.coords)
      
      return {
        latitude: position.coords.latitude,
        longitude: position.coords.longitude,
        city: 'Current Location',
        country: 'Unknown',
        countryCode: 'Unknown',
        timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
        accuracy: 'high',
        source: 'gps',
      }
    } catch (gpsError) {
      console.warn('GPS location failed, trying Supabase fallback:', gpsError)
      
      try {
        // Fallback to Supabase edge function using the configured client
        const { data, error } = await supabase.functions.invoke('get-user-location')

        if (error) {
          throw new Error(`Supabase function failed: ${error}`)
        }

        if (!data) {
          throw new Error('No data received from Supabase function')
        }
        
        // Validate response data
        if (!data.latitude || !data.longitude) {
          throw new Error('Invalid response: Missing latitude or longitude data')
        }

        const latitude = parseFloat(data.latitude)
        const longitude = parseFloat(data.longitude)

        if (isNaN(latitude) || isNaN(longitude)) {
          throw new Error('Invalid response: Latitude or longitude is not a valid number')
        }

        if (latitude < -90 || latitude > 90) {
          throw new Error('Invalid response: Latitude out of valid range (-90 to 90)')
        }

        if (longitude < -180 || longitude > 180) {
          throw new Error('Invalid response: Longitude out of valid range (-180 to 180)')
        }

        console.log('Supabase location successful:', data)

        return {
          latitude,
          longitude,
          city: data.city || 'Unknown',
          country: data.country || 'Unknown',
          countryCode: data.countryCode || 'Unknown',
          timeZone: data.timeZone || Intl.DateTimeFormat().resolvedOptions().timeZone,
          accuracy: 'medium',
          source: 'ip',
        }
      } catch (supabaseError) {
        console.warn('Supabase location also failed:', supabaseError)
        
        // Final fallback to default location (Los Angeles, CA)
        console.warn('All location methods failed, using default location')
        return {
          latitude: 34.0522,
          longitude: -118.2437,
          city: 'Los Angeles',
          country: 'United States',
          countryCode: 'US',
          timeZone: 'America/Los_Angeles',
          accuracy: 'low',
          source: 'fallback',
        }
      }
    }
  }

  // Keep existing utility methods for compatibility
  static calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number
  ): number {
    const R = 3959 // Earth's radius in miles
    const dLat = this.toRadians(lat2 - lat1)
    const dLon = this.toRadians(lon2 - lon1)
    
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRadians(lat1)) *
        Math.cos(this.toRadians(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2)
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return R * c
  }

  static toRadians(degrees: number): number {
    return degrees * (Math.PI / 180)
  }

  static async geocodeAddress(address: string): Promise<{
    latitude: number
    longitude: number
    formatted_address: string
  }> {
    // This would typically use a geocoding service like Google Maps API
    // For demo purposes, we'll return a mock response
    throw new Error('Geocoding service not implemented')
  }

  static async reverseGeocode(latitude: number, longitude: number): Promise<string> {
    // This would typically use a reverse geocoding service
    // For demo purposes, we'll return a mock response
    return `${latitude.toFixed(4)}, ${longitude.toFixed(4)}`
  }

  static filterRequestsByLocation<T extends { location: { latitude: number; longitude: number } }>(
    requests: T[],
    filter: LocationFilter
  ): T[] {
    return requests.filter(request => {
      const distance = this.calculateDistance(
        filter.latitude,
        filter.longitude,
        request.location.latitude,
        request.location.longitude
      )
      return distance <= filter.radius
    })
  }
}