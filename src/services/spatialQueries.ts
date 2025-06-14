import { supabase, handleSupabaseResponse, SupabaseError, retryOperation } from '@/lib/supabase'
import type { Request } from '@/types'

/**
 * Map bounds interface for spatial queries
 */
export interface MapBounds {
  north: number
  south: number
  east: number
  west: number
}

/**
 * Spatial query options
 */
export interface SpatialQueryOptions {
  category?: string
  subcategory?: string
  status?: string
  limit?: number
}

/**
 * Request with distance information
 */
export interface RequestWithDistance extends Request {
  distance_meters?: number
}

/**
 * Service for spatial queries using PostGIS
 */
export class SpatialQueryService {
  /**
   * Validates map bounds coordinates
   */
  static validateBounds(bounds: MapBounds): void {
    const { north, south, east, west } = bounds

    // Check if bounds are valid
    if (north <= south) {
      throw new SupabaseError('Invalid bounds: north must be greater than south', 'VALIDATION_ERROR')
    }

    if (east <= west && Math.abs(east - west) < 180) {
      throw new SupabaseError('Invalid bounds: east must be greater than west', 'VALIDATION_ERROR')
    }

    // Check latitude bounds
    if (north < -90 || north > 90 || south < -90 || south > 90) {
      throw new SupabaseError('Invalid latitude bounds: must be between -90 and 90', 'VALIDATION_ERROR')
    }

    // Check longitude bounds
    if (east < -180 || east > 180 || west < -180 || west > 180) {
      throw new SupabaseError('Invalid longitude bounds: must be between -180 and 180', 'VALIDATION_ERROR')
    }
  }

  /**
   * Validates radius query parameters
   */
  static validateRadius(lat: number, lng: number, radiusMeters: number): void {
    if (lat < -90 || lat > 90) {
      throw new SupabaseError('Invalid latitude: must be between -90 and 90', 'VALIDATION_ERROR')
    }

    if (lng < -180 || lng > 180) {
      throw new SupabaseError('Invalid longitude: must be between -180 and 180', 'VALIDATION_ERROR')
    }

    if (radiusMeters <= 0 || radiusMeters > 50000) {
      throw new SupabaseError('Invalid radius: must be between 1 and 50000 meters', 'VALIDATION_ERROR')
    }
  }

  /**
   * Transforms database result to Request type
   */
  static transformRequestData(data: any[]): RequestWithDistance[] {
    return data.map(item => ({
      id: item.id,
      user_id: item.user_id,
      title: item.title,
      description: item.description,
      category: item.category,
      subcategory: item.subcategory,
      duration_estimate: item.duration_estimate,
      skills_required: item.skills_required || [],
      compensation: item.compensation,
      images: item.images || [],
      location: item.location,
      status: item.status,
      created_at: item.created_at,
      updated_at: item.updated_at,
      expires_at: item.expires_at,
      distance_meters: item.distance_meters,
      user: item.user_full_name ? {
        id: item.user_id,
        full_name: item.user_full_name,
        avatar_url: item.user_avatar_url,
        email: item.user_email,
      } : undefined
    }))
  }

