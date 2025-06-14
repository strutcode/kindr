import { ref, computed, onMounted, onUnmounted } from 'vue'

interface InfiniteScrollOptions {
  threshold?: number
  rootMargin?: string
  enabled?: Ref<boolean>
}

/**
 * Composable for infinite scrolling functionality
 */
export function useInfiniteScroll(
  callback: () => void | Promise<void>,
  options: InfiniteScrollOptions = {}
) {
  const {
    threshold = 0.1,
    rootMargin = '100px',
    enabled = ref(true)
  } = options
  
  const targetRef = ref<HTMLElement>()
  const isIntersecting = ref(false)
  const observer = ref<IntersectionObserver>()
  
  const setupObserver = () => {
    if (!targetRef.value || !enabled.value) return
    
    observer.value = new IntersectionObserver(
      (entries) => {
        const entry = entries[0]
        isIntersecting.value = entry.isIntersecting
        
        if (entry.isIntersecting && enabled.value) {
          callback()
        }
      },
      {
        threshold,
        rootMargin
      }
    )
    
    observer.value.observe(targetRef.value)
  }
  
  const cleanup = () => {
    if (observer.value) {
      observer.value.disconnect()
      observer.value = undefined
    }
  }
  
  // Watch for enabled changes
  watch(enabled, (newEnabled) => {
    if (newEnabled) {
      setupObserver()
    } else {
      cleanup()
    }
  })
  
  onMounted(() => {
    setupObserver()
  })
  
  onUnmounted(() => {
    cleanup()
  })
  
  return {
    targetRef,
    isIntersecting: computed(() => isIntersecting.value),
    setupObserver,
    cleanup
  }
}