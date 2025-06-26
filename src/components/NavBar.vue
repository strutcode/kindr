<template>
  <nav :class="{ transparent: ui.header.fade }">
    <router-link class="home-link" to="/">
      <img
        class="logo"
        :class="{ active: ui.header.fade }"
        src="@/assets/logo-white.svg"
        alt="Kindr"
      />
      <img class="logo" :class="{ active: !ui.header.fade }" src="@/assets/logo.svg" alt="Kindr" />
    </router-link>

    <div class="search">
      <Text
        v-model="query"
        class="w-full"
        placeholder="Search for people, groups, or topics"
        @enter="query => router.push({ name: 'search', query: { q: query } })"
      />
      <Button variant="outline" @click="router.push({ name: 'browse' })">Browse</Button>
    </div>

    <!-- Chat icon with unread indicator -->
    <button v-if="authStore.user" @click="router.push({ name: 'chats' })" class="chat-button">
      <svg class="chat-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
        />
      </svg>
      <span v-if="chatStore.unreadCount > 0" class="unread-badge">
        {{ chatStore.unreadCount > 99 ? '99+' : chatStore.unreadCount }}
      </span>
    </button>

    <UserMenu class="collapse md:visible" />

    <MobileMenu class="md:hidden" />
  </nav>
</template>

<script setup lang="ts">
  import { ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { useUiStore } from '@/stores/ui'
  import { useAuthStore } from '@/stores/auth'
  import { useChatStore } from '@/stores/chat'

  import UserMenu from '@/components/UserMenu.vue'
  import Button from './widgets/Button.vue'
  import Text from './widgets/Text.vue'
  import MobileMenu from './MobileMenu.vue'

  const query = ref('')
  const router = useRouter()
  const ui = useUiStore()
  const authStore = useAuthStore()
  const chatStore = useChatStore()
</script>

<style scoped>
  nav {
    @apply flex items-center justify-between relative z-50;
    @apply px-4 h-14 md:h-16 sticky top-0;
    @apply bg-white border-b border-gray-300 shadow-md;
    @apply transition-all duration-300 ease-in-out;
  }

  nav.transparent {
    @apply bg-transparent bg-gradient-to-b from-black/65 to-black/0 border-0 shadow-none;
  }

  nav .home-link {
    @apply block relative h-8 w-32;
  }

  .logo {
    @apply absolute top-0 left-0 h-8 w-auto;
    @apply transition-all duration-300 ease-in-out opacity-0;
  }

  .logo.active {
    @apply opacity-100;
  }

  .nav-item {
    @apply text-gray-600 hover:text-gray-900 font-medium transition-colors px-4 py-2;
  }

  .nav-item:hover {
    @apply bg-gray-50 rounded-md;
  }

  .search {
    @apply flex items-center space-x-2 collapse;
    @apply md:visible;
  }

  .chat-button {
    @apply relative p-2 rounded-lg transition-colors;
    @apply text-gray-600 hover:text-gray-900 hover:bg-gray-100;
  }

  nav.transparent .chat-button {
    @apply text-white hover:text-gray-200 hover:bg-white/20;
  }

  .chat-icon {
    @apply w-6 h-6;
  }

  .unread-badge {
    @apply absolute -top-1 -right-1 bg-red-500 text-white text-xs;
    @apply rounded-full px-1.5 py-0.5 min-w-[20px] text-center;
    @apply font-medium leading-none;
  }
</style>
