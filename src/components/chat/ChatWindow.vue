<template>
  <div class="chat-window">
    <!-- Messages area -->
    <div class="messages-container" ref="messagesContainer">
      <!-- Load more button -->
      <div v-if="hasMore" class="load-more-container">
        <button @click="$emit('load-more')" class="load-more-button">Load older messages</button>
      </div>

      <!-- Messages -->
      <div class="messages-list">
        <ChatMessage
          v-for="message in reversedMessages"
          :key="message.id"
          :message="message"
          :is-own="message.sender_id === authStore.user?.id"
        />
      </div>

      <!-- Scroll to bottom anchor -->
      <div ref="bottomAnchor"></div>
    </div>

    <!-- Message input -->
    <div class="message-input-container">
      <div class="message-input-wrapper">
        <!-- Image upload button -->
        <button @click="triggerImageUpload" class="image-upload-button" title="Send image">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
            />
          </svg>
        </button>

        <!-- Text input -->
        <input
          v-model="messageText"
          type="text"
          placeholder="Type a message..."
          class="message-input"
          @keydown.enter="handleSendMessage"
          :disabled="sending"
        />

        <!-- Send button -->
        <button
          @click="handleSendMessage"
          :disabled="!messageText.trim() || sending"
          class="send-button"
        >
          <svg
            v-if="!sending"
            class="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
            />
          </svg>
          <svg v-else class="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
            <circle
              class="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              stroke-width="4"
            ></circle>
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ></path>
          </svg>
        </button>

        <!-- Hidden file input -->
        <input
          ref="fileInput"
          type="file"
          accept="image/*"
          @change="handleImageSelect"
          class="hidden"
        />
      </div>

      <!-- Image preview -->
      <div v-if="selectedImage" class="image-preview-container">
        <div class="image-preview">
          <img :src="selectedImageUrl" alt="Selected image" class="preview-image" />
          <button @click="cancelImageUpload" class="cancel-image-button">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </div>
        <button @click="handleSendImage" :disabled="sending" class="send-image-button">
          <span v-if="!sending">Send Photo</span>
          <span v-else>Sending...</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, nextTick, watch, onMounted } from 'vue'
  import { useAuthStore } from '@/stores/auth'
  import type { Chat, ChatMessage as ChatMessageType } from '@/types'
  import ChatMessage from './ChatMessage.vue'

  interface Props {
    chat: Chat
    messages: ChatMessageType[]
    loading: boolean
    hasMore: boolean
  }

  const props = defineProps<Props>()

  const emit = defineEmits<{
    'send-message': [content: string]
    'send-image': [file: File]
    'load-more': []
  }>()

  const authStore = useAuthStore()

  const messageText = ref('')
  const sending = ref(false)
  const messagesContainer = ref<HTMLElement>()
  const bottomAnchor = ref<HTMLElement>()
  const fileInput = ref<HTMLInputElement>()
  const selectedImage = ref<File | null>(null)
  const selectedImageUrl = ref<string>('')

  const reversedMessages = computed(() => [...props.messages].reverse())

  // Scroll to bottom
  const scrollToBottom = (smooth = true) => {
    nextTick(() => {
      if (bottomAnchor.value) {
        bottomAnchor.value.scrollIntoView({
          behavior: smooth ? 'smooth' : 'auto',
          block: 'end',
        })
      }
    })
  }

  // Handle sending text message
  const handleSendMessage = async () => {
    const content = messageText.value.trim()
    if (!content || sending.value) return

    sending.value = true
    try {
      emit('send-message', content)
      messageText.value = ''
      scrollToBottom()
    } catch (error) {
      console.error('Failed to send message:', error)
    } finally {
      sending.value = false
    }
  }

  // Trigger image upload
  const triggerImageUpload = () => {
    fileInput.value?.click()
  }

  // Handle image selection
  const handleImageSelect = (event: Event) => {
    const target = event.target as HTMLInputElement
    const file = target.files?.[0]

    if (file) {
      selectedImage.value = file
      selectedImageUrl.value = URL.createObjectURL(file)
    }
  }

  // Handle sending image
  const handleSendImage = async () => {
    if (!selectedImage.value || sending.value) return

    sending.value = true
    try {
      emit('send-image', selectedImage.value)
      cancelImageUpload()
      scrollToBottom()
    } catch (error) {
      console.error('Failed to send image:', error)
    } finally {
      sending.value = false
    }
  }

  // Cancel image upload
  const cancelImageUpload = () => {
    selectedImage.value = null
    if (selectedImageUrl.value) {
      URL.revokeObjectURL(selectedImageUrl.value)
      selectedImageUrl.value = ''
    }
    if (fileInput.value) {
      fileInput.value.value = ''
    }
  }

  // Watch for new messages and scroll to bottom
  watch(
    () => props.messages.length,
    (newLength, oldLength) => {
      if (newLength > oldLength) {
        scrollToBottom()
      }
    },
  )

  // Scroll to bottom on mount
  onMounted(() => {
    scrollToBottom(false)
  })
</script>

<style scoped>
  .chat-window {
    @apply flex flex-col h-full bg-gray-50;
  }

  .messages-container {
    @apply flex-1 overflow-y-auto p-4;
  }

  .load-more-container {
    @apply text-center pb-4;
  }

  .load-more-button {
    @apply px-4 py-2 text-sm text-blue-600 hover:text-blue-800;
    @apply border border-blue-200 rounded-full hover:bg-blue-50;
    @apply transition-colors;
  }

  .messages-list {
    @apply space-y-4;
  }

  .message-input-container {
    @apply border-t border-gray-200 bg-white p-4;
  }

  .message-input-wrapper {
    @apply flex items-center space-x-2;
  }

  .image-upload-button {
    @apply p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100;
    @apply rounded-full transition-colors;
  }

  .message-input {
    @apply flex-1 px-4 py-2 border border-gray-300 rounded-full;
    @apply focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent;
    @apply disabled:bg-gray-100 disabled:cursor-not-allowed;
  }

  .send-button {
    @apply p-2 text-white bg-blue-500 rounded-full;
    @apply hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed;
    @apply transition-colors;
  }

  .image-preview-container {
    @apply mt-3 p-3 bg-gray-50 rounded-lg;
  }

  .image-preview {
    @apply relative inline-block;
  }

  .preview-image {
    @apply w-20 h-20 object-cover rounded-lg;
  }

  .cancel-image-button {
    @apply absolute -top-2 -right-2 p-1 bg-red-500 text-white rounded-full;
    @apply hover:bg-red-600 transition-colors;
  }

  .send-image-button {
    @apply mt-2 px-4 py-2 bg-blue-500 text-white rounded-lg;
    @apply hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed;
    @apply transition-colors;
  }
</style>
