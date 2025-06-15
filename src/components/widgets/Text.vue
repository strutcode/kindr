<template>
  <label v-if="label" :for="id" class="block text-sm font-medium text-gray-700 mb-2">
    {{ label }}<span v-if="required" class="text-error-600">*</span>
  </label>
  <input
    :id="id"
    v-model="modelValueProxy"
    :type="type"
    :placeholder="placeholder"
    :required="required"
    class="input"
    @input="$emit('input', $event.target.value)"
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
    type?: string
  }
  const props = withDefaults(defineProps<Props>(), {
    type: 'text',
  })
  const emit = defineEmits(['update:modelValue', 'input'])

  const modelValueProxy = computed({
    get: () => props.modelValue,
    set: v => emit('update:modelValue', v),
  })
</script>
