<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center">
    <div class="text-center">
      <Icon
        name="svg-spinners:bars-scale"
        class="w-12 h-12 mx-auto text-secondary-600 animate-spin"
      />
      <p class="mt-4 text-gray-600">Completing sign in...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { onMounted } from 'vue'
  import { useRouter } from 'vue-router'
  import { supabase } from '@/lib/supabase'
  import { useAuthStore } from '@/stores/auth'

  const router = useRouter()
  const authStore = useAuthStore()

  onMounted(async () => {
    try {
      const { data, error } = await supabase.auth.getSession()

      if (error) {
        console.error('Auth callback error:', error)
        router.push('/auth')
        return
      }

      if (data.session) {
        // Check if user profile exists, if not create one
        const { data: profile, error: profileError } = await supabase
          .from('users')
          .select('*')
          .eq('id', data.session.user.id)
          .maybeSingle()

        if (profileError) {
          console.error('Error checking profile:', profileError)
          router.push('/auth')
          return
        }

        if (!profile) {
          // Profile doesn't exist, create one
          const { error: createError } = await supabase.from('users').insert([
            {
              id: data.session.user.id,
              email: data.session.user.email,
              full_name:
                data.session.user.user_metadata.full_name ||
                data.session.user.user_metadata.name ||
                '',
              avatar_url: data.session.user.user_metadata.avatar_url,
            },
          ])

          if (createError) {
            console.error('Error creating profile:', createError)
            router.push('/auth')
            return
          }
        }

        // Ensure the auth store is synchronized with the user profile
        await authStore.fetchUserProfile(data.session.user.id)

        router.push('/requests')
      } else {
        router.push('/auth')
      }
    } catch (error) {
      console.error('Auth callback error:', error)
      router.push('/auth')
    }
  })
</script>
