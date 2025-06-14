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
          <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <DocumentTextIcon class="w-8 h-8 text-gray-400" />
          </div>
          <h4 class="text-lg font-medium text-gray-900 mb-2">No requests yet</h4>
          <p class="text-gray-600 mb-4">Create your first request to get started</p>
          <router-link to="/requests/create" class="btn btn-primary">
            Create Request
          </router-link>
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
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
                    {{ getCategoryLabel(request.category) }}
                  </span>
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                    {{ getSubcategoryLabel(request.category, request.subcategory) }}
                  </span>
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium" :class="getStatusColor(request.status)">
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

            <div class="flex items-center justify-between pt-4 border-t border-gray-100">
              <div class="flex space-x-2">
                <router-link
                  :to="`/requests/${request.id}/edit`"
                  class="btn btn-outline btn-sm"
                >
                  <PencilIcon class="w-4 h-4 mr-2" />
                  Edit
                </router-link>
                <button
                  @click="handleDeleteRequest(request)"
                  class="btn btn-outline btn-sm text-error-600 border-error-300 hover:bg-error-50"
                >
                  <TrashIcon class="w-4 h-4 mr-2" />
                  Delete
                </button>
              </div>
              
              <router-link
                :to="`/requests/${request.id}`"
                class="btn btn-primary btn-sm"
              >
                View Details
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { formatDistanceToNow } from 'date-fns'
import { PlusIcon, DocumentTextIcon, MapPinIcon, ClockIcon, PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'
import { useAuthStore } from '@/stores/auth'
import { useRequestsStore } from '@/stores/requests'
import { useReputationStore } from '@/stores/reputation'
import { CATEGORIES } from '@/constants/categories'
import UserProfileForm from '@/components/common/UserProfileForm.vue'
import ReputationBar from '@/components/common/ReputationBar.vue'
import type { Request, User } from '@/types'

const router = useRouter()
const authStore = useAuthStore()
const requestsStore = useRequestsStore()
const reputationStore = useReputationStore()

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

const getCategoryLabel = (category: string) => {
  return CATEGORIES.find(cat => cat.value === category)?.label || category
}

const getSubcategoryLabel = (category: string, subcategory: string) => {
  const cat = CATEGORIES.find(cat => cat.value === category)
  return cat?.subcategories.find(sub => sub.value === subcategory)?.label || subcategory
}

const getStatusColor = (status: string) => {
  switch (status) {
    case 'active':
      return 'bg-success-100 text-success-800'
    case 'in-progress':
      return 'bg-warning-100 text-warning-800'
    case 'completed':
      return 'bg-primary-100 text-primary-800'
    case 'cancelled':
      return 'bg-error-100 text-error-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
}

const formatRelativeTime = (dateString: string) => {
  return formatDistanceToNow(new Date(dateString), { addSuffix: true })
}

const handleProfileSuccess = (profile: User) => {
  console.log('Profile saved successfully:', profile)
  // The auth store will be automatically updated
}

const handleProfileError = (error: string) => {
  console.error('Profile error:', error)
  // Error is already displayed in the form component
}

const handleDeleteRequest = async (request: Request) => {
  if (!confirm('Are you sure you want to delete this request?')) return
  
  try {
    const result = await requestsStore.deleteRequest(request.id)
    if (result.error) {
      console.error('Error deleting request:', result.error)
    }
  } catch (error) {
    console.error('Error deleting request:', error)
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