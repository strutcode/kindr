<template>
  <div class="space-y-2">
    <label v-if="label" :for="id" class="block text-sm font-medium text-gray-700 mb-2">
      {{ label }}<span v-if="required" class="text-error-600">*</span>
    </label>
    <input
      v-model="input"
      :id="id"
      :placeholder="placeholder"
      class="input"
      @keydown.enter.prevent="addTag"
      @blur="addTag"
      type="text"
    />
    <div class="flex flex-wrap gap-2 mb-2">
      <span
        v-for="(tag, index) in modelValue"
        :key="index"
        class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-primary-100 text-primary-800"
      >
        {{ tag }}
        <button
          type="button"
          @click="removeTag(index)"
          class="ml-2 text-primary-600 hover:text-primary-500"
        >
          <slot name="remove-icon">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </slot>
        </button>
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'

  interface Props {
    id: string
    label?: string
    required?: boolean
    modelValue: string[]
    placeholder?: string
  }
  const props = defineProps<Props>()
  const emit = defineEmits(['update:modelValue', 'add', 'remove'])

  const input = ref('')

  function addTag() {
    const value = input.value.trim()
    if (value && !props.modelValue.includes(value)) {
      emit('update:modelValue', [...props.modelValue, value])
      emit('add', value)
    }
    input.value = ''
  }

  function removeTag(index: number) {
    const tags = [...props.modelValue]
    const removed = tags.splice(index, 1)
    emit('update:modelValue', tags)
    emit('remove', removed[0])
  }
</script>
