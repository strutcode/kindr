<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Anonymous User Banner -->
    <div
      v-if="!authStore.isAuthenticated"
      class="bg-primary-50 border border-primary-200 rounded-lg p-4 mb-6"
    >
      <div class="flex items-start justify-between">
        <div class="flex items-start">
          <InformationCircleIcon class="w-5 h-5 text-primary-600 mt-0.5 mr-3 flex-shrink-0" />
          <div>
            <h3 class="text-sm font-medium text-primary-800">Viewing as Guest</h3>
            <p class="text-sm text-primary-700 mt-1">
              To respond to this request or contact the poster, please
              <router-link to="/auth" class="font-medium underline hover:no-underline">
                sign in or join the community </router-link
              >.
            </p>
          </div>
        </div>
        <router-link to="/auth" class="btn btn-primary btn-sm ml-4 flex-shrink-0">
          Join Community
        </router-link>
      </div>
    </div>

    <div v-if="loading" class="text-center py-12">
      <LoadingSpinner size="lg" text="Loading request..." />
    </div>

    <div v-else-if="error" class="text-center py-12">
      <div
        class="w-16 h-16 bg-error-100 rounded-full flex items-center justify-center mx-auto mb-4"
      >
        <ExclamationTriangleIcon class="w-8 h-8 text-error-600" />
      </div>
      <h3 class="text-lg font-medium text-gray-900 mb-2">Request not found</h3>
      <p class="text-gray-600 mb-6">{{ error }}</p>
      <router-link to="/requests" class="btn btn-primary"> Back to Requests </router-link>
    </div>

    <div v-else-if="request" class="space-y-8">
      <!-- Header -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
        <div class="flex items-start justify-between mb-6">
          <div class="flex-1">
            <h1 class="text-3xl font-bold text-gray-900 mb-4">{{ request.title }}</h1>

            <div class="flex flex-wrap items-center gap-3 mb-4">
              <span
                class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-primary-100 text-primary-800"
              >
                {{ getCategoryLabel(request.category) }}
              </span>
              <span
                class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-gray-100 text-gray-800"
              >
                {{ getSubcategoryLabel(request.category, request.subcategory) }}
              </span>
              <span
                v-if="request.duration_estimate"
                class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-accent-100 text-accent-800"
              >
                {{ getDurationLabel(request.duration_estimate) }}
              </span>
              <span
                class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"
                :class="getStatusColor(request.status)"
              >
                {{ request.status.charAt(0).toUpperCase() + request.status.slice(1) }}
              </span>
            </div>

            <div class="flex items-center text-sm text-gray-500 space-x-4 mb-4">
              <div class="flex items-center space-x-1">
                <MapPinIcon class="w-4 h-4" />
                <span>{{ request.location.address || 'Location provided' }}</span>
              </div>
              <div class="flex items-center space-x-1">
                <ClockIcon class="w-4 h-4" />
                <span>{{ formatRelativeTime(request.created_at) }}</span>
              </div>
            </div>

            <div v-if="request.compensation" class="text-secondary-600 font-medium mb-4">
              Compensation: {{ request.compensation }}
            </div>
          </div>

          <div class="ml-6 flex-shrink-0">
            <div class="flex items-center space-x-3">
              <div class="w-12 h-12 bg-gray-300 rounded-full flex items-center justify-center">
                <UserIcon class="w-6 h-6 text-gray-600" />
              </div>
              <div>
                <p class="font-medium text-gray-900">
                  {{ request.user?.full_name || 'Anonymous' }}
                </p>
                <!-- Hide email for anonymous users -->
                <p v-if="authStore.isAuthenticated" class="text-sm text-gray-500">
                  {{ request.user?.email }}
                </p>
                <p v-else class="text-sm text-gray-500">Community Member</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Images Gallery -->
        <div v-if="request.images && request.images.length > 0" class="mb-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-3">Images</h3>
          <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            <div
              v-for="(image, index) in request.images"
              :key="index"
              class="aspect-square bg-gray-100 rounded-lg overflow-hidden cursor-pointer hover:opacity-75 transition-opacity"
              @click="openImageModal(image, index)"
            >
              <img
                :src="image"
                :alt="`Request image ${index + 1}`"
                class="w-full h-full object-cover"
              />
            </div>
          </div>
        </div>

        <!-- Description -->
        <div class="prose max-w-none">
          <h3 class="text-lg font-semibold text-gray-900 mb-3">Description</h3>
          <p class="text-gray-700 whitespace-pre-wrap">{{ request.description }}</p>
        </div>

        <!-- Skills Required -->
        <div v-if="request.skills_required?.length" class="mt-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-3">Skills Required</h3>
          <div class="flex flex-wrap gap-2">
            <span
              v-for="skill in request.skills_required"
              :key="skill"
              class="inline-flex items-center px-3 py-1 rounded-md text-sm font-medium bg-secondary-100 text-secondary-800"
            >
              {{ skill }}
            </span>
          </div>
        </div>

        <!-- Actions -->
        <div v-if="canTakeAction" class="mt-8 pt-6 border-t border-gray-200">
          <div class="flex items-center justify-between">
            <!-- Owner Actions (Edit/Delete) -->
            <div v-if="authStore.isAuthenticated" class="flex space-x-3">
              <router-link
                v-if="canEdit"
                :to="`/requests/${request.id}/edit`"
                class="btn btn-outline"
              >
                <PencilIcon class="w-4 h-4 mr-2" />
                Edit Request
              </router-link>
              <button
                v-if="canDelete"
                @click="deleteRequest"
                class="btn btn-outline text-error-600 border-error-300 hover:bg-error-50"
              >
                <TrashIcon class="w-4 h-4 mr-2" />
                Delete Request
              </button>
            </div>

            <!-- Response Actions -->
            <div class="flex space-x-3">
              <!-- Authenticated User Response -->
              <button
                v-if="canRespond && authStore.isAuthenticated"
                @click="respondToRequest"
                class="btn btn-primary"
              >
                <ChatBubbleLeftIcon class="w-4 h-4 mr-2" />
                Respond to Request
              </button>

              <!-- Anonymous User Prompt -->
              <router-link
                v-else-if="canRespond && !authStore.isAuthenticated"
                :to="`/auth?redirect=/requests/${request.id}`"
                class="btn btn-primary"
              >
                <UserPlusIcon class="w-4 h-4 mr-2" />
                Sign In to Respond
              </router-link>
            </div>
          </div>
        </div>
      </div>

      <!-- User Reputation - Only show for authenticated users -->
      <div
        v-if="userReputation && authStore.isAuthenticated"
        class="bg-white rounded-lg shadow-sm border border-gray-200 p-6"
      >
        <h3 class="text-lg font-semibold text-gray-900 mb-4">User Reputation</h3>
        <ReputationBar :reputation="userReputation" />
      </div>

      <!-- Anonymous User Call-to-Action -->
      <div
        v-if="!authStore.isAuthenticated"
        class="bg-gradient-to-r from-primary-50 to-secondary-50 rounded-lg p-6 border border-primary-200"
      >
        <div class="text-center">
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Join the Kindr Community</h3>
          <p class="text-gray-600 mb-4">
            Connect with neighbors, offer help, and build stronger communities together.
          </p>
          <div class="flex flex-col sm:flex-row gap-3 justify-center">
            <router-link :to="`/auth?redirect=/requests/${request.id}`" class="btn btn-primary">
              Sign Up to Respond
            </router-link>
            <router-link to="/requests" class="btn btn-outline"> Browse More Requests </router-link>
          </div>
        </div>
      </div>
    </div>

    <!-- Image Modal -->
    <div
      v-if="selectedImage"
      class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4"
      @click="closeImageModal"
    >
      <div class="relative max-w-4xl max-h-full">
        <img
          :src="selectedImage.url"
          :alt="`Request image ${selectedImage.index + 1}`"
          class="max-w-full max-h-full object-contain"
        />
        <button
          @click="closeImageModal"
          class="absolute top-4 right-4 w-8 h-8 bg-black bg-opacity-50 hover:bg-opacity-75 rounded-full flex items-center justify-center text-white"
        >
          <XMarkIcon class="w-5 h-5" />
        </button>

        <!-- Navigation arrows for multiple images -->
        <div
          v-if="request && request.images && request.images.length > 1"
          class="absolute inset-y-0 left-4 flex items-center"
        >
          <button
            @click.stop="previousImage"
            class="w-10 h-10 bg-black bg-opacity-50 hover:bg-opacity-75 rounded-full flex items-center justify-center text-white"
          >
            <ChevronLeftIcon class="w-6 h-6" />
          </button>
        </div>
        <div
          v-if="request && request.images && request.images.length > 1"
          class="absolute inset-y-0 right-4 flex items-center"
        >
          <button
            @click.stop="nextImage"
            class="w-10 h-10 bg-black bg-opacity-50 hover:bg-opacity-75 rounded-full flex items-center justify-center text-white"
          >
            <ChevronRightIcon class="w-6 h-6" />
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { formatDistanceToNow } from 'date-fns'
  import {
    MapPinIcon,
    ClockIcon,
    UserIcon,
    PencilIcon,
    TrashIcon,
    ChatBubbleLeftIcon,
    ExclamationTriangleIcon,
    XMarkIcon,
    ChevronLeftIcon,
    ChevronRightIcon,
    InformationCircleIcon,
    UserPlusIcon,
  } from '@heroicons/vue/24/outline'
  import { useRequestsStore } from '@/stores/requests'
  import { useAuthStore } from '@/stores/auth'
  import { useReputationStore } from '@/stores/reputation'
  import { CATEGORIES, DURATION_OPTIONS } from '@/constants/categories'
  import LoadingSpinner from '@/components/common/LoadingSpinner.vue'
  import ReputationBar from '@/components/common/ReputationBar.vue'
  import type { Request } from '@/types'
  import { createLogger } from '@/lib/logger'

  const { debug, error } = createLogger('RequestDetails')

  const route = useRoute()
  const router = useRouter()
  const requestsStore = useRequestsStore()
  const authStore = useAuthStore()
  const reputationStore = useReputationStore()

  const request = ref<Request | null>(null)
  const loading = ref(true)
  const errorMessage = ref('')
  const selectedImage = ref<{ url: string; index: number } | null>(null)

  const userReputation = computed(() => {
    if (!request.value?.user_id) return null
    return reputationStore.getReputationDisplay(request.value.user_id)
  })

  const canEdit = computed(
    () => authStore.isAuthenticated && authStore.user?.id === request.value?.user_id,
  )

  const canDelete = computed(
    () => authStore.isAuthenticated && authStore.user?.id === request.value?.user_id,
  )

  const canRespond = computed(
    () => authStore.user?.id !== request.value?.user_id && request.value?.status === 'active',
  )

  const canTakeAction = computed(() => canEdit.value || canDelete.value || canRespond.value)

  const getCategoryLabel = (category: string) => {
    return CATEGORIES.find(cat => cat.value === category)?.label || category
  }

  const getSubcategoryLabel = (category: string, subcategory: string) => {
    const cat = CATEGORIES.find(cat => cat.value === category)
    return cat?.subcategories.find(sub => sub.value === subcategory)?.label || subcategory
  }

  const getDurationLabel = (duration: string) => {
    return DURATION_OPTIONS.find(opt => opt.value === duration)?.label || duration
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

  const openImageModal = (imageUrl: string, index: number) => {
    selectedImage.value = { url: imageUrl, index }
  }

  const closeImageModal = () => {
    selectedImage.value = null
  }

  const previousImage = () => {
    if (!selectedImage.value || !request.value?.images) return

    const currentIndex = selectedImage.value.index
    const newIndex = currentIndex > 0 ? currentIndex - 1 : request.value.images.length - 1
    selectedImage.value = {
      url: request.value.images[newIndex],
      index: newIndex,
    }
  }

  const nextImage = () => {
    if (!selectedImage.value || !request.value?.images) return

    const currentIndex = selectedImage.value.index
    const newIndex = currentIndex < request.value.images.length - 1 ? currentIndex + 1 : 0
    selectedImage.value = {
      url: request.value.images[newIndex],
      index: newIndex,
    }
  }

  const fetchRequest = async () => {
    const requestId = route.params.id as string
    loading.value = true
    errorMessage.value = ''

    try {
      // Use the new getRequestById method from the store
      const foundRequest = await requestsStore.getRequestById(requestId)

      if (!foundRequest) {
        errorMessage.value = 'Request not found'
        return
      }

      request.value = foundRequest

      // Fetch user reputation only for authenticated users
      if (foundRequest.user_id && authStore.isAuthenticated) {
        await reputationStore.fetchReputation(foundRequest.user_id)
      }
    } catch (err: any) {
      error('Error fetching request:', err)
      errorMessage.value = err.message || 'Failed to load request'
    } finally {
      loading.value = false
    }
  }

  const deleteRequest = async () => {
    if (!request.value || !confirm('Are you sure you want to delete this request?')) return

    try {
      const result = await requestsStore.deleteRequest(request.value.id)
      if (result.error) {
        error('Error deleting request:', result.error)
        return
      }
      router.push('/requests')
    } catch (err: any) {
      error('Error deleting request:', err)
    }
  }

  const respondToRequest = () => {
    // This would open a response modal or navigate to a response form
    debug('Responding to request:', request.value?.id)
  }

  onMounted(() => {
    fetchRequest()
  })
</script>

<style scoped>
  .aspect-square {
    aspect-ratio: 1 / 1;
  }
</style>
