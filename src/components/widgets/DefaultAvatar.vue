<template>
  <div class="user-avatar-placeholder">
    <img :src="src" alt="User Avatar" />
  </div>
</template>

<script lang="ts" setup>
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
  .user-avatar-placeholder {
    @apply w-10 h-10 flex items-center justify-center;
    @apply rounded-full bg-gray-200 text-gray-400;
  }

  img {
    @apply w-full h-full object-cover rounded-full;
  }
</style>
