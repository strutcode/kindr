import { ref, watch, type Ref } from 'vue'

/**
 * Composable for debouncing reactive values
 */
export function useDebounce<T>(
  value: Ref<T>,
  delay: number = 300
): Ref<T> {
  const debouncedValue = ref(value.value) as Ref<T>
  let timeoutId: NodeJS.Timeout | null = null
  
  watch(value, (newValue) => {
    if (timeoutId) {
      clearTimeout(timeoutId)
    }
    
    timeoutId = setTimeout(() => {
      debouncedValue.value = newValue
    }, delay)
  }, { immediate: true })
  
  return debouncedValue
}

/**
 * Composable for debouncing function calls
 */
export function useDebouncedFunction<T extends (...args: any[]) => any>(
  fn: T,
  delay: number = 300
): T {
  let timeoutId: NodeJS.Timeout | null = null
  
  return ((...args: Parameters<T>) => {
    if (timeoutId) {
      clearTimeout(timeoutId)
    }
    
    timeoutId = setTimeout(() => {
      fn(...args)
    }, delay)
  }) as T
}