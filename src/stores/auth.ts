import { ref, computed, readonly } from 'vue'
import { defineStore } from 'pinia'
import router from '@/router'
import { supabase } from '@/lib/supabase'
import type { User } from '@/types'
import { createLogger } from '@/lib/logger'

const { log, debug, info, warn, error } = createLogger('AuthStore')

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const session = ref<any | null>(null)
  const loading = ref(false)
  const authErr = ref<string>('')
  const initialized = ref(false)

  const isAuthenticated = computed(() => Boolean(session.value && user.value))

  const initialize = async () => {
    if (initialized.value) return

    loading.value = true
    authErr.value = ''

    try {
      info('Initializing auth store...')

      const res = await supabase.auth.getSession()

      if (res.error) {
        user.value = null
        session.value = null
        throw res.error
      }

      const sessionData = res.data
      debug('Session result:', sessionData)
      session.value = sessionData.session

      if (session.value?.user) {
        debug('Getting user profile for:', session.value.user.id)
        await fetchUserProfile(session.value.user.id)
      }

      // supabase.auth.onAuthStateChange(async (event, newSession) => {
      //   debug('Auth state changed:', event, newSession?.user?.id)

      //   if (event === 'SIGNED_IN') {
      //     try {
      //       session.value = newSession
      //       authErr.value = '' // Clear any previous errors on successful auth change
      //     } catch (err) {
      //       error('Error handling auth state change:', err)
      //       authErr.value = err instanceof Error ? err.message : 'Authentication error'
      //     }
      //   }

      //   if (event === 'SIGNED_OUT') {
      //     debug('User signed out, clearing session and user data')
      //     session.value = null
      //     user.value = null
      //     authErr.value = '' // Clear any previous errors on sign out
      //   }
      // })

      initialized.value = true
    } catch (err) {
      error('Error initializing auth:', err)
      authErr.value = err instanceof Error ? err.message : 'Failed to initialize authentication'
    } finally {
      loading.value = false
      initialized.value = true
    }
  }

  const fetchUserProfile = async (userId: string) => {
    try {
      debug('Fetching user profile for:', userId)

      const { data, error: fetchError } = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .maybeSingle()

      if (fetchError) throw new Error(fetchError.message)

      log('User profile data:', data)
      user.value = data

      // Initialize stores when user profile is loaded
      const { useChatStore } = await import('./chat')
      const { useAlertsStore } = await import('./alerts')
      const { useNotificationsStore } = await import('./notifications')

      const chatStore = useChatStore()
      const alertsStore = useAlertsStore()
      const notificationsStore = useNotificationsStore()

      chatStore.initialize()
      alertsStore.initialize()
      notificationsStore.initialize()
    } catch (err) {
      error('Error fetching user profile:', err)

      if (err instanceof Error) {
        warn('User profile not found, user may need to complete profile setup')
      }
    }
  }

  const signUp = async (email: string, password: string, fullName: string) => {
    loading.value = true
    authErr.value = ''

    try {
      const { data: authResult, error: signUpError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName,
          },
        },
      })

      if (signUpError) throw new Error(signUpError.message)

      if (authResult.user) {
        const { error: profileError } = await supabase
          .from('users')
          .insert([
            {
              id: authResult.user.id,
              full_name: fullName,
            },
          ])
          .single()

        if (profileError) throw new Error(profileError.message)

        await fetchUserProfile(authResult.user.id)
      }

      return { data: authResult, error: null }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Sign up failed'
      authErr.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const signIn = async (email: string, password: string) => {
    loading.value = true
    authErr.value = ''

    try {
      const { data: authResult, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (signInError) throw new Error(signInError.message)

      if (authResult.user) {
        await fetchUserProfile(authResult.user.id)
      }
      log('Sign in successful:', authResult)
      session.value = authResult.session || null

      return { data: authResult, error: null }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Sign in failed'
      authErr.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const signInWithGoogle = async () => {
    loading.value = true
    authErr.value = ''

    try {
      const { data: authResult, error: googleError } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/auth/callback`,
        },
      })

      if (googleError) throw new Error(googleError.message)

      return { data: authResult, error: null }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Google sign in failed'
      authErr.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const signOut = async () => {
    loading.value = true
    authErr.value = ''

    try {
      // Cleanup stores before signing out
      const { useChatStore } = await import('./chat')
      const { useAlertsStore } = await import('./alerts')
      const { useNotificationsStore } = await import('./notifications')

      const chatStore = useChatStore()
      const alertsStore = useAlertsStore()
      const notificationsStore = useNotificationsStore()

      chatStore.cleanup()
      alertsStore.cleanup()
      notificationsStore.cleanup()

      const { error: signOutError } = await supabase.auth.signOut()

      if (signOutError) throw new Error(signOutError.message)

      user.value = null
      session.value = null

      log('User signed out successfully')

      // Redirect to main page after sign out
      router.push('/')
    } catch (err) {
      error('Error signing out:', err)
      authErr.value = err instanceof Error ? err.message : 'Sign out failed'

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
      authErr.value = errorMsg
      return { error: errorMsg, data: null }
    }

    loading.value = true
    authErr.value = ''

    try {
      const { data: existingProfile, error: profileError } = await supabase
        .from('users')
        .select('*')
        .eq('id', currentUser.id)
        .maybeSingle()

      if (profileError) throw new Error(profileError.message)

      let result
      if (existingProfile) {
        const { data, error: updateError } = await supabase
          .from('users')
          .update({
            ...updates,
            updated_at: new Date().toISOString(),
          })
          .eq('id', currentUser.id)
          .select()
          .single()

        if (updateError) throw new Error(updateError.message)

        result = data
      } else {
        const { data, error: createError } = await supabase
          .from('users')
          .insert([
            {
              id: currentUser.id,
              email: currentUser.email || session.value?.user?.email,
              ...updates,
            },
          ])
          .select()
          .single()

        if (createError) throw new Error(createError.message)

        result = data
      }

      user.value = result
      return { data: result, error: null }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to update profile'
      authErr.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  // Method to clear errors
  const clearError = () => {
    authErr.value = ''
  }

  return {
    user: readonly(user),
    session: readonly(session),
    loading: readonly(loading),
    error: readonly(authErr),
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
  }
})
