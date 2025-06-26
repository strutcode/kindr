<template>
  <div
    :class="['chat-list-item', { selected: selected, unread: hasUnreadMessages }]"
    @click="$emit('select')"
  >
    <div class="chat-avatar">
      <img
        v-if="chat.other_user?.avatar_url"
        :src="chat.other_user.avatar_url"
        :alt="chat.other_user.full_name || 'User'"
        class="avatar-image"
      />
      <div v-else class="avatar-placeholder">
        <svg class="avatar-icon" fill="currentColor" viewBox="0 0 20 20">
          <path
            fill-rule="evenodd"
            d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
            clip-rule="evenodd"
          />
        </svg>
      </div>
    </div>

    <div class="chat-content">
      <div class="chat-header">
        <h3 class="chat-name">{{ chat.other_user?.full_name || 'Anonymous' }}</h3>
        <span class="chat-time">{{ formatTime(chat.last_message_at) }}</span>
      </div>

      <div class="chat-info">
        <p class="listing-title">{{ chat.listing?.title || 'Unknown listing' }}</p>
        <Chip
          v-if="chat.listing?.category"
          :label="categoryLabels[chat.listing.category]"
          :color="categoryColors[chat.listing.category]"
          size="xs"
        />
      </div>

      <div v-if="chat.last_message" class="last-message">
        <p class="message-preview">
          <span v-if="chat.last_message.message_type === 'image'" class="flex items-center">
            <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
              />
            </svg>
            Photo
          </span>
          <span v-else>{{ chat.last_message.content }}</span>
        </p>

        <div v-if="hasUnreadMessages" class="unread-indicator">
          {{ unreadCount > 99 ? '99+' : unreadCount }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed } from 'vue'
  import { useAuthStore } from '@/stores/auth'
  import type { Chat } from '@/types'
  import Chip from '@/components/widgets/Chip.vue'

  interface Props {
    chat: Chat
    selected: boolean
  }

  const props = defineProps<Props>()

  defineEmits<{
    select: []
  }>()

  const authStore = useAuthStore()

  const categoryLabels = {
    'free-stuff': 'Free Stuff',
    'help-needed': 'Help Needed',
    'skills-offered': 'Skills Offered',
  }

  const categoryColors = {
    'free-stuff': 'green' as const,
    'help-needed': 'blue' as const,
    'skills-offered': 'purple' as const,
  }

  const hasUnreadMessages = computed(() => {
    if (!authStore.user) return false

    if (props.chat.requester_id === authStore.user.id) {
      return props.chat.requester_unread_count > 0
    } else {
      return props.chat.owner_unread_count > 0
    }
  })

  const unreadCount = computed(() => {
    if (!authStore.user) return 0

    if (props.chat.requester_id === authStore.user.id) {
      return props.chat.requester_unread_count
    } else {
      return props.chat.owner_unread_count
    }
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
      return `${diffMinutes}m`
    } else if (diffHours < 24) {
      return `${diffHours}h`
    } else if (diffDays < 7) {
      return `${diffDays}d`
    } else {
      return date.toLocaleDateString(undefined, { month: 'short', day: 'numeric' })
    }
  }
</script>

<style scoped>
  .chat-list-item {
    @apply flex p-4 cursor-pointer transition-colors;
    @apply hover:bg-gray-50;
  }

  .chat-list-item.selected {
    @apply bg-blue-50 border-r-2 border-blue-500;
  }

  .chat-list-item.unread {
    @apply bg-blue-50 bg-opacity-50;
  }

  .chat-avatar {
    @apply flex-shrink-0 mr-3;
  }

  .avatar-image {
    @apply w-12 h-12 rounded-full object-cover;
  }

  .avatar-placeholder {
    @apply w-12 h-12 rounded-full bg-gray-300 flex items-center justify-center;
  }

  .avatar-icon {
    @apply w-6 h-6 text-gray-600;
  }

  .chat-content {
    @apply flex-1 min-w-0;
  }

  .chat-header {
    @apply flex items-start justify-between mb-1;
  }

  .chat-name {
    @apply font-medium text-gray-900 truncate;
  }

  .chat-time {
    @apply text-xs text-gray-500 flex-shrink-0 ml-2;
  }

  .chat-info {
    @apply flex items-center gap-2 mb-1;
  }

  .listing-title {
    @apply text-sm text-gray-600 truncate flex-1;
  }

  .last-message {
    @apply flex items-center justify-between;
  }

  .message-preview {
    @apply text-sm text-gray-500 truncate flex-1;
  }

  .unread-indicator {
    @apply bg-blue-500 text-white text-xs rounded-full px-2 py-1 ml-2;
    @apply min-w-[20px] text-center flex-shrink-0;
  }
</style>
