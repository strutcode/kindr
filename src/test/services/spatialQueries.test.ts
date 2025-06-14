import { describe, it, expect, vi, beforeEach } from 'vitest'
import { SpatialQueryService } from '@/services/spatialQueries'
import type { MapBounds } from '@/services/spatialQueries'

// Mock Supabase
vi.mock('@/lib/supabase', () => ({
  supabase: {
    rpc: vi.fn()
  },
  handleSupabaseResponse: vi.fn(),
  retryOperation: vi.fn()
}))

describe('SpatialQueryService', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('validateBounds', () => {
    it('validates correct bounds', () => {
      const validBounds: MapBounds = {
        north: 40.7128,
        south: 40.7000,
        east: -74.0000,
        west: -74.0200
      }

      expect(() => SpatialQueryService.validateBounds(validBounds)).not.toThrow()
    })

    it('throws error for invalid latitude bounds', () => {
      const invalidBounds: MapBounds = {
        north: 100, // Invalid latitude
        south: 40.7000,
        east: -74.0000,
        west: -74.0200
      }

      expect(() => SpatialQueryService.validateBounds(invalidBounds))
        .toThrow('Invalid latitude bounds')
    })

    it('throws error for invalid longitude bounds', () => {
      const invalidBounds: MapBounds = {
        north: 40.7128,
        south: 40.7000,
        east: 200, // Invalid longitude
        west: -74.0200
      }

      expect(() => SpatialQueryService.validateBounds(invalidBounds))
        .toThrow('Invalid longitude bounds')
    })

    it('throws error when north <= south', () => {
      const invalidBounds: MapBounds = {
        north: 40.7000,
        south: 40.7128, // South greater than north
        east: -74.0000,
        west: -74.0200
      }

      expect(() => SpatialQueryService.validateBounds(invalidBounds))
        .toThrow('Invalid bounds: north must be greater than south')
    })
  })

  describe('validateRadius', () => {
    it('validates correct radius parameters', () => {
      expect(() => SpatialQueryService.validateRadius(40.7128, -74.0060, 1000))
        .not.toThrow()
    })

    it('throws error for invalid latitude', () => {
      expect(() => SpatialQueryService.validateRadius(100, -74.0060, 1000))
        .toThrow('Invalid latitude')
    })

    it('throws error for invalid longitude', () => {
      expect(() => SpatialQueryService.validateRadius(40.7128, 200, 1000))
        .toThrow('Invalid longitude')
    })

    it('throws error for invalid radius', () => {
      expect(() => SpatialQueryService.validateRadius(40.7128, -74.0060, 0))
        .toThrow('Invalid radius')

      expect(() => SpatialQueryService.validateRadius(40.7128, -74.0060, 60000))
        .toThrow('Invalid radius')
    })
  })

  describe('utility functions', () => {
    it('converts miles to meters correctly', () => {
      expect(SpatialQueryService.milesToMeters(1)).toBeCloseTo(1609.34, 2)
      expect(SpatialQueryService.milesToMeters(5)).toBeCloseTo(8046.7, 1)
    })

    it('converts meters to miles correctly', () => {
      expect(SpatialQueryService.metersToMiles(1609.34)).toBeCloseTo(1, 2)
      expect(SpatialQueryService.metersToMiles(8046.7)).toBeCloseTo(5, 1)
    })

    it('calculates bounds from radius correctly', () => {
      const bounds = SpatialQueryService.calculateBoundsFromRadius(40.7128, -74.0060, 1)
      
      expect(bounds.north).toBeGreaterThan(40.7128)
      expect(bounds.south).toBeLessThan(40.7128)
      expect(bounds.east).toBeGreaterThan(-74.0060)
      expect(bounds.west).toBeLessThan(-74.0060)
    })

    it('checks if point is in bounds correctly', () => {
      const bounds: MapBounds = {
        north: 40.8,
        south: 40.7,
        east: -74.0,
        west: -74.1
      }

      expect(SpatialQueryService.isPointInBounds(40.75, -74.05, bounds)).toBe(true)
      expect(SpatialQueryService.isPointInBounds(40.9, -74.05, bounds)).toBe(false)
      expect(SpatialQueryService.isPointInBounds(40.75, -73.9, bounds)).toBe(false)
    })
  })
})