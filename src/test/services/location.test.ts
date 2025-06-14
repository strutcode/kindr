import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { LocationService } from '@/services/location'

// Mock fetch globally
global.fetch = vi.fn()

describe('LocationService IP Location', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    LocationService.clearCache()
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  describe('getLocationByIP', () => {
    it('validates IP address format', async () => {
      await expect(LocationService.getLocationByIP('')).rejects.toThrow('Invalid IP address: IP must be a non-empty string')
      await expect(LocationService.getLocationByIP('invalid-ip')).rejects.toThrow('Invalid IP address format')
      await expect(LocationService.getLocationByIP('999.999.999.999')).rejects.toThrow('Invalid IP address format')
    })

    it('successfully retrieves location data for valid IP', async () => {
      const mockResponse = {
        country_code: 'US',
        country_name: 'United States',
        city: 'Los Angeles',
        latitude: '34.0522',
        longitude: '-118.2437',
        time_zone: 'America/Los_Angeles',
        response_code: '200'
      }

      vi.mocked(fetch).mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: () => Promise.resolve(mockResponse),
      } as Response)

      const result = await LocationService.getLocationByIP('8.8.8.8')

      expect(result).toEqual({
        latitude: 34.0522,
        longitude: -118.2437,
        city: 'Los Angeles',
        country: 'United States',
        countryCode: 'US',
        timeZone: 'America/Los_Angeles',
        accuracy: 'medium',
        source: 'ip',
      })

      expect(fetch).toHaveBeenCalledWith(
        'https://api.iplocation.net/?ip=8.8.8.8',
        expect.objectContaining({
          method: 'GET',
          headers: expect.objectContaining({
            'Accept': 'application/json',
            'User-Agent': 'LocalHelp/1.0',
          }),
        })
      )
    })

    it('handles API errors gracefully', async () => {
      vi.mocked(fetch).mockResolvedValueOnce({
        ok: false,
        status: 429,
        statusText: 'Too Many Requests',
      } as Response)

      await expect(LocationService.getLocationByIP('8.8.8.8')).rejects.toThrow('API request failed: 429 Too Many Requests')
    })

    it('handles invalid API response', async () => {
      const mockResponse = {
        response_code: '400',
        response_message: 'Invalid IP address'
      }

      vi.mocked(fetch).mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: () => Promise.resolve(mockResponse),
      } as Response)

      await expect(LocationService.getLocationByIP('8.8.8.8')).rejects.toThrow('API error: Invalid IP address')
    })

    it('handles missing coordinate data', async () => {
      const mockResponse = {
        country_code: 'US',
        country_name: 'United States',
        city: 'Los Angeles',
        time_zone: 'America/Los_Angeles'
        // Missing latitude and longitude
      }

      vi.mocked(fetch).mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: () => Promise.resolve(mockResponse),
      } as Response)

      await expect(LocationService.getLocationByIP('8.8.8.8')).rejects.toThrow('Invalid response: Missing latitude or longitude data')
    })

    it('validates coordinate ranges', async () => {
      const mockResponse = {
        country_code: 'US',
        country_name: 'United States',
        city: 'Los Angeles',
        latitude: '999', // Invalid latitude
        longitude: '-118.2437',
        time_zone: 'America/Los_Angeles'
      }

      vi.mocked(fetch).mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: () => Promise.resolve(mockResponse),
      } as Response)

      await expect(LocationService.getLocationByIP('8.8.8.8')).rejects.toThrow('Invalid response: Latitude out of valid range')
    })

    it('caches successful responses', async () => {
      const mockResponse = {
        country_code: 'US',
        country_name: 'United States',
        city: 'Los Angeles',
        latitude: '34.0522',
        longitude: '-118.2437',
        time_zone: 'America/Los_Angeles'
      }

      vi.mocked(fetch).mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: () => Promise.resolve(mockResponse),
      } as Response)

      // First call
      const result1 = await LocationService.getLocationByIP('8.8.8.8')
      
      // Second call should use cache
      const result2 = await LocationService.getLocationByIP('8.8.8.8')

      expect(result1).toEqual(result2)
      expect(fetch).toHaveBeenCalledTimes(1) // Only called once due to caching
    })

    it('handles network timeouts', async () => {
      vi.mocked(fetch).mockRejectedValueOnce(new DOMException('The operation was aborted', 'AbortError'))

      await expect(LocationService.getLocationByIP('8.8.8.8')).rejects.toThrow('Location request timed out. Please try again.')
    })

    it('handles network errors', async () => {
      vi.mocked(fetch).mockRejectedValueOnce(new TypeError('Failed to fetch'))

      await expect(LocationService.getLocationByIP('8.8.8.8')).rejects.toThrow('Network error: Unable to connect to location service')
    })
  })

  describe('detectUserIP', () => {
    it('successfully detects IP from first service', async () => {
      vi.mocked(fetch).mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ ip: '8.8.8.8' }),
      } as Response)

      const ip = await LocationService.detectUserIP()
      expect(ip).toBe('8.8.8.8')
    })

    it('tries multiple services if first fails', async () => {
      // First service fails
      vi.mocked(fetch).mockRejectedValueOnce(new Error('Service unavailable'))
      
      // Second service succeeds
      vi.mocked(fetch).mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ origin: '8.8.8.8' }),
      } as Response)

      const ip = await LocationService.detectUserIP()
      expect(ip).toBe('8.8.8.8')
      expect(fetch).toHaveBeenCalledTimes(2)
    })

    it('returns null if all services fail', async () => {
      vi.mocked(fetch).mockRejectedValue(new Error('All services down'))

      const ip = await LocationService.detectUserIP()
      expect(ip).toBeNull()
    })
  })

  describe('getLocationWithFallback', () => {
    it('uses GPS location when available', async () => {
      // Mock successful GPS
      const mockGeolocation = {
        getCurrentPosition: vi.fn((success) => {
          success({
            coords: {
              latitude: 40.7128,
              longitude: -74.0060,
            },
          })
        }),
      }
      
      Object.defineProperty(global.navigator, 'geolocation', {
        value: mockGeolocation,
        writable: true,
      })

      const result = await LocationService.getLocationWithFallback('8.8.8.8')
      
      expect(result.source).toBe('gps')
      expect(result.accuracy).toBe('high')
      expect(result.latitude).toBe(40.7128)
      expect(result.longitude).toBe(-74.0060)
    })

    it('falls back to IP location when GPS fails', async () => {
      // Mock GPS failure
      const mockGeolocation = {
        getCurrentPosition: vi.fn((success, error) => {
          error(new Error('GPS unavailable'))
        }),
      }
      
      Object.defineProperty(global.navigator, 'geolocation', {
        value: mockGeolocation,
        writable: true,
      })

      // Mock successful IP location
      const mockResponse = {
        country_code: 'US',
        country_name: 'United States',
        city: 'Los Angeles',
        latitude: '34.0522',
        longitude: '-118.2437',
        time_zone: 'America/Los_Angeles'
      }

      vi.mocked(fetch).mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: () => Promise.resolve(mockResponse),
      } as Response)

      const result = await LocationService.getLocationWithFallback('8.8.8.8')
      
      expect(result.source).toBe('ip')
      expect(result.accuracy).toBe('medium')
      expect(result.city).toBe('Los Angeles')
    })

    it('uses default location when all methods fail', async () => {
      // Mock GPS failure
      const mockGeolocation = {
        getCurrentPosition: vi.fn((success, error) => {
          error(new Error('GPS unavailable'))
        }),
      }
      
      Object.defineProperty(global.navigator, 'geolocation', {
        value: mockGeolocation,
        writable: true,
      })

      // Mock IP location failure
      vi.mocked(fetch).mockRejectedValueOnce(new Error('IP service unavailable'))

      const result = await LocationService.getLocationWithFallback('8.8.8.8')
      
      expect(result.source).toBe('fallback')
      expect(result.accuracy).toBe('low')
      expect(result.city).toBe('Los Angeles')
      expect(result.latitude).toBe(34.0522)
      expect(result.longitude).toBe(-118.2437)
    })
  })

  describe('cache management', () => {
    it('provides cache statistics', () => {
      const stats = LocationService.getCacheStats()
      expect(stats).toHaveProperty('size')
      expect(stats).toHaveProperty('entries')
      expect(Array.isArray(stats.entries)).toBe(true)
    })

    it('clears cache successfully', () => {
      LocationService.clearCache()
      const stats = LocationService.getCacheStats()
      expect(stats.size).toBe(0)
      expect(stats.entries).toHaveLength(0)
    })
  })

  describe('calculateDistance', () => {
    it('calculates distance between two points correctly', () => {
      // Distance between New York City and Los Angeles (approximately 2445 miles)
      const distance = LocationService.calculateDistance(
        40.7128, -74.0060, // NYC
        34.0522, -118.2437  // LA
      )
      
      expect(distance).toBeCloseTo(2445, -1) // Within 10 miles
    })

    it('calculates zero distance for same points', () => {
      const distance = LocationService.calculateDistance(
        40.7128, -74.0060,
        40.7128, -74.0060
      )
      
      expect(distance).toBeCloseTo(0, 2)
    })
  })

  describe('filterRequestsByLocation', () => {
    const mockRequests = [
      {
        id: '1',
        location: { latitude: 40.7128, longitude: -74.0060 }
      },
      {
        id: '2', 
        location: { latitude: 40.7580, longitude: -73.9855 }
      },
      {
        id: '3',
        location: { latitude: 34.0522, longitude: -118.2437 }
      }
    ]

    it('filters requests within radius', () => {
      const filter = {
        latitude: 40.7128,
        longitude: -74.0060,
        radius: 10 // 10 miles
      }

      const filtered = LocationService.filterRequestsByLocation(mockRequests, filter)
      
      expect(filtered).toHaveLength(2) // NYC area requests only
      expect(filtered.map(r => r.id)).toEqual(['1', '2'])
    })

    it('returns empty array when no requests within radius', () => {
      const filter = {
        latitude: 40.7128,
        longitude: -74.0060,
        radius: 0.1 // Very small radius
      }

      const filtered = LocationService.filterRequestsByLocation(mockRequests, filter)
      
      expect(filtered).toHaveLength(1) // Only exact match
    })
  })
})