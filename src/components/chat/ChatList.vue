<template>
  <div class="chat-list">
    <!-- Header -->
    <div class="chat-list-header">
      <h2 class="text-lg font-semibold text-gray-900">Messages</h2>
      <div v-if="loading" class="text-sm text-gray-500">Loading...</div>
    </div>

    <!-- Chat list -->
    <div class="chat-list-content">
      <div v-if="chats.length === 0 && !loading" class="empty-state">
        <Icon icon="tabler:message-circle" class="mx-auto h-8 w-8 text-gray-400 mb-3" />
        <p class="text-sm text-gray-500 text-center">No messages yet</p>
        <p class="text-xs text-gray-400 text-center mt-1">Start a conversation about a listing</p>
      </div>

      <div v-else class="chat-items">
        <ChatListItem
          v-for="chat in chats"
          :key="chat.id"
          :chat="chat"
          :selected="chat.id === selectedChatId"
          @select="$emit('select-chat', chat.id)"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { defineEmits } from 'vue'
  import type { Chat } from '@/types'
  import ChatListItem from './ChatListItem.vue'
  import { Icon } from '@iconify/vue'

  interface Props {
    chats: Chat[]
    loading: boolean
    selectedChatId: string | null
  }

  defineProps<Props>()

  defineEmits<{
    'select-chat': [chatId: string]
  }>()
</script>

<style scoped>
  .chat-list {
    @apply flex flex-col h-full;
  }

  .chat-list-header {
    @apply p-4 border-b border-gray-200 flex items-center justify-between;
  }

  .chat-list-content {
    @apply flex-1 overflow-y-auto;
  }

  .empty-state {
    @apply flex flex-col items-center justify-center h-full px-4 py-8;
  }

  .chat-items {
    @apply divide-y divide-gray-100;
  }
</style>
