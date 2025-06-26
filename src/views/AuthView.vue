<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div class="text-center">
        <h2 class="mt-6 text-3xl font-bold text-gray-900">Let's get started!</h2>
        <p class="mt-2 text-sm text-gray-600">Sign in or join the Kindr community.</p>
      </div>

      <div>
        <Button
          @click="handleGoogleSignIn"
          class="w-full"
          :disabled="authStore.loading"
          variant="outline"
          icon-left="fa6-brands:google"
        >
          Continue with Google
        </Button>
      </div>

      <div class="flex items-center justify-center">
        <div class="flex items-center">
          <div class="flex-1 border-t border-gray-200" />
          <div class="px-4 text-sm text-gray-500">or</div>
          <div class="flex-1 border-t border-gray-200" />
        </div>
      </div>

      <form class="mt-8 space-y-6" @submit.prevent="handleSubmit">
        <div class="space-y-4">
          <div v-if="isSignUp">
            <label for="fullName" class="block text-sm font-medium text-gray-700">
              Full Name
            </label>
            <input
              id="fullName"
              v-model="form.fullName"
              type="text"
              required
              class="input"
              placeholder="Enter your full name"
            />
          </div>

          <div>
            <label for="email" class="block text-sm font-medium text-gray-700">
              Email address
            </label>
            <input
              id="email"
              v-model="form.email"
              type="email"
              required
              class="input"
              placeholder="Enter your email"
            />
          </div>

          <div>
            <label for="password" class="block text-sm font-medium text-gray-700"> Password </label>
            <input
              id="password"
              v-model="form.password"
              type="password"
              required
              class="input"
              :placeholder="isSignUp ? 'Create a password' : 'Enter your password'"
            />
          </div>
        </div>

        <div v-if="error" class="rounded-md bg-error-50 p-4">
          <div class="text-sm text-error-700">
            {{ error }}
          </div>
        </div>

        <div>
          <Button
            type="submit"
            :loading="authStore.loading"
            :disabled="authStore.loading"
            class="btn btn-primary w-full"
          >
            {{ isSignUp ? 'Create Account' : 'Sign In' }}
          </Button>
        </div>

        <div class="text-center">
          <button
            type="button"
            @click="isSignUp = !isSignUp"
            class="text-sm text-primary-600 hover:text-primary-500"
          >
            {{ isSignUp ? 'Already have an account? Sign in' : 'Need an account? Sign up' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive } from 'vue'
  import { useRouter, useRoute } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'
  import Button from '@/components/widgets/Button.vue'

  const router = useRouter()
  const route = useRoute()
  const authStore = useAuthStore()

  const isSignUp = ref(false)
  const error = ref('')

  const form = reactive({
    fullName: '',
    email: '',
    password: '',
  })

  const handleSubmit = async () => {
    error.value = ''

    try {
      let result
      if (isSignUp.value) {
        result = await authStore.signUp(form.email, form.password, form.fullName)
      } else {
        result = await authStore.signIn(form.email, form.password)
      }

      if (result.error) {
        error.value = result.error
        return
      }

      // Redirect to intended page or home
      const redirect = route.query.redirect as string
      router.push(redirect || { name: 'browse' })
    } catch (err: any) {
      error.value = err.message || 'An error occurred'
    }
  }

  const handleGoogleSignIn = async () => {
    error.value = ''

    try {
      const result = await authStore.signInWithGoogle()
      if (result.error) {
        error.value = result.error
      }
    } catch (err: any) {
      error.value = err.message || 'An error occurred'
    }
  }
</script>
