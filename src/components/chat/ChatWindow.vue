<template>
  <div class="chat-window">
    <!-- Messages area -->
    <div class="messages-container" ref="messagesContainer">
      <!-- Load more button -->
      <div v-if="hasMore" class="load-more-container">
        <button @click="loadMoreMessages" class="load-more-button">Load older messages</button>
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
        <button
          variant="ghost"
          @click="triggerImageUpload"
          class="image-upload-button"
          title="Send image"
        >
          <Icon icon="tabler:photo-up" class="w-5 h-5 text-gray-600" />
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
          <Icon v-if="!sending" icon="tabler:send" class="w-5 h-5" />
          <Icon
            v-else
            icon="svg-spinners:90-ring-with-bg"
            class="w-5 h-5 animate-spin text-primary-600"
          />
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
          <Button @click="cancelImageUpload" icon-left="tabler-x" class="cancel-image-button" />
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

  import type { Chat, ChatMessage as ChatMessageType } from '@/types'
  import { useAuthStore } from '@/stores/auth'
  import { useChatStore } from '@/stores/chat'

  import ChatMessage from './ChatMessage.vue'
  import { Icon } from '@iconify/vue'
  import Button from '../widgets/Button.vue'

  interface Props {
    chat: Chat
    messages: ChatMessageType[]
  }

  const props = defineProps<Props>()

  const authStore = useAuthStore()
  const chatStore = useChatStore()

  const messageText = ref('')
  const sending = ref(false)
  const loading = ref(false)
  const messagesContainer = ref<HTMLElement>()
  const bottomAnchor = ref<HTMLElement>()
  const fileInput = ref<HTMLInputElement>()
  const selectedImage = ref<File | null>(null)
  const selectedImageUrl = ref<string>('')

  const reversedMessages = computed(() => [...props.messages].reverse())
  const hasMore = computed(() => chatStore.hasMore[props.chat.id] ?? false)

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
      await chatStore.sendMessage(props.chat.id, content)
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
      await chatStore.uploadChatImage(selectedImage.value, props.chat.id)
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

  // Load more messages
  const loadMoreMessages = () => {
    try {
      loading.value = true
      chatStore.loadMoreMessages(props.chat.id)
    } catch (error) {
      console.error('Failed to load more messages:', error)
    } finally {
      loading.value = false
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
    @apply flex-1 content-end overflow-y-auto p-4;
    @apply md:p-8 lg:p-10;
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
