<template>
  <aside class="filters-sidebar" @click.stop>
    <div class="flex items-center justify-between mb-6">
      <h3 class="text-xl font-semibold">Filters</h3>
      <button @click="requestsStore.closeFiltersPopover" class="text-gray-400 hover:text-gray-600">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
    <form @submit.prevent="applyFilters" class="flex flex-col gap-6 flex-1">
      <div>
        <label class="block text-sm font-medium mb-2">Category</label>
        <select v-model="localFilters.category" class="form-select w-full">
          <option value="">All Categories</option>
          <option v-for="cat in categories" :key="cat.value" :value="cat.value">
            {{ cat.label }}
          </option>
        </select>
      </div>
      <div v-if="selectedCategorySubcategories.length">
        <label class="block text-sm font-medium mb-2">Subcategory</label>
        <select v-model="localFilters.subcategory" class="form-select w-full">
          <option value="">All Subcategories</option>
          <option v-for="sub in selectedCategorySubcategories" :key="sub.value" :value="sub.value">
            {{ sub.label }}
          </option>
        </select>
      </div>
      <div class="mt-auto flex gap-2">
        <button type="button" class="btn btn-outline flex-1" @click="clearFilters">Clear</button>
        <button type="submit" class="btn btn-primary flex-1">Apply</button>
      </div>
    </form>
  </aside>
</template>

<script setup lang="ts">
  import { ref, watch, computed } from 'vue'
  import { useRequestsStore } from '@/stores/requests'
  import { CATEGORIES } from '@/constants/categories'

  const requestsStore = useRequestsStore()
  const localFilters = ref({ ...requestsStore.filters })

  watch(
    () => requestsStore.filters,
    newVal => {
      localFilters.value = { ...newVal }
    },
  )

  const categories = CATEGORIES
  const selectedCategorySubcategories = computed(() => {
    if (!localFilters.value.category) return []
    return CATEGORIES.find(cat => cat.value === localFilters.value.category)?.subcategories || []
  })

  const clearFilters = () => {
    localFilters.value = { category: '', subcategory: '' }
    requestsStore.updateFilters(localFilters.value)
  }

  const applyFilters = () => {
    requestsStore.updateFilters({ ...localFilters.value })
    requestsStore.closeFiltersPopover()
  }
</script>

<style scoped>
  .filters-sidebar {
    background: white;
    box-shadow: 2px 0 16px rgba(0, 0, 0, 0.1);
    border-right: 1px solid #e5e7eb;
    border-radius: 0 0.5rem 0.5rem 0;
    padding: 2rem 1.5rem 1.5rem 1.5rem;
    width: 340px;
    height: 100%;
    display: flex;
    flex-direction: column;
    position: relative;
    z-index: 20;
  }
</style>
