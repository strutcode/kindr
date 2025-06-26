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

    <UserMenu class="collapse md:visible" />

    <MobileMenu class="md:hidden" />
  </nav>
</template>

<script setup lang="ts">
  import { ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { useUiStore } from '@/stores/ui'

  import UserMenu from '@/components/UserMenu.vue'
  import Button from './widgets/Button.vue'
  import Text from './widgets/Text.vue'
  import MobileMenu from './MobileMenu.vue'

  const query = ref('')
  const router = useRouter()
  const ui = useUiStore()
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
</style>
