import { defineStore } from 'pinia'
import { ref, computed, readonly } from 'vue'
import { supabase, handleSupabaseResponse, SupabaseError, retryOperation, checkAuthStatus } from '@/lib/supabase'
import type { User, AuthState } from '@/types'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const session = ref<any | null>(null)
  const loading = ref(false)
  const error = ref<string>('')
  const initialized = ref(false)

  const isAuthenticated = computed(() => !!session.value && !!user.value)

  const initialize = async () => {
    if (initialized.value) return

    loading.value = true
    error.value = ''
    
    try {
      console.log('Initializing auth store...')
      
      // Get current session with timeout and retry
      const sessionResult = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase.auth.getSession(),
          'getSession',
          8000 // 8 second timeout for initial load
        )
      }, 2, 1000)

      console.log('Session result:', sessionResult)
      session.value = sessionResult.session
      
      if (sessionResult.session?.user) {
        await fetchUserProfile(sessionResult.session.user.id)
      }

      // Listen for auth changes with error handling
      supabase.auth.onAuthStateChange(async (event, newSession) => {
        console.log('Auth state changed:', event, newSession?.user?.id)
        
        try {
          session.value = newSession
          if (newSession?.user) {
            await fetchUserProfile(newSession.user.id)
          } else {
            user.value = null
          }
          error.value = '' // Clear any previous errors on successful auth change
        } catch (err) {
          console.error('Error handling auth state change:', err)
          error.value = err instanceof Error ? err.message : 'Authentication error'
        }
      })

      initialized.value = true
    } catch (err) {
      console.error('Error initializing auth:', err)
      error.value = err instanceof SupabaseError ? err.message : 'Failed to initialize authentication'
      
      // Set initialized to true even on error to prevent infinite retries
      initialized.value = true
    } finally {
      loading.value = false
    }
  }

  const fetchUserProfile = async (userId: string) => {
    try {
      console.log('Fetching user profile for:', userId)
      
      const userData = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase
            .from('users')
            .select('*')
            .eq('id', userId)
            .maybeSingle(),
          'fetchUserProfile',
          5000
        )
      }, 2, 500)

      console.log('User profile data:', userData)
      user.value = userData
    } catch (err) {
      console.error('Error fetching user profile:', err)
      // Don't throw here - we want to allow the user to be authenticated even if profile fetch fails
      if (err instanceof SupabaseError && err.code === 'NOT_FOUND') {
        console.warn('User profile not found, user may need to complete profile setup')
      }
    }
  }

  const signUp = async (email: string, password: string, fullName: string) => {
    loading.value = true
    error.value = ''
    
    try {
      const authResult = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase.auth.signUp({
            email,
            password,
            options: {
              data: {
                full_name: fullName,
              }
            }
          }),
          'signUp',
          10000
        )
      }, 1) // Don't retry signup to avoid duplicate accounts

      if (authResult.user) {
        // Create user profile with retry
        await retryOperation(async () => {
          await handleSupabaseResponse(
            () => supabase
              .from('users')
              .insert([{
                id: authResult.user!.id,
                email: authResult.user!.email!,
                full_name: fullName,
                notification_radius: 2,
              }]),
            'createUserProfile',
            5000
          )
        }, 2, 1000)
      }

      return { data: authResult, error: null }
    } catch (err) {
      const errorMessage = err instanceof SupabaseError ? err.message : 'Sign up failed'
      error.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const signIn = async (email: string, password: string) => {
    loading.value = true
    error.value = ''
    
    try {
      const authResult = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase.auth.signInWithPassword({
            email,
            password,
          }),
          'signIn',
          8000
        )
      }, 2, 1000)

      return { data: authResult, error: null }
    } catch (err) {
      const errorMessage = err instanceof SupabaseError ? err.message : 'Sign in failed'
      error.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const signInWithGoogle = async () => {
    loading.value = true
    error.value = ''
    
    try {
      const authResult = await handleSupabaseResponse(
        () => supabase.auth.signInWithOAuth({
          provider: 'google',
          options: {
            redirectTo: `${window.location.origin}/auth/callback`
          }
        }),
        'signInWithGoogle',
        5000
      )

      return { data: authResult, error: null }
    } catch (err) {
      const errorMessage = err instanceof SupabaseError ? err.message : 'Google sign in failed'
      error.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const signOut = async () => {
    loading.value = true
    error.value = ''
    
    try {
      await retryOperation(async () => {
        await handleSupabaseResponse(
          () => supabase.auth.signOut(),
          'signOut',
          5000
        )
      }, 2, 500)
      
      user.value = null
      session.value = null
    } catch (err) {
      console.error('Error signing out:', err)
      error.value = err instanceof SupabaseError ? err.message : 'Sign out failed'
      
      // Force clear local state even if API call fails
      user.value = null
      session.value = null
    } finally {
      loading.value = false
    }
  }

  const updateProfile = async (updates: Partial<User>) => {
    const currentUser = user.value || session.value?.user
    if (!currentUser) {
      const errorMsg = 'No authenticated user found'
      error.value = errorMsg
      return { error: errorMsg, data: null }
    }
    
    loading.value = true
    error.value = ''
    
    try {
      // Check if profile exists first
      const existingProfile = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase
            .from('users')
            .select('*')
            .eq('id', currentUser.id)
            .maybeSingle(),
          'checkExistingProfile',
          5000
        )
      }, 2, 500)

      let result
      if (existingProfile) {
        // Update existing profile
        result = await retryOperation(async () => {
          return await handleSupabaseResponse(
            () => supabase
              .from('users')
              .update({
                ...updates,
                updated_at: new Date().toISOString(),
              })
              .eq('id', currentUser.id)
              .select()
              .single(),
            'updateProfile',
            5000
          )
        }, 2, 1000)
      } else {
        // Create new profile
        result = await retryOperation(async () => {
          return await handleSupabaseResponse(
            () => supabase
              .from('users')
              .insert([{
                id: currentUser.id,
                email: currentUser.email || session.value?.user?.email,
                notification_radius: 2,
                ...updates,
              }])
              .select()
              .single(),
            'createProfile',
            5000
          )
        }, 2, 1000)
      }
      
      user.value = result
      return { data: result, error: null }
    } catch (err) {
      const errorMessage = err instanceof SupabaseError ? err.message : 'Failed to update profile'
      error.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  // Method to clear errors
  const clearError = () => {
    error.value = ''
  }

  // Method to check if session is still valid
  const validateSession = async (): Promise<boolean> => {
    try {
      return await checkAuthStatus(3000)
    } catch {
      return false
    }
  }

  return {
    user: readonly(user),
    session: readonly(session),
    loading: readonly(loading),
    error: readonly(error),
    initialized: readonly(initialized),
    isAuthenticated,
    initialize,
    signUp,
    signIn,
    signInWithGoogle,
    signOut,
    updateProfile,
    fetchUserProfile,
    clearError,
    validateSession,
  }
})