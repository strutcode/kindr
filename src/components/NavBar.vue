<template>
  <nav :class="{ fadeOut: ui.header.fade }">
    <router-link to="/">
      <img class="h-8 w-auto" src="@/assets/logo.svg" alt="Kindr" />
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

    <UserMenu />
  </nav>
</template>

<script setup lang="ts">
  import { ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { useUiStore } from '@/stores/ui'

  import UserMenu from '@/components/UserMenu.vue'
  import Button from './widgets/Button.vue'
  import Text from './widgets/Text.vue'

  const query = ref('')
  const router = useRouter()
  const ui = useUiStore()
</script>

<style scoped>
  nav {
    @apply bg-white shadow-md flex items-center justify-between px-4 py-2 relative z-10;
  }

  .nav-item {
    @apply text-gray-600 hover:text-gray-900 font-medium transition-colors px-4 py-2;
  }

  .nav-item:hover {
    @apply bg-gray-50 rounded-md;
  }

  .search {
    @apply flex items-center space-x-2;
  }
</style>
