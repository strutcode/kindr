<template>
  <label v-if="label" :for="id" class="block text-sm font-medium text-gray-700 mb-2">
    {{ label }}<span v-if="required" class="text-error-600">*</span>
  </label>
  <textarea
    :id="id"
    v-model="modelValueProxy"
    :rows="rows"
    :placeholder="placeholder"
    :required="required"
    class="input"
    @input="$emit('input', modelValueProxy)"
  />
</template>

<script setup lang="ts">
  import { computed } from 'vue'

  interface Props {
    modelValue: string
    label?: string
    id?: string
    placeholder?: string
    required?: boolean
    rows?: number
  }
  const props = withDefaults(defineProps<Props>(), {
    rows: 4,
  })
  const emit = defineEmits(['update:modelValue', 'input'])

  const modelValueProxy = computed({
    get: () => props.modelValue,
    set: v => emit('update:modelValue', v),
  })
</script>
