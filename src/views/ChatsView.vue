<template>
  <div class="chats-container">
    <!-- Desktop Layout -->
    <div class="hidden md:flex h-full">
      <!-- Chat List Sidebar -->
      <div class="w-80 border-r border-gray-200 flex flex-col bg-white">
        <ChatList
          :chats="chatStore.sortedChats"
          :loading="chatStore.loading"
          :selected-chat-id="selectedChatId"
          @select-chat="handleChatSelect"
        />
      </div>

      <!-- Chat View -->
      <div class="flex-1 flex flex-col">
        <ChatWindow
          v-if="selectedChatId && currentChat"
          :chat="currentChat"
          :messages="chatStore.currentMessages"
          :loading="false"
          :has-more="chatStore.hasMore[selectedChatId] || false"
          @send-message="handleSendMessage"
          @send-image="handleSendImage"
          @load-more="handleLoadMore"
        />
        <div v-else class="flex-1 flex items-center justify-center text-gray-500">
          <div class="text-center">
            <svg
              class="mx-auto h-12 w-12 text-gray-400 mb-4"
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
            <p class="text-lg font-medium">Select a chat to start messaging</p>
            <p class="text-sm text-gray-400 mt-1">Choose from your existing conversations</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Mobile Layout -->
    <div class="md:hidden h-full flex flex-col">
      <!-- Show chat list if no chat selected -->
      <div v-if="!selectedChatId" class="flex-1">
        <div class="bg-white border-b border-gray-200 px-4 py-3">
          <h1 class="text-lg font-semibold text-gray-900">Messages</h1>
        </div>
        <ChatList
          :chats="chatStore.sortedChats"
          :loading="chatStore.loading"
          :selected-chat-id="null"
          @select-chat="handleChatSelect"
        />
      </div>

      <!-- Show individual chat -->
      <div v-else-if="currentChat" class="flex-1 flex flex-col">
        <!-- Mobile chat header -->
        <div class="bg-white border-b border-gray-200 px-4 py-3 flex items-center">
          <button @click="handleBackToList" class="mr-3 p-1 rounded-md hover:bg-gray-100">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              />
            </svg>
          </button>
          <div class="flex items-center">
            <img
              v-if="currentChat.other_user?.avatar_url"
              :src="currentChat.other_user.avatar_url"
              :alt="currentChat.other_user.full_name || 'User'"
              class="w-8 h-8 rounded-full mr-3"
            />
            <div
              class="w-8 h-8 rounded-full bg-gray-300 mr-3 flex items-center justify-center"
              v-else
            >
              <svg class="w-4 h-4 text-gray-600" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fill-rule="evenodd"
                  d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
                  clip-rule="evenodd"
                />
              </svg>
            </div>
            <div>
              <h2 class="font-medium text-gray-900">
                {{ currentChat.other_user?.full_name || 'Anonymous' }}
              </h2>
              <p class="text-sm text-gray-500">{{ currentChat.listing?.title }}</p>
            </div>
          </div>
        </div>

        <ChatWindow
          :chat="currentChat"
          :messages="chatStore.currentMessages"
          :loading="false"
          :has-more="chatStore.hasMore[selectedChatId] || false"
          @send-message="handleSendMessage"
          @send-image="handleSendImage"
          @load-more="handleLoadMore"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, watch } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { useChatStore } from '@/stores/chat'
  import ChatList from '@/components/chat/ChatList.vue'
  import ChatWindow from '@/components/chat/ChatWindow.vue'

  const route = useRoute()
  const router = useRouter()
  const chatStore = useChatStore()

  const selectedChatId = ref<string | null>(null)

  const currentChat = computed(() =>
    selectedChatId.value ? chatStore.chats.find(c => c.id === selectedChatId.value) : null,
  )

  // Handle chat selection
  const handleChatSelect = (chatId: string) => {
    selectedChatId.value = chatId
    chatStore.setCurrentChat(chatId)

    // Update URL for desktop
    if (window.innerWidth >= 768) {
      router.replace({ name: 'chat', params: { id: chatId } })
    } else {
      router.push({ name: 'chat', params: { id: chatId } })
    }
  }

  // Handle back to list (mobile)
  const handleBackToList = () => {
    selectedChatId.value = null
    chatStore.setCurrentChat(null)
    router.push({ name: 'chats' })
  }

  // Handle sending text message
  const handleSendMessage = async (content: string) => {
    if (!selectedChatId.value) return

    try {
      await chatStore.sendMessage(selectedChatId.value, content)
    } catch (error) {
      console.error('Failed to send message:', error)
      // You could show a toast notification here
    }
  }

  // Handle sending image
  const handleSendImage = async (file: File) => {
    if (!selectedChatId.value) return

    try {
      const imageUrl = await chatStore.uploadChatImage(file, selectedChatId.value)
      await chatStore.sendMessage(selectedChatId.value, '', 'image', imageUrl)
    } catch (error) {
      console.error('Failed to send image:', error)
      // You could show a toast notification here
    }
  }

  // Handle loading more messages
  const handleLoadMore = () => {
    if (selectedChatId.value) {
      chatStore.loadMoreMessages(selectedChatId.value)
    }
  }

  // Watch route params for chat ID
  watch(
    () => route.params.id,
    newId => {
      if (newId && typeof newId === 'string') {
        selectedChatId.value = newId
        chatStore.setCurrentChat(newId)
      } else if (route.name === 'chats') {
        selectedChatId.value = null
        chatStore.setCurrentChat(null)
      }
    },
    { immediate: true },
  )

  // Initialize chat store on mount
  onMounted(() => {
    chatStore.initialize()
  })
</script>

<style scoped>
  .chats-container {
    @apply h-screen flex flex-col;
    height: calc(100vh - 3.5rem); /* Account for navbar height */
  }

  @media (min-width: 768px) {
    .chats-container {
      height: calc(100vh - 4rem); /* Account for larger navbar on desktop */
    }
  }
</style>
