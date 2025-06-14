import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import RequestCard from '@/components/requests/RequestCard.vue'
import { useAuthStore } from '@/stores/auth'
import type { Request } from '@/types'

// Mock the auth store
vi.mock('@/stores/auth')

const mockRequest: Request = {
  id: '123',
  user_id: 'user-123',
  title: 'Test Request',
  description: 'This is a test request',
  category: 'help-needed',
  subcategory: 'transportation',
  duration_estimate: '1hour',
  skills_required: ['driving'],
  compensation: '$20',
  images: [],
  location: {
    latitude: 34.0522,
    longitude: -118.2437,
    address: 'Los Angeles, CA'
  },
  status: 'active',
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
  user: {
    id: 'user-123',
    full_name: 'John Doe',
    email: 'john@example.com'
  }
}

describe('RequestCard', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('renders request information correctly', () => {
    const wrapper = mount(RequestCard, {
      props: { request: mockRequest }
    })

    expect(wrapper.text()).toContain('Test Request')
    expect(wrapper.text()).toContain('This is a test request')
    expect(wrapper.text()).toContain('Help Needed')
    expect(wrapper.text()).toContain('Transportation')
    expect(wrapper.text()).toContain('$20')
  })

  it('shows edit and delete buttons for request owner', () => {
    const mockAuthStore = {
      isAuthenticated: true,
      user: { id: 'user-123' }
    }
    vi.mocked(useAuthStore).mockReturnValue(mockAuthStore as any)

    const wrapper = mount(RequestCard, {
      props: { request: mockRequest }
    })

    expect(wrapper.find('button:contains("Edit")').exists()).toBe(true)
    expect(wrapper.find('button:contains("Delete")').exists()).toBe(true)
  })

  it('shows respond button for other users', () => {
    const mockAuthStore = {
      isAuthenticated: true,
      user: { id: 'different-user' }
    }
    vi.mocked(useAuthStore).mockReturnValue(mockAuthStore as any)

    const wrapper = mount(RequestCard, {
      props: { request: mockRequest }
    })

    expect(wrapper.find('button:contains("Respond")').exists()).toBe(true)
  })

  it('emits events when buttons are clicked', async () => {
    const mockAuthStore = {
      isAuthenticated: true,
      user: { id: 'user-123' }
    }
    vi.mocked(useAuthStore).mockReturnValue(mockAuthStore as any)

    const wrapper = mount(RequestCard, {
      props: { request: mockRequest }
    })

    await wrapper.find('button:contains("Edit")').trigger('click')
    expect(wrapper.emitted('edit')).toBeTruthy()

    await wrapper.find('button:contains("Delete")').trigger('click')
    expect(wrapper.emitted('delete')).toBeTruthy()
  })
})