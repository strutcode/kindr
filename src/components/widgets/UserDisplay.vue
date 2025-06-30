<template>
  <div class="user-display">
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
    <ReputationBar :reputation="reputation" />
  </div>
</template>

<script lang="ts" setup>
  import { Listing } from '@/types'
  import DefaultAvatar from './DefaultAvatar.vue'
  import { useReputationStore } from '@/stores/reputation'
  import ReputationBar from '../common/ReputationBar.vue'
  import { computed } from 'vue'

  const props = defineProps<{
    user: Required<Listing>['user']
  }>()

  const reputationStore = useReputationStore()

  const reputation = computed(() => reputationStore.getReputationDisplay(props.user.id))

  if (props.user) {
    // Fetch reputation data for the user when the listing is loaded
    reputationStore.fetchReputation(props.user.id)
  }
</script>

<style scoped>
  .user-display {
    @apply flex items-center justify-between p-4 bg-white rounded-lg shadow-sm;
  }

  .user-info {
    @apply flex items-center space-x-3 w-full;
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
