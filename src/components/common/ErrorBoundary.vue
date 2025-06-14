<template>
  <div v-if="hasError" class="error-boundary">
    <div class="bg-error-50 border border-error-200 rounded-lg p-6 m-4">
      <div class="flex items-start">
        <ExclamationTriangleIcon class="w-6 h-6 text-error-600 mt-1 mr-3 flex-shrink-0" />
        <div class="flex-1">
          <h3 class="text-lg font-medium text-error-900 mb-2">
            {{ title || 'Something went wrong' }}
          </h3>
          <p class="text-error-700 mb-4">
            {{ message || 'An unexpected error occurred. Please try again.' }}
          </p>
          
          <!-- Error details (only in development) -->
          <details v-if="showDetails && errorDetails" class="mb-4">
            <summary class="text-sm text-error-600 cursor-pointer hover:text-error-500">
              Show error details
            </summary>
            <pre class="mt-2 text-xs text-error-600 bg-error-100 p-2 rounded overflow-auto max-h-32">{{ errorDetails }}</pre>
          </details>
          
          <div class="flex space-x-3">
            <button 
              @click="retry"
              class="btn btn-primary btn-sm"
            >
              Try Again
            </button>
            <button 
              @click="reset"
              class="btn btn-outline btn-sm"
            >
              Reset
            </button>
            <router-link 
              v-if="showHomeLink"
              to="/" 
              class="btn btn-outline btn-sm"
            >
              Go Home
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
  <slot v-else />
</template>

<script setup lang="ts">
import { ref, onErrorCaptured } from 'vue'
import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'

interface Props {
  title?: string
  message?: string
  showDetails?: boolean
  showHomeLink?: boolean
  onRetry?: () => void | Promise<void>
  onReset?: () => void | Promise<void>
}

interface Emits {
  (e: 'error', error: Error): void
  (e: 'retry'): void
  (e: 'reset'): void
}

const props = withDefaults(defineProps<Props>(), {
  showDetails: import.meta.env.DEV,
  showHomeLink: true,
})

const emit = defineEmits<Emits>()

const hasError = ref(false)
const errorDetails = ref('')

onErrorCaptured((error: Error) => {
  console.error('Error caught by ErrorBoundary:', error)
  
  hasError.value = true
  errorDetails.value = error.stack || error.message
  
  emit('error', error)
  
  // Prevent the error from propagating further
  return false
})

const retry = async () => {
  try {
    if (props.onRetry) {
      await props.onRetry()
    }
    hasError.value = false
    errorDetails.value = ''
    emit('retry')
  } catch (error) {
    console.error('Retry failed:', error)
  }
}

const reset = async () => {
  try {
    if (props.onReset) {
      await props.onReset()
    }
    hasError.value = false
    errorDetails.value = ''
    emit('reset')
  } catch (error) {
    console.error('Reset failed:', error)
  }
}

// Expose methods for parent components
defineExpose({
  hasError: () => hasError.value,
  reset,
  retry,
})
</script>

<style scoped>
.error-boundary {
  min-height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>