<template>
  <div class="filters-popover" @click.stop>
    <div class="flex justify-between items-center mb-4">
      <h3 class="text-lg font-semibold">Filters</h3>
      <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    <form @submit.prevent="applyFilters">
      <div class="mb-4">
        <label class="block text-sm font-medium mb-1">Category</label>
        <select v-model="localFilters.category" class="form-select w-full">
          <option value="">All Categories</option>
          <option v-for="cat in categories" :key="cat.value" :value="cat.value">
            {{ cat.label }}
          </option>
        </select>
      </div>
      <div class="mb-4" v-if="selectedCategorySubcategories.length">
        <label class="block text-sm font-medium mb-1">Subcategory</label>
        <select v-model="localFilters.subcategory" class="form-select w-full">
          <option value="">All Subcategories</option>
          <option v-for="sub in selectedCategorySubcategories" :key="sub.value" :value="sub.value">
            {{ sub.label }}
          </option>
        </select>
      </div>
      <div class="flex justify-end space-x-2">
        <button type="button" class="btn btn-outline" @click="clearFilters">Clear</button>
        <button type="submit" class="btn btn-primary">Apply</button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch, computed } from 'vue'
  const props = defineProps({
    filters: { type: Object, required: true },
    categories: { type: Array, required: true },
    selectedCategorySubcategories: { type: Array, required: true },
  })
  const emit = defineEmits(['update:filters', 'close'])
  const localFilters = ref({ ...props.filters })

  watch(
    () => props.filters,
    newVal => {
      localFilters.value = { ...newVal }
    },
  )

  const clearFilters = () => {
    localFilters.value = { category: '', subcategory: '' }
    emit('update:filters', localFilters.value)
  }

  const applyFilters = () => {
    emit('update:filters', { ...localFilters.value })
  }
</script>

<style scoped>
  .filters-popover {
    background: white;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
    border-radius: 0.5rem;
    padding: 1.5rem;
    min-width: 320px;
    position: absolute;
    top: 64px;
    left: 50px;
    z-index: 20;
  }
</style>
