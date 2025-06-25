<template>
  <router-link v-if="link" :to="link" :class="buttonClass">
    <Icon v-if="loading" :horizontal-flip="true" icon="tabler:refresh" class="animate-spin mr-2" />
    <Icon v-if="iconLeft" :icon="iconLeft" :class="{ 'mr-2': $slots.default }" />
    <slot />
    <Icon v-if="iconRight" :icon="iconRight" :class="{ 'ml-2': $slots.default }" />
  </router-link>
  <button
    v-else
    :class="buttonClass"
    :disabled="disabled || loading"
    @click="$emit('click', $event)"
  >
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
    variant?: 'primary' | 'secondary' | 'accent' | 'outline' | 'outline-white' | 'ghost'
    size?: 'sm' | 'md' | 'lg'
    disabled?: boolean
    loading?: boolean
    iconLeft?: string
    iconRight?: string
    link?: { name: string; params?: Record<string, any> }
  }
  const props = withDefaults(defineProps<Props>(), {
    variant: 'primary',
    size: 'md',
    disabled: false,
    loading: false,
    iconLeft: undefined,
    iconRight: undefined,
    link: undefined,
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
