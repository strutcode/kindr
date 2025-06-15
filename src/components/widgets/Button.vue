<template>
  <button :class="buttonClass" :disabled="disabled || loading" @click="$emit('click', $event)">
    <slot />
  </button>
</template>

<script setup lang="ts">
  import { computed } from 'vue'

  interface Props {
    variant?: 'primary' | 'secondary' | 'accent' | 'outline' | 'outline-white'
    size?: 'sm' | 'md' | 'lg'
    disabled?: boolean
    loading?: boolean
  }
  const props = withDefaults(defineProps<Props>(), {
    variant: 'primary',
    size: 'md',
    disabled: false,
    loading: false,
  })

  const buttonClass = computed(() => {
    const base = 'btn'
    const variant = {
      primary: 'btn-primary',
      secondary: 'btn-secondary',
      accent: 'btn-accent',
      outline: 'btn-outline',
      'outline-white': 'btn-outline-white',
    }[props.variant]
    const size = {
      sm: 'btn-sm',
      md: '',
      lg: 'btn-lg',
    }[props.size]
    return [base, variant, size, props.loading ? 'opacity-70 pointer-events-none' : ''].join(' ')
  })
</script>
