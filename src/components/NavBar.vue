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

    <div class="flex justify-end items-center space-x-4">
      <!-- Chat icon with unread indicator -->
      <router-link v-if="authStore.user" :to="{ name: 'chats' }" class="chat-button">
        <Icon icon="tabler:message-circle-filled" class="chat-icon" />
        <span v-if="chatStore.unreadCount > 0" class="unread-badge">
          {{ chatStore.unreadCount > 99 ? '∞' : chatStore.unreadCount }}
        </span>
      </router-link>

      <!-- The user profile icon and menu -->
      <UserMenu class="collapse md:visible" />

      <!-- Mobile hamburger menu -->
      <MobileMenu class="md:hidden" />
    </div>
  </nav>
</template>

<script setup lang="ts">
  import { ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { useUiStore } from '@/stores/ui'
  import { useAuthStore } from '@/stores/auth'
  import { useChatStore } from '@/stores/chat'
  import { Icon } from '@iconify/vue'

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
    @apply w-8 h-8 text-gray-400;
  }

  .unread-badge {
    @apply block absolute w-6 h-6 -top-0 -right-0 flex items-center justify-center;
    @apply bg-red-500 text-white text-sm rounded-full font-medium leading-none;
  }
</style>
