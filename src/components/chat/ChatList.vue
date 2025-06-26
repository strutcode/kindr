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
        <svg
          class="mx-auto h-8 w-8 text-gray-400 mb-3"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
          />
        </svg>
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
