<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div class="text-center">
        <div class="mx-auto h-12 w-12 bg-primary-600 rounded-lg flex items-center justify-center">
          <span class="text-white font-bold text-lg">K</span>
        </div>
        <h2 class="mt-6 text-3xl font-bold text-gray-900">
          {{ isSignUp ? 'Join Kindr' : 'Welcome back' }}
        </h2>
        <p class="mt-2 text-sm text-gray-600">
          {{ isSignUp ? 'Connect with your neighbors' : 'Sign in to your account' }}
        </p>
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
            <label for="password" class="block text-sm font-medium text-gray-700">
              Password
            </label>
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
          <button
            type="submit"
            :disabled="authStore.loading"
            class="btn btn-primary w-full"
          >
            <LoadingSpinner v-if="authStore.loading" size="sm" />
            {{ isSignUp ? 'Create Account' : 'Sign In' }}
          </button>
        </div>

        <div class="flex items-center justify-center">
          <div class="flex items-center">
            <div class="flex-1 border-t border-gray-200" />
            <div class="px-4 text-sm text-gray-500">or</div>
            <div class="flex-1 border-t border-gray-200" />
          </div>
        </div>

        <div>
          <button
            type="button"
            @click="handleGoogleSignIn"
            :disabled="authStore.loading"
            class="btn btn-outline w-full"
          >
            <svg class="w-5 h-5 mr-2" viewBox="0 0 24 24">
              <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
              <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
              <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            Continue with Google
          </button>
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
import LoadingSpinner from '@/components/common/LoadingSpinner.vue'

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
    router.push(redirect || '/requests')
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