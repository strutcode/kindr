<template>
  <div class="checkbox-wrapper">
    <label v-if="label" class="checkbox-label">
      <input
        :id="id"
        v-model="modelValueProxy"
        type="checkbox"
        :required="required"
        :disabled="disabled"
        class="checkbox-input"
        @change="$emit('change', modelValueProxy)"
      />
      <span class="checkbox-visual"></span>
      <span class="checkbox-text">
        {{ label }}<span v-if="required" class="text-error-600">*</span>
      </span>
    </label>

    <!-- Helper text -->
    <p v-if="helper" class="checkbox-helper">
      {{ helper }}
    </p>
  </div>
</template>

<script setup lang="ts">
  import { computed } from 'vue'

  interface Props {
    modelValue: boolean
    label?: string
    id?: string
    helper?: string
    required?: boolean
    disabled?: boolean
  }

  const props = withDefaults(defineProps<Props>(), {
    required: false,
    disabled: false,
  })

  const emit = defineEmits<{
    (e: 'update:modelValue', value: boolean): void
    (e: 'change', value: boolean): void
  }>()

  const modelValueProxy = computed({
    get: () => props.modelValue,
    set: value => emit('update:modelValue', value),
  })
</script>

<style scoped>
  .checkbox-wrapper {
    @apply space-y-1;
  }

  .checkbox-label {
    @apply flex items-start space-x-3 cursor-pointer;
  }

  .checkbox-label.disabled {
    @apply cursor-not-allowed opacity-50;
  }

  .checkbox-input {
    @apply sr-only;
  }

  .checkbox-visual {
    @apply flex-shrink-0 w-5 h-5 border-2 border-gray-300 rounded;
    @apply transition-colors duration-200 ease-in-out;
    @apply relative flex items-center justify-center;
  }

  .checkbox-input:checked + .checkbox-visual {
    @apply bg-primary-600 border-primary-600;
  }

  .checkbox-input:checked + .checkbox-visual::after {
    content: '';
    @apply absolute w-2.5 h-1.5 border-b-2 border-l-2 border-white;
    @apply transform -rotate-45 -translate-y-0.5;
  }

  .checkbox-input:focus + .checkbox-visual {
    @apply ring-2 ring-primary-500 ring-offset-2;
  }

  .checkbox-input:disabled + .checkbox-visual {
    @apply bg-gray-100 border-gray-300 cursor-not-allowed;
  }

  .checkbox-input:checked:disabled + .checkbox-visual {
    @apply bg-gray-400 border-gray-400;
  }

  .checkbox-text {
    @apply text-sm font-medium text-gray-700 leading-5;
  }

  .checkbox-label:has(.checkbox-input:disabled) .checkbox-text {
    @apply text-gray-400;
  }

  .checkbox-helper {
    @apply text-xs text-gray-500 ml-8;
  }
</style>
