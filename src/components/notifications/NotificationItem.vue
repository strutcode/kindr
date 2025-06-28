<template>
  <div :class="['notification-item', { unread: !notification.read }]" @click="handleClick">
    <div class="notification-content">
      <div class="notification-header">
        <div class="notification-info">
          <h4 class="notification-title">{{ notification.listing_title }}</h4>
          <div class="notification-meta">
            <Chip :label="categoryLabel" :color="categoryColor" size="xs" />
            <span class="notification-alert">{{ notification.alert_name }}</span>
          </div>
        </div>
        <div class="notification-time">
          {{ formatTime(notification.created_at) }}
        </div>
      </div>

      <div class="notification-location">
        <Icon icon="tabler:map-pin" class="location-icon" />
        <span>{{ locationDisplay }}</span>
      </div>
    </div>

    <div v-if="!notification.read" class="unread-indicator"></div>
  </div>
</template>

<script setup lang="ts">
  import { computed } from 'vue'
  import { Icon } from '@iconify/vue'
  import type { Notification } from '@/types'
  import { CATEGORIES } from '@/constants/categories'
  import Chip from '@/components/widgets/Chip.vue'

  interface Props {
    notification: Notification
  }

  interface Emits {
    (e: 'click', notification: Notification): void
  }

  const props = defineProps<Props>()
  const emit = defineEmits<Emits>()

  const categoryLabel = computed(() => {
    return (
      CATEGORIES.find(cat => cat.value === props.notification.listing_category)?.label ||
      props.notification.listing_category
    )
  })

  const categoryColor = computed(() => {
    const category = CATEGORIES.find(cat => cat.value === props.notification.listing_category)
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
    return `${props.notification.listing_location.lat.toFixed(
      4,
    )}, ${props.notification.listing_location.lng.toFixed(4)}`
  })

  const formatTime = (timestamp: string) => {
    const date = new Date(timestamp)
    const now = new Date()
    const diffMs = now.getTime() - date.getTime()
    const diffMinutes = Math.floor(diffMs / (1000 * 60))
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

    if (diffMinutes < 1) {
      return 'Just now'
    } else if (diffMinutes < 60) {
      return `${diffMinutes}m ago`
    } else if (diffHours < 24) {
      return `${diffHours}h ago`
    } else if (diffDays < 7) {
      return `${diffDays}d ago`
    } else {
      return date.toLocaleDateString(undefined, {
        month: 'short',
        day: 'numeric',
        year: diffDays > 365 ? 'numeric' : undefined,
      })
    }
  }

  const handleClick = () => {
    emit('click', props.notification)
  }
</script>

<style scoped>
  .notification-item {
    @apply flex items-start p-4 border-b border-gray-100 cursor-pointer;
    @apply hover:bg-gray-50 transition-colors relative;
  }

  .notification-item.unread {
    @apply bg-blue-50 border-blue-100;
  }

  .notification-content {
    @apply flex-1 space-y-2;
  }

  .notification-header {
    @apply flex items-start justify-between;
  }

  .notification-info {
    @apply flex-1 mr-4;
  }

  .notification-title {
    @apply font-semibold text-gray-900 text-sm leading-tight mb-1;
  }

  .notification-meta {
    @apply flex items-center gap-2;
  }

  .notification-alert {
    @apply text-xs text-gray-600;
  }

  .notification-time {
    @apply text-xs text-gray-500 flex-shrink-0;
  }

  .notification-location {
    @apply flex items-center gap-1 text-xs text-gray-600;
  }

  .location-icon {
    @apply w-3 h-3 text-gray-400;
  }

  .unread-indicator {
    @apply w-2 h-2 bg-blue-500 rounded-full flex-shrink-0 mt-2;
  }
</style>
