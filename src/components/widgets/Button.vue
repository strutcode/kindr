<template>
  <router-link v-if="link" :to="link" :class="buttonClass">
    <Icon v-if="loading" icon="svg-spinners:90-ring-with-bg" class="mr-2" />
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
    <Icon v-if="loading" icon="svg-spinners:90-ring-with-bg" class="animate-spin mr-2" />
    <Icon v-if="iconLeft" :icon="iconLeft" :class="{ 'mr-2': $slots.default }" />
    <slot />
    <Icon v-if="iconRight" :icon="iconRight" :class="{ 'ml-2': $slots.default }" />
  </button>
</template>

<script setup lang="ts">
  import { computed } from 'vue'
  import { Icon } from '@iconify/vue'

  interface Props {
    variant?: 'primary' | 'secondary' | 'accent' | 'gray' | 'outline' | 'outline-white' | 'ghost'
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
      ghost: '',
      gray: 'btn-gray',
    }[props.variant]
    const size = {
      sm: 'btn-sm',
      md: 'btn-md',
      lg: 'btn-lg',
    }[props.size]
    return [base, variant, size, props.loading ? 'opacity-70 pointer-events-none' : ''].join(' ')
  })
</script>

<style scoped>
  .btn {
    @apply inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-offset-2 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed;
  }

  .btn-primary {
    @apply bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-500;
  }

  .btn-secondary {
    @apply bg-secondary-600 text-white hover:bg-secondary-700 focus:ring-secondary-500;
  }

  .btn-outline {
    @apply border-gray-300 text-gray-700 bg-white hover:bg-gray-50 focus:ring-primary-500;
  }

  .btn-outline-white {
    @apply border-white text-white bg-transparent hover:bg-white hover:text-primary-600 focus:ring-white;
  }

  .btn-white {
    @apply bg-white text-primary-600 hover:bg-gray-50 focus:ring-primary-500;
  }

  .btn-gray {
    @apply bg-gray-500 text-white hover:bg-gray-600 focus:ring-primary-500;
  }

  .btn-sm {
    @apply px-3 py-1.5 text-sm;
  }

  .btn-md {
    @apply px-3 py-2 text-base;
  }

  .btn-lg {
    @apply px-6 py-3 text-lg;
  }
</style>