  /**
   * Get requests within map bounds using PostGIS
   */
  static async getRequestsInBounds(
    bounds: MapBounds,
    options: SpatialQueryOptions = {}
  ): Promise<RequestWithDistance[]> {
    try {
      console.log('Fetching requests in bounds:', bounds, options)

      // Validate bounds
      this.validateBounds(bounds)

      const { category, subcategory, status = 'active', limit = 100 } = options

      // Call PostGIS function with retry logic
      const data = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase.rpc('get_requests_in_bounds', {
            north: bounds.north,
            south: bounds.south,
            east: bounds.east,
            west: bounds.west,
            p_category: category || null,
            p_subcategory: subcategory || null,
            p_status: status,
            p_limit: limit
          }),
          'getRequestsInBounds',
          10000 // 10 second timeout for spatial queries
        )
      }, 2, 1000)

      console.log(`Found ${data?.length || 0} requests in bounds`)

      return this.transformRequestData(data || [])
    } catch (error) {
      console.error('Error fetching requests in bounds:', error)
      
      if (error instanceof SupabaseError) {
        throw error
      }
      
      throw new SupabaseError(
        'Failed to fetch requests in map bounds',
        'SPATIAL_QUERY_ERROR',
        { bounds, options, originalError: error }
      )
    }
  }

  /**
   * Get requests within radius using PostGIS (fallback method)
   */
  static async getRequestsInRadius(
    centerLat: number,
    centerLng: number,
    radiusMeters: number,
    options: SpatialQueryOptions = {}
  ): Promise<RequestWithDistance[]> {
    try {
      console.log('Fetching requests in radius:', { centerLat, centerLng, radiusMeters }, options)

      // Validate parameters
      this.validateRadius(centerLat, centerLng, radiusMeters)

      const { category, subcategory, status = 'active', limit = 100 } = options

      // Call PostGIS function with retry logic
      const data = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase.rpc('get_requests_in_radius', {
            center_lat: centerLat,
            center_lng: centerLng,
            radius_meters: radiusMeters,
            p_category: category || null,
            p_subcategory: subcategory || null,
            p_status: status,
            p_limit: limit
          }),
          'getRequestsInRadius',
          10000 // 10 second timeout for spatial queries
        )
      }, 2, 1000)

      console.log(`Found ${data?.length || 0} requests in radius`)

      return this.transformRequestData(data || [])
    } catch (error) {
      console.error('Error fetching requests in radius:', error)
      
      if (error instanceof SupabaseError) {
        throw error
      }
      
      throw new SupabaseError(
        'Failed to fetch requests in radius',
        'SPATIAL_QUERY_ERROR',
        { centerLat, centerLng, radiusMeters, options, originalError: error }
      )
    }
  }

  /**
   * Convert miles to meters for radius queries
   */
  static milesToMeters(miles: number): number {
    return miles * 1609.34
  }

  /**
   * Convert meters to miles for display
   */
  static metersToMiles(meters: number): number {
    return meters / 1609.34
  }

  /**
   * Calculate bounds from center point and radius
   */
  static calculateBoundsFromRadius(
    centerLat: number,
    centerLng: number,
    radiusMiles: number
  ): MapBounds {
    // Approximate degrees per mile (varies by latitude)
    const latDegreesPerMile = 1 / 69
    const lngDegreesPerMile = 1 / (69 * Math.cos(centerLat * Math.PI / 180))

    const latOffset = radiusMiles * latDegreesPerMile
    const lngOffset = radiusMiles * lngDegreesPerMile

    return {
      north: Math.min(90, centerLat + latOffset),
      south: Math.max(-90, centerLat - latOffset),
      east: centerLng + lngOffset,
      west: centerLng - lngOffset
    }
  }

  /**
   * Check if coordinates are within bounds
   */
  static isPointInBounds(lat: number, lng: number, bounds: MapBounds): boolean {
    const { north, south, east, west } = bounds

    // Check latitude
    if (lat < south || lat > north) {
      return false
    }

    // Check longitude (handle international date line crossing)
    if (west > east) {
      // Bounds cross the international date line
      return lng >= west || lng <= east
    } else {
      // Normal case
      return lng >= west && lng <= east
    }
  }

  /**
   * Validate and fix request geometries (admin function)
   */
  static async validateRequestGeometries(): Promise<any[]> {
    try {
      console.log('Validating request geometries...')

      const data = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase.rpc('validate_request_geometries'),
          'validateRequestGeometries',
          30000 // 30 second timeout for validation
        )
      }, 1) // Don't retry validation

      console.log('Geometry validation completed:', data)
      return data || []
    } catch (error) {
      console.error('Error validating geometries:', error)
      throw new SupabaseError(
        'Failed to validate request geometries',
        'VALIDATION_ERROR',
        { originalError: error }
      )
    }
  }
}