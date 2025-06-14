import { ref, computed } from 'vue'
import { SecurityService } from '@/services/security'
import { useAuthStore } from '@/stores/auth'

/**
 * Composable for security-related functionality
 */
export function useSecurity() {
  const authStore = useAuthStore()
  const csrfToken = ref<string>('')
  const rateLimitExceeded = ref(false)

  // Generate CSRF token on initialization
  const generateCSRFToken = () => {
    csrfToken.value = SecurityService.generateCSRFToken()
    return csrfToken.value
  }

  // Check rate limit for current user
  const checkRateLimit = (maxRequests?: number) => {
    const identifier = authStore.user?.id || 'anonymous'
    const allowed = SecurityService.checkRateLimit(identifier, maxRequests)
    
    if (!allowed) {
      rateLimitExceeded.value = true
      SecurityService.logSecurityEvent('rate_limit_exceeded', {
        userId: authStore.user?.id,
        identifier
      })
    }
    
    return allowed
  }

  // Validate text input with security checks
  const validateInput = (input: string, maxLength?: number) => {
    const result = SecurityService.validateTextInput(input, maxLength)
    
    if (!result.valid) {
      SecurityService.logSecurityEvent('invalid_input', {
        userId: authStore.user?.id,
        errors: result.errors,
        inputLength: input.length
      })
    }
    
    return result
  }

  // Validate email
  const validateEmail = (email: string) => {
    return SecurityService.validateEmail(email)
  }

  // Validate phone
  const validatePhone = (phone: string) => {
    return SecurityService.validatePhone(phone)
  }

  // Validate coordinates
  const validateCoordinates = (lat: number, lng: number) => {
    return SecurityService.validateCoordinates(lat, lng)
  }

  // Check user permissions
  const checkPermission = async (
    action: 'create' | 'read' | 'update' | 'delete',
    resourceType: 'request' | 'review' | 'reputation',
    resourceId?: string
  ) => {
    if (!authStore.user?.id) {
      return { valid: false, message: 'Not authenticated' }
    }
    
    return await SecurityService.validateUserPermission(
      authStore.user.id,
      action,
      resourceType,
      resourceId
    )
  }

  // Computed properties
  const isAuthenticated = computed(() => authStore.isAuthenticated)
  const currentUserId = computed(() => authStore.user?.id)

  // Initialize CSRF token
  generateCSRFToken()

  return {
    // State
    csrfToken: computed(() => csrfToken.value),
    rateLimitExceeded: computed(() => rateLimitExceeded.value),
    isAuthenticated,
    currentUserId,
    
    // Methods
    generateCSRFToken,
    checkRateLimit,
    validateInput,
    validateEmail,
    validatePhone,
    validateCoordinates,
    checkPermission,
    
    // Reset rate limit flag
    resetRateLimit: () => { rateLimitExceeded.value = false }
  }
}