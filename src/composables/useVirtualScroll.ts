import { ref, computed, onMounted, onUnmounted } from 'vue'

interface VirtualScrollOptions {
  itemHeight: number
  containerHeight: number
  buffer?: number
}

/**
 * Composable for virtual scrolling to handle large lists efficiently
 */
export function useVirtualScroll<T>(
  items: Ref<T[]>,
  options: VirtualScrollOptions
) {
  const { itemHeight, containerHeight, buffer = 5 } = options
  
  const scrollTop = ref(0)
  const containerRef = ref<HTMLElement>()
  
  // Calculate visible range
  const visibleRange = computed(() => {
    const start = Math.floor(scrollTop.value / itemHeight)
    const visibleCount = Math.ceil(containerHeight / itemHeight)
    const end = start + visibleCount
    
    return {
      start: Math.max(0, start - buffer),
      end: Math.min(items.value.length, end + buffer)
    }
  })
  
  // Get visible items
  const visibleItems = computed(() => {
    const { start, end } = visibleRange.value
    return items.value.slice(start, end).map((item, index) => ({
      item,
      index: start + index,
      top: (start + index) * itemHeight
    }))
  })
  
  // Total height for scrollbar
  const totalHeight = computed(() => items.value.length * itemHeight)
  
  // Handle scroll events
  const handleScroll = (event: Event) => {
    const target = event.target as HTMLElement
    scrollTop.value = target.scrollTop
  }
  
  // Scroll to specific index
  const scrollToIndex = (index: number) => {
    if (containerRef.value) {
      const targetScrollTop = index * itemHeight
      containerRef.value.scrollTop = targetScrollTop
      scrollTop.value = targetScrollTop
    }
  }
  
  // Setup scroll listener
  onMounted(() => {
    if (containerRef.value) {
      containerRef.value.addEventListener('scroll', handleScroll, { passive: true })
    }
  })
  
  onUnmounted(() => {
    if (containerRef.value) {
      containerRef.value.removeEventListener('scroll', handleScroll)
    }
  })
  
  return {
    containerRef,
    visibleItems,
    totalHeight,
    scrollToIndex,
    visibleRange
  }
}