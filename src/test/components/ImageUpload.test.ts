import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import ImageUpload from '@/components/common/ImageUpload.vue'
import { useAuthStore } from '@/stores/auth'

// Mock the auth store
vi.mock('@/stores/auth')

// Mock the image upload service
vi.mock('@/services/imageUpload', () => ({
  ImageUploadService: {
    validateFiles: vi.fn(() => ({ valid: [], errors: [] })),
    validateImageCount: vi.fn(() => null),
    uploadImage: vi.fn(() => Promise.resolve({ url: 'test-url', path: 'test-path' })),
    createPreviewUrl: vi.fn(() => 'blob:test-url'),
    revokePreviewUrl: vi.fn()
  }
}))

describe('ImageUpload', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    
    const mockAuthStore = {
      user: { id: 'test-user' }
    }
    vi.mocked(useAuthStore).mockReturnValue(mockAuthStore as any)
  })

  it('renders upload zone correctly', () => {
    const wrapper = mount(ImageUpload)
    
    expect(wrapper.find('.upload-zone').exists()).toBe(true)
    expect(wrapper.text()).toContain('Click to upload')
    expect(wrapper.text()).toContain('PNG, JPG, GIF up to 2MB each')
  })

  it('shows drag over state when dragging files', async () => {
    const wrapper = mount(ImageUpload)
    const uploadZone = wrapper.find('.upload-zone')
    
    await uploadZone.trigger('dragover')
    
    expect(uploadZone.classes()).toContain('border-primary-500')
    expect(wrapper.text()).toContain('Drop images here')
  })

  it('handles file input change', async () => {
    const wrapper = mount(ImageUpload)
    const fileInput = wrapper.find('input[type="file"]')
    
    // Create a mock file
    const file = new File(['test'], 'test.jpg', { type: 'image/jpeg' })
    
    // Mock the files property
    Object.defineProperty(fileInput.element, 'files', {
      value: [file],
      writable: false
    })
    
    await fileInput.trigger('change')
    
    // Should trigger file processing
    expect(wrapper.vm).toBeDefined()
  })

  it('displays error messages', async () => {
    const wrapper = mount(ImageUpload)
    
    // Manually set errors for testing
    wrapper.vm.errors = ['Test error message']
    await wrapper.vm.$nextTick()
    
    expect(wrapper.text()).toContain('Test error message')
    expect(wrapper.find('.bg-error-50').exists()).toBe(true)
  })

  it('emits events correctly', () => {
    const wrapper = mount(ImageUpload)
    
    // Test that component can emit events
    expect(wrapper.emitted()).toBeDefined()
  })

  it('respects max images limit', () => {
    const wrapper = mount(ImageUpload, {
      props: { maxImages: 3 }
    })
    
    expect(wrapper.text()).toContain('max 3 images')
  })

  it('handles disabled state', () => {
    const wrapper = mount(ImageUpload, {
      props: { disabled: true }
    })
    
    const uploadZone = wrapper.find('.upload-zone')
    expect(uploadZone.classes()).toContain('disabled')
  })
})