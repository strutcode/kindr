import { ref, computed } from 'vue'
import { SupabaseError } from '@/lib/supabase'

interface ErrorState {
  message: string
  code?: string
  details?: any
  timestamp: Date
  retryable: boolean
}

/**
 * Composable for centralized error handling
 */
export function useErrorHandler() {
  const errors = ref<ErrorState[]>([])
  const isOnline = ref(navigator.onLine)
  
  // Listen for online/offline events
  const handleOnline = () => { isOnline.value = true }
  const handleOffline = () => { isOnline.value = false }
  
  window.addEventListener('online', handleOnline)
  window.addEventListener('offline', handleOffline)
  
  // Add error
  const addError = (error: Error | SupabaseError | string, retryable = false) => {
    let errorState: ErrorState
    
    if (typeof error === 'string') {
      errorState = {
        message: error,
        timestamp: new Date(),
        retryable
      }
    } else if (error instanceof SupabaseError) {
      errorState = {
        message: error.message,
        code: error.code,
        details: error.details,
        timestamp: new Date(),
        retryable: ['NETWORK_ERROR', 'TIMEOUT'].includes(error.code || '')
      }
    } else {
      errorState = {
        message: error.message || 'An unknown error occurred',
        timestamp: new Date(),
        retryable: error.name === 'NetworkError' || error.message.includes('fetch')
      }
    }
    
    errors.value.unshift(errorState)
    
    // Keep only last 10 errors
    if (errors.value.length > 10) {
      errors.value = errors.value.slice(0, 10)
    }
    
    // Log error for debugging
    console.error('Error handled:', errorState)
  }
  
  // Clear specific error
  const clearError = (index: number) => {
    errors.value.splice(index, 1)
  }
  
  // Clear all errors
  const clearAllErrors = () => {
    errors.value = []
  }
  
  // Get user-friendly error message
  const getUserFriendlyMessage = (error: ErrorState): string => {
    if (!isOnline.value) {
      return 'You appear to be offline. Please check your internet connection.'
    }
    
    switch (error.code) {
      case 'NETWORK_ERROR':
        return 'Network connection problem. Please try again.'
      case 'TIMEOUT':
        return 'Request timed out. Please try again.'
      case 'AUTH_ERROR':
        return 'Authentication failed. Please sign in again.'
      case 'NOT_FOUND':
        return 'The requested item was not found.'
      case 'VALIDATION_ERROR':
        return 'Please check your input and try again.'
      case 'RATE_LIMIT_EXCEEDED':
        return 'Too many requests. Please wait a moment and try again.'
      default:
        return error.message || 'Something went wrong. Please try again.'
    }
  }
  
  // Computed properties
  const hasErrors = computed(() => errors.value.length > 0)
  const latestError = computed(() => errors.value[0] || null)
  const retryableErrors = computed(() => errors.value.filter(e => e.retryable))
  
  // Cleanup
  const cleanup = () => {
    window.removeEventListener('online', handleOnline)
    window.removeEventListener('offline', handleOffline)
  }
  
  return {
    // State
    errors: computed(() => errors.value),
    hasErrors,
    latestError,
    retryableErrors,
    isOnline: computed(() => isOnline.value),
    
    // Methods
    addError,
    clearError,
    clearAllErrors,
    getUserFriendlyMessage,
    cleanup
  }
}