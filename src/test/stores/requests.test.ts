import { describe, it, expect, vi, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useRequestsStore } from '@/stores/requests'
import type { Request } from '@/types'

// Mock Supabase and services
vi.mock('@/lib/supabase', () => ({
  supabase: {
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => ({
          order: vi.fn(() => ({
            limit: vi.fn(() => Promise.resolve({ data: [], error: null }))
          }))
        }))
      })),
      insert: vi.fn(() => ({
        select: vi.fn(() => ({
          single: vi.fn(() => Promise.resolve({ data: mockRequest, error: null }))
        }))
      })),
      update: vi.fn(() => ({
        eq: vi.fn(() => ({
          select: vi.fn(() => ({
            single: vi.fn(() => Promise.resolve({ data: mockRequest, error: null }))
          }))
        }))
      })),
      delete: vi.fn(() => ({
        eq: vi.fn(() => Promise.resolve({ error: null }))
      }))
    }))
  },
  handleSupabaseResponse: vi.fn(),
  retryOperation: vi.fn()
}))

vi.mock('@/services/spatialQueries', () => ({
  SpatialQueryService: {
    getRequestsInBounds: vi.fn(() => Promise.resolve([])),
    getRequestsInRadius: vi.fn(() => Promise.resolve([]))
  }
}))

const mockRequest: Request = {
  id: '123',
  user_id: 'user-123',
  title: 'Test Request',
  description: 'Test description',
  category: 'help-needed',
  subcategory: 'transportation',
  duration_estimate: '1hour',
  skills_required: [],
  location: {
    latitude: 34.0522,
    longitude: -118.2437,
    address: 'Los Angeles, CA'
  },
  status: 'active',
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z'
}

describe('Requests Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    vi.clearAllMocks()
  })

  it('initializes with default state', () => {
    const store = useRequestsStore()
    
    expect(store.requests).toEqual([])
    expect(store.userRequests).toEqual([])
    expect(store.spatialRequests).toEqual([])
    expect(store.loading).toBe(false)
    expect(store.error).toBe('')
  })

  it('filters active requests correctly', () => {
    const store = useRequestsStore()
    
    // Manually set requests for testing
    store.requests.push(
      { ...mockRequest, status: 'active' },
      { ...mockRequest, id: '456', status: 'completed' },
      { ...mockRequest, id: '789', status: 'active' }
    )
    
    expect(store.activeRequests).toHaveLength(2)
    expect(store.activeRequests.every(req => req.status === 'active')).toBe(true)
  })

  it('updates filters correctly', () => {
    const store = useRequestsStore()
    
    store.updateFilters({ category: 'help-needed', radius: 5 })
    
    expect(store.filters.category).toBe('help-needed')
    expect(store.filters.radius).toBe(5)
  })

  it('clears error state', () => {
    const store = useRequestsStore()
    
    store.error = 'Test error'
    store.clearError()
    
    expect(store.error).toBe('')
  })

  it('clears loading state', () => {
    const store = useRequestsStore()
    
    store.loading = true
    store.clearLoading()
    
    expect(store.loading).toBe(false)
  })
})