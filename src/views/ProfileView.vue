<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Profile Form -->
    <UserProfileForm
      :existing-profile="authStore.user"
      @success="handleProfileSuccess"
      @error="handleProfileError"
    />

    <!-- Reputation Section -->
    <div v-if="authStore.user" class="mt-8">
      <div class="card">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Your Reputation</h3>
        <ReputationBar :reputation="userReputation" />
      </div>
    </div>

    <!-- My Requests Section -->
    <div v-if="authStore.user" class="mt-8">
      <div class="card">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-semibold text-gray-900">My Listings</h3>
          <Button icon-left="tabler:plus" :link="{ name: 'create' }"> Create Listing </Button>
        </div>

        <div v-if="loading" class="flex flex-col items-center py-8">
          <Icon icon="svg-spinners:3-dots-bounce" class="w-12 h-12 text-primary-400 mb-4" />
          <p class="text-gray-500">Loading your listings...</p>
        </div>

        <div v-else-if="listingsStore.userListings.length === 0" class="text-center py-8">
          <div
            class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4"
          >
            <Icon icon="tabler:file-broken" class="w-8 h-8 text-gray-400" />
          </div>
          <h4 class="text-lg font-medium text-gray-900 mb-2">No listings yet</h4>
          <p class="text-gray-600 mb-4">Create your first listing to get started</p>
        </div>

        <div v-else class="space-y-4">
          <ListingMini v-for="listing in listingsStore.userListings" :listing="listing" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, onMounted, ref } from 'vue'
  import { useAuthStore } from '@/stores/auth'
  import { useListingsStore } from '@/stores/listings'
  import { useReputationStore } from '@/stores/reputation'
  import UserProfileForm from '@/components/common/UserProfileForm.vue'
  import ReputationBar from '@/components/common/ReputationBar.vue'
  import type { User } from '@/types'
  import { createLogger } from '@/lib/logger'
  import { Icon } from '@iconify/vue'
  import Button from '@/components/widgets/Button.vue'
  import ListingMini from '@/components/listings/ListingMini.vue'

  const { debug, error } = createLogger('ProfileView')

  const authStore = useAuthStore()
  const listingsStore = useListingsStore()
  const reputationStore = useReputationStore()
  const loading = ref(false)

  const userReputation = computed(() => {
    if (!authStore.user) {
      return {
        status: 'unknown' as const,
        positive: 0,
        negative: 0,
        total: 0,
        positivePercentage: 0,
        negativePercentage: 0,
        unknownPercentage: 100,
      }
    }
    return reputationStore.getReputationDisplay(authStore.user.id)
  })

  const handleProfileSuccess = (profile: User) => {
    debug('Profile saved successfully:', profile)
    // The auth store will be automatically updated
  }

  const handleProfileError = (error: unknown) => {
    if (error instanceof Error) {
      console.error('Profile error:', error.message)
    } else {
      console.error('Profile error:', error)
    }
  }

  onMounted(async () => {
    if (authStore.user) {
      loading.value = true

      try {
        // Fetch user's requests and reputation
        await Promise.all([
          listingsStore.fetchUserListings(authStore.user.id),
          reputationStore.fetchReputation(authStore.user.id),
        ])
      } catch (err) {
        error('Error fetching user data:', err)
      } finally {
        loading.value = false
      }
    }
  })
</script>

<style scoped>
  .card {
    @apply bg-white rounded-lg shadow-sm border border-gray-200 p-6;
  }
</style>
