<template>
  <label v-if="label" :for="id" class="block text-sm font-medium text-gray-700 mb-2">
    {{ label }}<span v-if="required" class="text-error-600">*</span>
  </label>
  <select
    :id="id"
    v-model="modelValueProxy"
    :required="required"
    class="input"
    @change="$emit('change', $event.target.value)"
  >
    <option v-if="placeholder" value="">{{ placeholder }}</option>
    <option v-for="option in options" :key="option.value" :value="option.value">
      {{ option.label }}
    </option>
  </select>
</template>

<script setup lang="ts">
  import { computed } from 'vue'

  interface Option {
    value: string | number
    label: string
  }
  interface Props {
    modelValue: string | number | null
    options: Option[]
    label?: string
    id?: string
    required?: boolean
    placeholder?: string
  }
  const props = defineProps<Props>()
  const emit = defineEmits(['update:modelValue', 'change'])

  const modelValueProxy = computed({
    get: () => props.modelValue,
    set: v => emit('update:modelValue', v),
  })
</script>
