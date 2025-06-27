<template>
  <div class="user-menu" v-if="auth.user" @click="toggleMenu">
    <div class="user-info">
      <img v-if="avatar" :src="avatar" alt="User Avatar" class="avatar" />
      <div v-else class="avatar bg-gray-200 flex items-center justify-center text-gray-500">
        <span class="text-lg">{{ auth.user.full_name?.charAt(0) }}</span>
      </div>
      <Icon icon="mdi:chevron-down" class="ml-2 text-gray-500" />
    </div>
    <ul class="menu-items" v-show="menu">
      <li @click="router.push({ name: 'create' })">New Listing</li>
      <li @click="router.push({ name: 'profile' })">Profile</li>
      <li @click="auth.signOut">Logout</li>
    </ul>
  </div>
  <div v-else-if="auth.loading" class="text-center">
    <p class="text-gray-600">Loading user info...</p>
  </div>
  <div v-else class="text-center">
    <Button @click="router.push({ name: 'auth' })" class="w-full">Login / Signup</Button>
  </div>
</template>

<script setup lang="ts">
  import { computed, ref } from 'vue'
  import { useAuthStore } from '@/stores/auth'
  import { useRouter } from 'vue-router'
  import { Icon } from '@iconify/vue'

  import Button from './widgets/Button.vue'

  const router = useRouter()
  const auth = useAuthStore()
  const menu = ref(false)

  const toggleMenu = () => {
    menu.value = !menu.value
  }

  const avatar = computed(() => {
    return auth.user?.avatar_url
  })
</script>

<style scoped>
  .user-menu {
    @apply relative right-0 cursor-pointer;
  }

  .user-info {
    @apply flex items-center p-2;
    @apply hover:bg-gray-100 rounded-md;
  }

  .avatar {
    @apply w-8 h-8 rounded-full;
  }

  .username {
    @apply text-gray-800 font-semibold;
  }

  .menu-items {
    @apply bg-white;
    @apply min-w-48 space-y-1 absolute right-0 top-full;
    @apply shadow-lg rounded-md border border-gray-200;
  }

  .menu-items li {
    @apply px-4 py-2 cursor-pointer transition text-gray-700;
    @apply hover:text-gray-800 hover:bg-gray-100;
  }
</style>
