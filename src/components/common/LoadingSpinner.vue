<template>
  <div class="flex items-center justify-center" :class="containerClass">
    <div 
      class="animate-spin rounded-full border-2 border-gray-300 border-t-primary-600" 
      :class="sizeClass"
      role="status"
      aria-label="Loading"
    />
    <span v-if="text" class="ml-3 text-gray-600" :class="textSizeClass">{{ text }}</span>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  size?: 'sm' | 'md' | 'lg'
  text?: string
  centered?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  centered: false,
})

const sizeClass = computed(() => {
  switch (props.size) {
    case 'sm': return 'w-4 h-4'
    case 'lg': return 'w-8 h-8'
    default: return 'w-6 h-6'
  }
})

const textSizeClass = computed(() => {
  switch (props.size) {
    case 'sm': return 'text-sm'
    case 'lg': return 'text-lg'
    default: return 'text-base'
  }
})

const containerClass = computed(() => {
  return props.centered ? 'min-h-[200px]' : ''
})
</script>