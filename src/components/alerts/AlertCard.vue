<template>
  <div class="alert-card">
    <div class="alert-header">
      <div class="alert-info">
        <h3 class="alert-name">{{ alert.name }}</h3>
        <div class="alert-details">
          <span class="alert-radius">{{ radiusDisplay }}</span>
          <span v-if="alert.category" class="alert-category">
            <Chip :label="categoryLabel" :color="categoryColor" size="xs" />
          </span>
          <span v-else class="alert-category-all">All categories</span>
        </div>
      </div>
      <div class="alert-actions">
        <Button
          variant="ghost"
          size="sm"
          @click="toggleActive"
          :icon-left="alert.active ? 'tabler:bell' : 'tabler:bell-off'"
          :class="{ 'text-gray-400': !alert.active }"
        >
          {{ alert.active ? 'Active' : 'Inactive' }}
        </Button>
        <Button variant="ghost" size="sm" icon-left="tabler:edit" @click="$emit('edit', alert)" />
        <Button
          variant="ghost"
          size="sm"
          icon-left="tabler:trash"
          class="text-red-500 hover:text-red-700"
          @click="$emit('delete', alert)"
        />
      </div>
    </div>

    <div class="alert-location">
      <Icon icon="tabler:map-pin" class="location-icon" />
      <span>{{ locationDisplay }}</span>
    </div>

    <div class="alert-meta">
      <span class="alert-date">Created {{ formatDate(alert.created_at) }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed } from 'vue'
  import { Icon } from '@iconify/vue'
  import type { Alert, RequestCategory } from '@/types'
  import { CATEGORIES } from '@/constants/categories'
  import Button from '@/components/widgets/Button.vue'
  import Chip from '@/components/widgets/Chip.vue'

  interface Props {
    alert: Alert
  }

  interface Emits {
    (e: 'edit', alert: Alert): void
    (e: 'delete', alert: Alert): void
    (e: 'toggle', alert: Alert): void
  }

  const props = defineProps<Props>()
  const emit = defineEmits<Emits>()

  const radiusDisplay = computed(() => {
    const km = props.alert.radius_meters / 1000
    return km < 1 ? `${props.alert.radius_meters}m` : `${km}km`
  })

  const categoryLabel = computed(() => {
    if (!props.alert.category) return ''
    return CATEGORIES.find(cat => cat.value === props.alert.category)?.label || props.alert.category
  })

  const categoryColor = computed(() => {
    if (!props.alert.category) return 'gray'
    const category = CATEGORIES.find(cat => cat.value === props.alert.category)
    if (!category) return 'gray'

    // Map category colors to chip colors
    const colorMap: Record<string, string> = {
      '#059669': 'green',
      '#2563eb': 'blue',
      '#7c3aed': 'purple',
    }
    return colorMap[category.color] || 'gray'
  })

  const locationDisplay = computed(() => {
    return `${props.alert.location.lat.toFixed(4)}, ${props.alert.location.lng.toFixed(4)}`
  })

  const toggleActive = () => {
    emit('toggle', props.alert)
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    })
  }
</script>

<style scoped>
  .alert-card {
    @apply bg-white border border-gray-200 rounded-lg p-4 space-y-3;
    @apply hover:shadow-md transition-shadow;
  }

  .alert-header {
    @apply flex items-start justify-between;
  }

  .alert-info {
    @apply flex-1;
  }

  .alert-name {
    @apply text-lg font-semibold text-gray-900 mb-1;
  }

  .alert-details {
    @apply flex items-center gap-3 text-sm text-gray-600;
  }

  .alert-radius {
    @apply font-medium;
  }

  .alert-category-all {
    @apply text-gray-500 italic;
  }

  .alert-actions {
    @apply flex items-center gap-1;
  }

  .alert-location {
    @apply flex items-center gap-2 text-sm text-gray-600;
  }

  .location-icon {
    @apply w-4 h-4 text-gray-400;
  }

  .alert-meta {
    @apply text-xs text-gray-500;
  }

  .alert-date {
    @apply block;
  }
</style>
