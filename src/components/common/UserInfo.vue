<template>
  <div class="flex items-center space-x-2">
    <div class="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
      <UserIcon class="w-5 h-5 text-gray-600" />
    </div>
    <div class="text-sm">
      <p class="font-medium text-gray-900">{{ user?.full_name || 'Anonymous' }}</p>
      <p v-if="showEmail && user?.email" class="text-gray-500">{{ user.email }}</p>
      <p v-else-if="!showEmail" class="text-gray-500">Community Member</p>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { UserIcon } from '@heroicons/vue/24/outline'
  import type { User } from '@/types'

  interface Props {
    user?: User | null
    showEmail?: boolean
  }

  defineProps<Props>()
</script>
