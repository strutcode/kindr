<template>
  <div class="user-info">
    <img
      v-if="user.avatar_url"
      :src="user.avatar_url"
      :alt="user.full_name || 'User'"
      class="user-avatar"
    />
    <div v-else class="user-avatar-placeholder">
      <img :src="src" alt="User Avatar" />
    </div>
    <div class="user-details">
      <h4 class="user-name">{{ user.full_name || 'Anonymous User' }}</h4>
      <p class="user-email">{{ user.email }}</p>
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { Icon } from '@iconify/vue'
  import { createAvatar } from '@dicebear/core'
  import { dylan } from '@dicebear/collection'

  import { Listing } from '@/types'

  const props = defineProps<{
    user: Required<Listing>['user']
  }>()

  const avatar = createAvatar(dylan, {
    seed: props.user.id,
  })

  const svg = avatar.toString()
  const src = `data:image/svg+xml;utf8,${encodeURIComponent(svg)}`
</script>

<style scoped>
  .user-info {
    @apply flex items-center space-x-3;
  }

  .user-avatar {
    @apply w-10 h-10 rounded-full object-cover;
  }

  .user-avatar-placeholder {
    @apply w-10 h-10 overflow-hidden flex items-center justify-center;
    @apply rounded-full bg-gray-200 text-gray-400;
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
