<template>
  <Teleport to="body">
    <div class="error-toast-container">
      <TransitionGroup
        name="toast"
        tag="div"
        class="fixed top-4 right-4 z-50 space-y-2"
      >
        <div
          v-for="(error, index) in visibleErrors"
          :key="`error-${error.timestamp.getTime()}`"
          class="error-toast"
          :class="getToastClass(error)"
        >
          <div class="flex items-start">
            <div class="flex-shrink-0">
              <ExclamationTriangleIcon 
                v-if="error.code === 'VALIDATION_ERROR'"
                class="w-5 h-5 text-warning-600" 
              />
              <XCircleIcon 
                v-else-if="!error.retryable"
                class="w-5 h-5 text-error-600" 
              />
              <ExclamationCircleIcon 
                v-else
                class="w-5 h-5 text-warning-600" 
              />
            </div>
            
            <div class="ml-3 flex-1">
              <p class="text-sm font-medium text-gray-900">
                {{ getUserFriendlyMessage(error) }}
              </p>
              
              <div v-if="error.retryable" class="mt-2 flex space-x-2">
                <button
                  @click="$emit('retry', error)"
                  class="text-xs bg-white text-gray-700 border border-gray-300 rounded px-2 py-1 hover:bg-gray-50"
                >
                  Retry
                </button>
                <button
                  @click="dismissError(index)"
                  class="text-xs text-gray-500 hover:text-gray-700"
                >
                  Dismiss
                </button>
              </div>
            </div>
            
            <div class="ml-4 flex-shrink-0">
              <button
                @click="dismissError(index)"
                class="text-gray-400 hover:text-gray-600"
              >
                <XMarkIcon class="w-4 h-4" />
              </button>
            </div>
          </div>
          
          <!-- Auto-dismiss progress bar -->
          <div
            v-if="autoDismiss && !error.retryable"
            class="absolute bottom-0 left-0 h-1 bg-gray-300 transition-all duration-300 ease-linear"
            :style="{ width: `${getProgressWidth(error)}%` }"
          />
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted } from 'vue'
import {
  ExclamationTriangleIcon,
  XCircleIcon,
  ExclamationCircleIcon,
  XMarkIcon
} from '@heroicons/vue/24/outline'
import { useErrorHandler } from '@/composables/useErrorHandler'

interface Props {
  maxVisible?: number
  autoDismiss?: boolean
  dismissDelay?: number
}

interface Emits {
  (e: 'retry', error: any): void
}

const props = withDefaults(defineProps<Props>(), {
  maxVisible: 3,
  autoDismiss: true,
  dismissDelay: 5000
})

const emit = defineEmits<Emits>()

const { errors, clearError, getUserFriendlyMessage } = useErrorHandler()

const visibleErrors = computed(() => 
  errors.value.slice(0, props.maxVisible)
)

const getToastClass = (error: any) => {
  const baseClass = 'bg-white border rounded-lg shadow-lg p-4 max-w-sm relative overflow-hidden'
  
  switch (error.code) {
    case 'VALIDATION_ERROR':
      return `${baseClass} border-warning-300`
    case 'NETWORK_ERROR':
    case 'TIMEOUT':
      return `${baseClass} border-warning-300`
    default:
      return `${baseClass} border-error-300`
  }
}

const dismissError = (index: number) => {
  clearError(index)
}

const getProgressWidth = (error: any) => {
  if (!props.autoDismiss) return 0
  
  const elapsed = Date.now() - error.timestamp.getTime()
  const progress = (elapsed / props.dismissDelay) * 100
  return Math.min(100, Math.max(0, progress))
}

// Auto-dismiss non-retryable errors
let dismissTimers: NodeJS.Timeout[] = []

const setupAutoDismiss = () => {
  if (!props.autoDismiss) return
  
  // Clear existing timers
  dismissTimers.forEach(timer => clearTimeout(timer))
  dismissTimers = []
  
  // Set up new timers for non-retryable errors
  visibleErrors.value.forEach((error, index) => {
    if (!error.retryable) {
      const timer = setTimeout(() => {
        dismissError(index)
      }, props.dismissDelay)
      dismissTimers.push(timer)
    }
  })
}

// Watch for new errors and setup auto-dismiss
watch(visibleErrors, setupAutoDismiss, { immediate: true })

onUnmounted(() => {
  dismissTimers.forEach(timer => clearTimeout(timer))
})
</script>

<style scoped>
.error-toast-container {
  pointer-events: none;
}

.error-toast {
  pointer-events: auto;
}

/* Toast animations */
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s ease;
}

.toast-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.toast-leave-to {
  opacity: 0;
  transform: translateX(100%);
}

.toast-move {
  transition: transform 0.3s ease;
}
</style>