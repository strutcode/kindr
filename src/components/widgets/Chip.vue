<template>
  <span :class="chipClass">
    <slot />
  </span>
</template>

<script setup lang="ts">
  import { computed } from 'vue'

  interface Props {
    color?: 'primary' | 'secondary' | 'accent' | 'success' | 'warning' | 'error' | 'gray'
    outline?: boolean
    size?: 'sm' | 'md' | 'lg'
  }
  const props = withDefaults(defineProps<Props>(), {
    color: 'primary',
    outline: false,
    size: 'md',
  })

  const chipClass = computed(() => {
    const colorMap = {
      primary: props.outline
        ? 'bg-white border border-primary-200 text-primary-800'
        : 'bg-primary-100 text-primary-800',
      secondary: props.outline
        ? 'bg-white border border-secondary-200 text-secondary-800'
        : 'bg-secondary-100 text-secondary-800',
      accent: props.outline
        ? 'bg-white border border-accent-200 text-accent-800'
        : 'bg-accent-100 text-accent-800',
      success: props.outline
        ? 'bg-white border border-success-200 text-success-800'
        : 'bg-success-100 text-success-800',
      warning: props.outline
        ? 'bg-white border border-warning-200 text-warning-800'
        : 'bg-warning-100 text-warning-800',
      error: props.outline
        ? 'bg-white border border-error-200 text-error-800'
        : 'bg-error-100 text-error-800',
      gray: props.outline
        ? 'bg-white border border-gray-200 text-gray-800'
        : 'bg-gray-100 text-gray-800',
    }
    const sizeMap = {
      sm: 'px-2 py-0.5 text-xs',
      md: 'px-2.5 py-0.5 text-xs',
      lg: 'px-3 py-1 text-sm',
    }
    return `inline-flex items-center rounded-full font-medium ${colorMap[props.color]} ${
      sizeMap[props.size]
    }`
  })
</script>
