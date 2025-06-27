<template>
  <div :class="['message', { 'own-message': isOwn, 'other-message': !isOwn }]">
    <div v-if="!isOwn" class="message-avatar">
      <img
        v-if="message.sender_avatar_url"
        :src="message.sender_avatar_url"
        :alt="message.sender_name"
        class="avatar-image"
      />
      <div v-else class="avatar-placeholder">
        <Icon icon="tabler:user-filled" class="h-5 w-5 text-gray-500" />
      </div>
    </div>

    <div class="message-content">
      <div v-if="!isOwn" class="sender-name">{{ message.sender_name }}</div>

      <div class="message-bubble">
        <!-- Text message -->
        <div v-if="message.message_type === 'text'" class="text-message">
          {{ message.content }}
        </div>

        <!-- Image message -->
        <div v-else-if="message.message_type === 'image'" class="image-message">
          <img
            :src="message.image_url"
            :alt="'Image from ' + message.sender_name"
            class="message-image"
            @click="openImageModal"
          />
        </div>
      </div>

      <div class="message-time">
        {{ formatTime(message.created_at) }}
      </div>
    </div>

    <!-- Image modal -->
    <div
      v-if="showImageModal && message.message_type === 'image'"
      class="image-modal"
      @click="closeImageModal"
    >
      <div class="image-modal-content" @click.stop>
        <img
          :src="message.image_url"
          :alt="'Image from ' + message.sender_name"
          class="modal-image"
        />
        <button @click="closeImageModal" class="close-modal-button">
          <Icon icon="tabler:user-filled" class="h-6 w-6 text-gray-500" />
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref } from 'vue'
  import type { ChatMessage as ChatMessageType } from '@/types'
  import { Icon } from '@iconify/vue'

  interface Props {
    message: ChatMessageType
    isOwn: boolean
  }

  defineProps<Props>()

  const showImageModal = ref(false)

  const openImageModal = () => {
    showImageModal.value = true
  }

  const closeImageModal = () => {
    showImageModal.value = false
  }

  const formatTime = (timestamp: string) => {
    const date = new Date(timestamp)
    return date.toLocaleTimeString(undefined, {
      hour: 'numeric',
      minute: '2-digit',
      hour12: true,
    })
  }
</script>

<style scoped>
  .message {
    @apply flex gap-3;
  }

  .own-message {
    @apply flex-row-reverse;
  }

  .other-message {
    @apply flex-row;
  }

  .message-avatar {
    @apply flex-shrink-0;
  }

  .avatar-image {
    @apply w-8 h-8 rounded-full object-cover;
  }

  .avatar-placeholder {
    @apply w-8 h-8 rounded-full bg-gray-300 flex items-center justify-center;
  }

  .avatar-icon {
    @apply w-4 h-4 text-gray-600;
  }

  .message-content {
    @apply max-w-xs md:max-w-sm lg:max-w-md;
  }

  .own-message .message-content {
    @apply items-end;
  }

  .other-message .message-content {
    @apply items-start;
  }

  .sender-name {
    @apply text-xs text-gray-500 mb-1 px-1;
  }

  .message-bubble {
    @apply rounded-lg px-3 py-2 break-words;
  }

  .own-message .message-bubble {
    @apply bg-blue-500 text-white rounded-br-sm;
  }

  .other-message .message-bubble {
    @apply bg-white text-gray-900 border border-gray-200 rounded-bl-sm;
  }

  .text-message {
    @apply text-sm leading-relaxed;
  }

  .image-message {
    @apply p-0;
  }

  .message-image {
    @apply max-w-full h-auto rounded-lg cursor-pointer;
    @apply hover:opacity-90 transition-opacity;
    max-width: 200px;
    max-height: 200px;
    object-fit: cover;
  }

  .message-time {
    @apply text-xs text-gray-400 mt-1 px-1;
  }

  .own-message .message-time {
    @apply text-right;
  }

  .other-message .message-time {
    @apply text-left;
  }

  .image-modal {
    @apply fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50;
    @apply p-4;
  }

  .image-modal-content {
    @apply relative max-w-4xl max-h-full;
  }

  .modal-image {
    @apply max-w-full max-h-full object-contain;
  }

  .close-modal-button {
    @apply absolute top-4 right-4 bg-black bg-opacity-50 text-white;
    @apply rounded-full p-2 hover:bg-opacity-75 transition-all;
  }
</style>
