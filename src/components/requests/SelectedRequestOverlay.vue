<template>
  <div v-if="selectedRequestProp" class="mapview-request-details-overlay">
    <div class="flex items-start justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-900">Selected Request</h3>
      <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600">
        <XMarkIcon class="w-5 h-5" />
      </button>
    </div>

    <div class="grid md:grid-cols-2 gap-6">
      <div>
        <h4 class="font-semibold text-gray-900 mb-2">
          {{ selectedRequestProp.title }}
        </h4>
        <p class="text-gray-600 mb-4">{{ selectedRequestProp.description }}</p>

        <div class="flex flex-wrap gap-2 mb-4">
          <span
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800"
          >
            {{ getCategoryLabelProp(selectedRequestProp.category) }}
          </span>
          <span
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
          >
            {{
              getSubcategoryLabelProp(selectedRequestProp.category, selectedRequestProp.subcategory)
            }}
          </span>
          <span
            v-if="selectedRequestProp.duration_estimate"
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-accent-100 text-accent-800"
          >
            {{ getDurationLabelProp(selectedRequestProp.duration_estimate) }}
          </span>
          <span
            v-if="selectedRequestProp.distance_meters"
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-secondary-100 text-secondary-800"
          >
            {{ formatDistanceProp(selectedRequestProp.distance_meters) }}
          </span>
        </div>

        <div class="flex items-center text-sm text-gray-500 space-x-4">
          <div class="flex items-center space-x-1">
            <MapPinIcon class="w-4 h-4" />
            <span>{{ selectedRequestProp.location.address || 'Location provided' }}</span>
          </div>
          <div class="flex items-center space-x-1">
            <ClockIcon class="w-4 h-4" />
            <span>{{ formatRelativeTimeProp(selectedRequestProp.created_at) }}</span>
          </div>
        </div>
      </div>

      <div class="flex flex-col justify-between">
        <div>
          <div class="flex items-center space-x-3 mb-4">
            <div class="w-10 h-10 bg-gray-300 rounded-full flex items-center justify-center">
              <UserIcon class="w-6 h-6 text-gray-600" />
            </div>
            <div>
              <p class="font-medium text-gray-900">
                {{ selectedRequestProp.user?.full_name || 'Anonymous' }}
              </p>
              <!-- Hide email for anonymous users -->
              <p v-if="authStore.isAuthenticated" class="text-sm text-gray-500">
                {{ selectedRequestProp.user?.email }}
              </p>
              <p v-else class="text-sm text-gray-500">Community Member</p>
            </div>
          </div>

          <div v-if="selectedRequestProp.compensation" class="text-secondary-600 font-medium mb-4">
            Compensation: {{ selectedRequestProp.compensation }}
          </div>
        </div>

        <div class="flex space-x-3">
          <button
            @click="router.push(`/requests/${selectedRequestProp.id}`)"
            class="btn btn-primary flex-1"
          >
            View Details
          </button>
          <!-- Authenticated user response -->
          <button
            v-if="canRespondProp(selectedRequestProp) && authStore.isAuthenticated"
            @click="handleRespond(selectedRequestProp)"
            class="btn btn-secondary flex-1"
          >
            Respond
          </button>
          <!-- Anonymous user prompt -->
          <router-link
            v-else-if="canRespondProp(selectedRequestProp) && !authStore.isAuthenticated"
            :to="`/auth?redirect=/requests/${selectedRequestProp.id}`"
            class="btn btn-secondary flex-1"
          >
            Sign In to Respond
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { useRouter } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'
  import { XMarkIcon, MapPinIcon, ClockIcon, UserIcon } from '@heroicons/vue/24/outline'
  import type { RequestWithDistance } from '@/services/spatialQueries'

  const props = defineProps<{
    selectedRequest: RequestWithDistance | null
    getCategoryLabel: (cat: string) => string
    getSubcategoryLabel: (cat: string, sub: string) => string
    getDurationLabel: (duration: any) => string
    formatRelativeTime: (date: string) => string
    formatDistance: (meters: number) => string
    canRespond: (request: RequestWithDistance) => boolean
  }>()

  const emit = defineEmits(['close'])

  const router = useRouter()
  const authStore = useAuthStore()

  // Expose props to template with unique names to avoid shadowing
  const selectedRequestProp = props.selectedRequest
  const getCategoryLabelProp = props.getCategoryLabel
  const getSubcategoryLabelProp = props.getSubcategoryLabel
  const getDurationLabelProp = props.getDurationLabel
  const formatRelativeTimeProp = props.formatRelativeTime
  const formatDistanceProp = props.formatDistance
  const canRespondProp = props.canRespond

  function handleRespond(request: RequestWithDistance) {
    if (!authStore.isAuthenticated) {
      router.push(`/auth?redirect=/requests/${request.id}`)
      return
    }
    router.push(`/requests/${request.id}`)
  }
</script>

<style scoped>
  .mapview-request-details-overlay {
    position: absolute;
    right: 400px;
    top: 80px;
    z-index: 30;
    background: white;
    border-radius: 0.75rem;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
    padding: 2rem;
    max-width: 420px;
  }
</style>
