import { describe, it, expect, vi, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useAuthStore } from '@/stores/auth'

// Mock Supabase
vi.mock('@/lib/supabase', () => ({
  supabase: {
    auth: {
      getSession: vi.fn(),
      onAuthStateChange: vi.fn(),
      signUp: vi.fn(),
      signInWithPassword: vi.fn(),
      signInWithOAuth: vi.fn(),
      signOut: vi.fn(),
    },
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        eq: vi.fn(() => ({
          single: vi.fn(),
        })),
      })),
      insert: vi.fn(),
      update: vi.fn(() => ({
        eq: vi.fn(() => ({
          select: vi.fn(() => ({
            single: vi.fn(),
          })),
        })),
      })),
    })),
  },
}))

describe('Auth Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('initializes with default state', () => {
    const store = useAuthStore()
    
    expect(store.user).toBeNull()
    expect(store.session).toBeNull()
    expect(store.loading).toBe(false)
    expect(store.isAuthenticated).toBe(false)
  })

  it('handles successful sign up', async () => {
    const store = useAuthStore()
    const mockUser = { id: '123', email: 'test@example.com' }
    
    // Mock successful sign up
    const { supabase } = await import('@/lib/supabase')
    vi.mocked(supabase.auth.signUp).mockResolvedValue({
      data: { user: mockUser, session: null },
      error: null,
    })
    vi.mocked(supabase.from).mockReturnValue({
      insert: vi.fn().mockResolvedValue({ error: null }),
    } as any)

    const result = await store.signUp('test@example.com', 'password', 'Test User')
    
    expect(result.error).toBeNull()
    expect(supabase.auth.signUp).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password',
      options: {
        data: {
          full_name: 'Test User',
        }
      }
    })
  })

  it('handles sign up errors', async () => {
    const store = useAuthStore()
    const mockError = new Error('Email already exists')
    
    const { supabase } = await import('@/lib/supabase')
    vi.mocked(supabase.auth.signUp).mockRejectedValue(mockError)

    const result = await store.signUp('test@example.com', 'password', 'Test User')
    
    expect(result.error).toBe('Email already exists')
    expect(result.data).toBeNull()
  })
})