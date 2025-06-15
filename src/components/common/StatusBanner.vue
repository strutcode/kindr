<template>
  <div :class="[baseClass, colorClass]">
    <slot />
  </div>
</template>
<script setup lang="ts">
  interface Props {
    type: 'info' | 'success' | 'warning' | 'error'
  }
  const props = defineProps<Props>()
  const baseClass = 'rounded-lg p-4 mb-6 border flex items-start'
  const colorClass = {
    info: 'bg-primary-50 border-primary-200',
    success: 'bg-success-50 border-success-200',
    warning: 'bg-warning-50 border-warning-200',
    error: 'bg-error-50 border-error-200',
  }[props.type]
</script>
