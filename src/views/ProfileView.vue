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
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Your Reputation</h3>
        <ReputationBar :reputation="userReputation" />
      </div>
    </div>

    <!-- My Requests Section -->
    <div v-if="authStore.user" class="mt-8">
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-semibold text-gray-900">My Requests</h3>
          <router-link to="/requests/create" class="btn btn-primary btn-sm">
            <PlusIcon class="w-4 h-4 mr-2" />
            Create Request
          </router-link>
        </div>

        <div v-if="requestsStore.loading" class="space-y-4">
          <div v-for="i in 3" :key="i" class="bg-gray-50 rounded-lg p-4 animate-pulse">
            <div class="h-4 bg-gray-200 rounded mb-2 w-3/4" />
            <div class="h-3 bg-gray-200 rounded w-1/2" />
          </div>
        </div>

        <div v-else-if="requestsStore.userRequests.length === 0" class="text-center py-8">
          <div
            class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4"
          >
            <DocumentTextIcon class="w-8 h-8 text-gray-400" />
          </div>
          <h4 class="text-lg font-medium text-gray-900 mb-2">No requests yet</h4>
          <p class="text-gray-600 mb-4">Create your first request to get started</p>
          <router-link to="/requests/create" class="btn btn-primary"> Create Request </router-link>
        </div>

        <div v-else class="space-y-4">
          <div
            v-for="request in requestsStore.userRequests"
            :key="request.id"
            class="bg-white rounded-lg border border-gray-200 p-6 hover:shadow-md transition-shadow"
          >
            <div class="flex items-start justify-between mb-4">
              <div class="flex-1">
                <h4 class="text-lg font-semibold text-gray-900 mb-2">{{ request.title }}</h4>
                <p class="text-gray-600 text-sm mb-3 line-clamp-2">{{ request.description }}</p>

                <div class="flex flex-wrap items-center gap-2 mb-3">
                  <span
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800"
                  >
                    {{ getCategoryLabel(request.category) }}
                  </span>
                  <span
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
                  >
                    {{ getSubcategoryLabel(request.category, request.subcategory) }}
                  </span>
                  <span
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                    :class="getStatusColor(request.status)"
                  >
                    {{ request.status.charAt(0).toUpperCase() + request.status.slice(1) }}
                  </span>
                </div>

                <div class="flex items-center text-sm text-gray-500 space-x-4">
                  <div class="flex items-center space-x-1">
                    <MapPinIcon class="w-4 h-4" />
                    <span>{{ request.location.address || 'Location provided' }}</span>
                  </div>
                  <div class="flex items-center space-x-1">
                    <ClockIcon class="w-4 h-4" />
                    <span>{{ formatRelativeTime(request.created_at) }}</span>
                  </div>
                </div>
              </div>
            </div>

            <RequestActions
              :request="request"
              class="flex items-center justify-between pt-4 border-t border-gray-100"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, onMounted } from 'vue'
  import { useAuthStore } from '@/stores/auth'
  import { useRequestsStore } from '@/stores/requests'
  import { useReputationStore } from '@/stores/reputation'
  import { useRequestFormatting } from '@/composables/useRequestFormatting'
  import { CATEGORIES } from '@/constants/categories'
  import UserProfileForm from '@/components/common/UserProfileForm.vue'
  import ReputationBar from '@/components/common/ReputationBar.vue'
  import RequestActions from '@/components/common/RequestActions.vue'
  import { useStatusColor } from '@/composables/useStatusColor'
  import type { Request, User } from '@/types'
  import { createLogger } from '@/lib/logger'
  import { PlusIcon, DocumentTextIcon, MapPinIcon, ClockIcon } from '@heroicons/vue/24/outline'

  const { debug, error } = createLogger('ProfileView')

  const authStore = useAuthStore()
  const requestsStore = useRequestsStore()
  const reputationStore = useReputationStore()
  const { getCategoryLabel, getSubcategoryLabel, formatRelativeTime } = useRequestFormatting()
  const { getStatusColor } = useStatusColor()

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

  const handleDeleteRequest = async (request: Request) => {
    if (!confirm('Are you sure you want to delete this request?')) return

    try {
      const result = await requestsStore.deleteRequest(request.id)
      if (result.error) {
        console.error('Error deleting request:', result.error)
      }
    } catch (error) {
      if (error instanceof Error) {
        console.error('Error deleting request:', error.message)
      } else {
        console.error('Error deleting request:', error)
      }
    }
  }

  onMounted(async () => {
    if (authStore.user) {
      // Fetch user's requests and reputation
      await Promise.all([
        requestsStore.fetchUserRequests(authStore.user.id),
        reputationStore.fetchReputation(authStore.user.id),
      ])
    }
  })
</script>

<style scoped>
  .line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
</style>
