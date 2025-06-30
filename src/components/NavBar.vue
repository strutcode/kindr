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

    <Button variant="ghost" :link="{ name: 'browse' }" class="nav-item">Browse</Button>
    <Button
      v-if="authStore.isAuthenticated"
      variant="ghost"
      :link="{ name: 'chats' }"
      class="nav-item"
      >Messages</Button
    >
    <Button variant="ghost" :link="{ name: 'help' }" class="nav-item">Help</Button>

    <div class="flex justify-end items-center space-x-4">
      <!-- Notifications bell icon with unread indicator -->
      <router-link
        v-if="authStore.user"
        :to="{ name: 'notifications' }"
        class="notification-button"
      >
        <Icon icon="tabler:bell-filled" class="notification-icon" />
        <span v-if="notificationsStore.unreadCount > 0" class="unread-badge">
          {{ notificationsStore.unreadCount > 99 ? '∞' : notificationsStore.unreadCount }}
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
  import { useUiStore } from '@/stores/ui'
  import { useAuthStore } from '@/stores/auth'
  import { useChatStore } from '@/stores/chat'
  import { useNotificationsStore } from '@/stores/notifications'
  import { Icon } from '@iconify/vue'

  import UserMenu from '@/components/UserMenu.vue'
  import Button from './widgets/Button.vue'
  import MobileMenu from './MobileMenu.vue'

  const ui = useUiStore()
  const authStore = useAuthStore()
  const chatStore = useChatStore()
  const notificationsStore = useNotificationsStore()
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
    @apply px-4 py-2 hidden md:block;
    @apply text-gray-600 hover:text-gray-900 font-medium transition-colors;
    @apply hover:bg-gray-100;
  }

  nav.transparent .nav-item {
    @apply text-white hover:text-gray-200;
    @apply hover:bg-black/20;
  }

  .search {
    @apply flex items-center space-x-2 collapse;
    @apply md:visible;
  }

  .notification-button,
  .chat-button {
    @apply relative p-2 rounded-lg transition-colors;
    @apply text-gray-400 hover:bg-gray-100;
  }

  nav.transparent .notification-button,
  nav.transparent .chat-button {
    @apply text-white text-gray-200 hover:bg-black/20;
  }

  .notification-icon,
  .chat-icon {
    @apply w-8 h-8;
  }

  .unread-badge {
    @apply block absolute w-6 h-6 -top-0 -right-0 flex items-center justify-center;
    @apply bg-red-500 text-white text-sm rounded-full font-medium leading-none;
  }
</style>
