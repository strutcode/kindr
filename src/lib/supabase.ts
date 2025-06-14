import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

// Enhanced Supabase client configuration with better error handling and timeouts
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    // Auto refresh tokens before they expire
    autoRefreshToken: true,
    // Persist session in localStorage
    persistSession: true,
    // Detect session from URL on mount
    detectSessionInUrl: true,
    // Storage key for session
    storageKey: 'kindr-auth-token',
    // Custom storage implementation with error handling
    storage: {
      getItem: (key: string) => {
        try {
          return localStorage.getItem(key)
        } catch (error) {
          console.warn('Failed to get item from localStorage:', error)
          return null
        }
      },
      setItem: (key: string, value: string) => {
        try {
          localStorage.setItem(key, value)
        } catch (error) {
          console.warn('Failed to set item in localStorage:', error)
        }
      },
      removeItem: (key: string) => {
        try {
          localStorage.removeItem(key)
        } catch (error) {
          console.warn('Failed to remove item from localStorage:', error)
        }
      },
    },
  },
  global: {
    headers: {
      'X-Client-Info': 'kindr-web-app',
    },
  },
  // Add realtime configuration
  realtime: {
    params: {
      eventsPerSecond: 10,
    },
  },
})

// Enhanced error handling wrapper for Supabase operations
export class SupabaseError extends Error {
  constructor(
    message: string,
    public code?: string,
    public details?: any,
    public hint?: string
  ) {
    super(message)
    this.name = 'SupabaseError'
  }
}

// Utility function to handle Supabase responses with proper error handling
export async function handleSupabaseResponse<T>(
  operation: () => Promise<{ data: T | null; error: any }>,
  operationName: string,
  timeout: number = 10000
): Promise<T> {
  const timeoutPromise = new Promise<never>((_, reject) => {
    setTimeout(() => {
      reject(new SupabaseError(
        `Operation '${operationName}' timed out after ${timeout}ms`,
        'TIMEOUT',
        { timeout, operationName }
      ))
    }, timeout)
  })

  try {
    const result = await Promise.race([operation(), timeoutPromise])
    
    if (result.error) {
      // Enhanced error handling with specific error types
      const errorMessage = result.error.message || 'Unknown database error'
      const errorCode = result.error.code || 'UNKNOWN_ERROR'
      const errorDetails = result.error.details || result.error
      const errorHint = result.error.hint

      // Log detailed error information for debugging
      console.error(`Supabase ${operationName} error:`, {
        message: errorMessage,
        code: errorCode,
        details: errorDetails,
        hint: errorHint,
        operation: operationName,
      })

      // Throw enhanced error
      throw new SupabaseError(errorMessage, errorCode, errorDetails, errorHint)
    }

    if (result.data === null && operationName.includes('single')) {
      throw new SupabaseError(
        `No data found for ${operationName}`,
        'NOT_FOUND',
        { operationName }
      )
    }

    return result.data as T
  } catch (error) {
    if (error instanceof SupabaseError) {
      throw error
    }

    // Handle network and other errors
    if (error instanceof TypeError && error.message.includes('fetch')) {
      throw new SupabaseError(
        'Network error: Unable to connect to the server. Please check your internet connection.',
        'NETWORK_ERROR',
        { originalError: error, operationName }
      )
    }

    // Handle timeout errors
    if (error instanceof Error && error.message.includes('timed out')) {
      throw new SupabaseError(
        `Operation timed out: ${operationName}`,
        'TIMEOUT',
        { originalError: error, operationName }
      )
    }

    // Handle authentication errors
    if (error instanceof Error && error.message.includes('JWT')) {
      throw new SupabaseError(
        'Authentication error: Please sign in again.',
        'AUTH_ERROR',
        { originalError: error, operationName }
      )
    }

    // Generic error handling
    throw new SupabaseError(
      error instanceof Error ? error.message : 'Unknown error occurred',
      'UNKNOWN_ERROR',
      { originalError: error, operationName }
    )
  }
}

// Utility function to check if user is authenticated with timeout
export async function checkAuthStatus(timeout: number = 5000): Promise<boolean> {
  try {
    const result = await handleSupabaseResponse(
      () => supabase.auth.getSession(),
      'checkAuthStatus',
      timeout
    )
    return !!result.session
  } catch (error) {
    console.warn('Auth status check failed:', error)
    return false
  }
}

// Utility function to retry operations with exponential backoff
export async function retryOperation<T>(
  operation: () => Promise<T>,
  maxRetries: number = 3,
  baseDelay: number = 1000
): Promise<T> {
  let lastError: Error

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await operation()
    } catch (error) {
      lastError = error as Error
      
      // Don't retry certain types of errors
      if (error instanceof SupabaseError) {
        if (['AUTH_ERROR', 'NOT_FOUND', 'VALIDATION_ERROR'].includes(error.code || '')) {
          throw error
        }
      }

      if (attempt === maxRetries) {
        break
      }

      // Exponential backoff with jitter
      const delay = baseDelay * Math.pow(2, attempt - 1) + Math.random() * 1000
      console.warn(`Operation failed (attempt ${attempt}/${maxRetries}), retrying in ${delay}ms:`, error)
      
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }

  throw lastError
}

// Connection health check
export async function checkConnection(): Promise<boolean> {
  try {
    await handleSupabaseResponse(
      () => supabase.from('users').select('id').limit(1),
      'connectionCheck',
      5000
    )
    return true
  } catch (error) {
    console.warn('Connection check failed:', error)
    return false
  }
}