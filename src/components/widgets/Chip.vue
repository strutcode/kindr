<template>
  <span :class="chipClass">
    <slot>{{ label }}</slot>
  </span>
</template>

<script setup lang="ts">
  import { computed } from 'vue'

  interface Props {
    label?: string
    color?:
      | 'primary'
      | 'secondary'
      | 'accent'
      | 'success'
      | 'warning'
      | 'error'
      | 'gray'
      | 'green'
      | 'blue'
      | 'purple'
    outline?: boolean
    size?: 'xs' | 'sm' | 'md' | 'lg'
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
      green: props.outline
        ? 'bg-white border border-green-200 text-green-800'
        : 'bg-green-100 text-green-800',
      blue: props.outline
        ? 'bg-white border border-blue-200 text-blue-800'
        : 'bg-blue-100 text-blue-800',
      purple: props.outline
        ? 'bg-white border border-purple-200 text-purple-800'
        : 'bg-purple-100 text-purple-800',
    }
    const sizeMap = {
      xs: 'px-1.5 py-0.5 text-xs',
      sm: 'px-2 py-0.5 text-xs',
      md: 'px-2.5 py-0.5 text-xs',
      lg: 'px-3 py-1 text-sm',
    }
    return `inline-flex items-center rounded-full font-medium ${colorMap[props.color]} ${
      sizeMap[props.size]
    }`
  })
</script>
