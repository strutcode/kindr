<template>
  <div class="user-info">
    <img
      v-if="user.avatar_url"
      :src="user.avatar_url"
      :alt="user.full_name || 'User'"
      class="user-avatar"
    />
    <DefaultAvatar v-else :user="user" />
    <div class="user-details">
      <h4 class="user-name">{{ user.full_name || 'Anonymous User' }}</h4>
      <p class="user-email">{{ user.email }}</p>
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { Listing } from '@/types'
  import DefaultAvatar from './DefaultAvatar.vue'

  defineProps<{
    user: Required<Listing>['user']
  }>()
</script>

<style scoped>
  .user-info {
    @apply flex items-center space-x-3;
  }

  .user-avatar {
    @apply w-10 h-10 rounded-full object-cover;
  }

  .user-details {
    @apply flex-1;
  }

  .user-name {
    @apply font-medium text-gray-900;
  }

  .user-email {
    @apply text-sm text-gray-600;
  }
</style>
