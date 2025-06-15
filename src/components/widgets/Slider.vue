<template>
  <label v-if="label" :for="id" class="block text-sm font-medium text-gray-700 mb-2">
    {{ label }}
  </label>
  <input
    type="range"
    :id="id"
    v-model.number="modelValueProxy"
    :min="min"
    :max="max"
    :step="step"
    class="w-full h-2 bg-gray-200 rounded-lg appearance-none slider"
    @input="$emit('input', $event.target.value)"
  />
  <div v-if="showRange" class="flex justify-between text-xs text-gray-500 mt-1">
    <span>{{ minLabel }}</span>
    <span>{{ maxLabel }}</span>
  </div>
</template>

<script setup lang="ts">
  import { computed } from 'vue'

  interface Props {
    modelValue: number
    min?: number
    max?: number
    step?: number
    label?: string
    id?: string
    minLabel?: string
    maxLabel?: string
    showRange?: boolean
  }
  const props = withDefaults(defineProps<Props>(), {
    min: 0,
    max: 100,
    step: 1,
    showRange: false,
  })
  const emit = defineEmits(['update:modelValue', 'input'])

  const modelValueProxy = computed({
    get: () => props.modelValue,
    set: v => emit('update:modelValue', Number(v)),
  })
</script>
