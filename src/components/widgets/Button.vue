<template>
  <button :class="buttonClass" :disabled="disabled || loading" @click="$emit('click', $event)">
    <Icon v-if="loading" :horizontal-flip="true" icon="tabler:refresh" class="animate-spin mr-2" />
    <Icon v-if="iconLeft" :icon="iconLeft" :class="{ 'mr-2': $slots.default }" />
    <slot />
    <Icon v-if="iconRight" :icon="iconRight" :class="{ 'ml-2': $slots.default }" />
  </button>
</template>

<script setup lang="ts">
  import { computed } from 'vue'
  import { Icon } from '@iconify/vue'

  interface Props {
    variant?: 'primary' | 'secondary' | 'accent' | 'outline' | 'outline-white'
    size?: 'sm' | 'md' | 'lg'
    disabled?: boolean
    loading?: boolean
    iconLeft?: string
    iconRight?: string
  }
  const props = withDefaults(defineProps<Props>(), {
    variant: 'primary',
    size: 'md',
    disabled: false,
    loading: false,
  })

  defineEmits<{
    (e: 'click', event: MouseEvent): void
  }>()

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
      md: 'btn-md',
      lg: 'btn-lg',
    }[props.size]
    return [base, variant, size, props.loading ? 'opacity-70 pointer-events-none' : ''].join(' ')
  })
</script>
