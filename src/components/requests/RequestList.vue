<template>
  <div class="request-list">
    <!-- Loading State -->
    <div v-if="loading" class="space-y-4">
      <div v-for="i in 3" :key="i" class="bg-white rounded-lg border border-gray-200 p-6 animate-pulse">
        <div class="h-6 bg-gray-200 rounded mb-4 w-3/4" />
        <div class="h-4 bg-gray-200 rounded mb-2" />
        <div class="h-4 bg-gray-200 rounded mb-4 w-1/2" />
        <div class="flex space-x-2">
          <div class="h-6 bg-gray-200 rounded-full w-20" />
          <div class="h-6 bg-gray-200 rounded-full w-24" />
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else-if="requests.length === 0" class="bg-gray-50 rounded-lg border border-gray-200 p-12 text-center">
      <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
        <DocumentTextIcon class="w-8 h-8 text-gray-400" />
      </div>
      <h3 class="text-lg font-medium text-gray-900 mb-2">No requests to display</h3>
      <p class="text-gray-600 mb-6">
        {{ emptyMessage || 'No requests to display at this time' }}
      </p>
      <slot name="empty-action">
        <router-link 
          v-if="showCreateButton"
          to="/requests/create" 
          class="btn btn-primary"
        >
          <PlusIcon class="w-4 h-4 mr-2" />
          Create Request
        </router-link>
        <router-link 
          v-else
          to="/auth" 
          class="btn btn-primary"
        >
          <UserPlusIcon class="w-4 h-4 mr-2" />
          Join to Create Requests
        </router-link>
      </slot>
    </div>

    <!-- Requests Grid/List -->
    <div v-else :class="gridClass">
      <div 
        v-for="(request, index) in requests" 
        :key="request.id"
        class="request-item"
        :class="[
          'bg-white rounded-lg border border-gray-200 hover:shadow-md transition-shadow cursor-pointer',
          { 'ring-2 ring-primary-500': selectedRequestId === request.id },
          itemClass
        ]"
        @click="handleRequestClick(request, index)"
      >
        <!-- Map View: Compact Layout with Number Badge -->
        <div v-if="variant === 'map'" class="p-4">
          <div class="flex items-start justify-between mb-2">
            <h3 class="font-semibold text-gray-900 text-sm leading-tight">{{ request.title }}</h3>
            <span class="inline-flex items-center justify-center w-6 h-6 bg-primary-600 text-white text-xs font-bold rounded-full ml-2 flex-shrink-0">
              {{ index + 1 }}
            </span>
          </div>
          
          <p class="text-sm text-gray-600 mb-3 line-clamp-2">{{ request.description }}</p>
          
          <div class="flex flex-wrap gap-1 mb-3">
            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
              {{ getCategoryLabel(request.category) }}
            </span>
          </div>

          <div class="flex items-center justify-between text-sm text-gray-500">
            <div class="flex items-center space-x-1 min-w-0 flex-1">
              <MapPinIcon class="w-4 h-4 flex-shrink-0" />
              <span class="truncate">{{ request.location.address || 'Location provided' }}</span>
            </div>
            <span class="ml-2 flex-shrink-0">{{ formatRelativeTime(request.created_at) }}</span>
          </div>
        </div>

        <!-- List View: Full Layout -->
        <div v-else class="p-6">
          <RequestCard
            :request="request"
            :show-actions="showActions"
            @edit="$emit('edit', request)"
            @delete="$emit('delete', request)"
            @respond="$emit('respond', request)"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { formatDistanceToNow } from 'date-fns'
import { DocumentTextIcon, MapPinIcon, PlusIcon, UserPlusIcon } from '@heroicons/vue/24/outline'
import { CATEGORIES } from '@/constants/categories'
import { useAuthStore } from '@/stores/auth'
import RequestCard from './RequestCard.vue'
import type { Request } from '@/types'

interface Props {
  /** Array of request objects to display */
  requests: Request[]
  /** Loading state */
  loading?: boolean
  /** Display variant - affects layout and styling */
  variant?: 'list' | 'map'
  /** Custom empty state message */
  emptyMessage?: string
  /** Whether to show the create request button in empty state */
  showCreateButton?: boolean
  /** Whether to show action buttons on request cards (list variant only) */
  showActions?: boolean
  /** ID of currently selected request (for highlighting) */
  selectedRequestId?: string
  /** Additional CSS classes for the grid container */
  gridClass?: string
  /** Additional CSS classes for individual items */
  itemClass?: string
}

interface Emits {
  /** Emitted when a request is clicked */
  (e: 'request-click', request: Request, index: number): void
  /** Emitted when edit action is triggered (list variant only) */
  (e: 'edit', request: Request): void
  /** Emitted when delete action is triggered (list variant only) */
  (e: 'delete', request: Request): void
  /** Emitted when respond action is triggered (list variant only) */
  (e: 'respond', request: Request): void
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  variant: 'list',
  showCreateButton: true,
  showActions: true,
  gridClass: '',
  itemClass: '',
})

const emit = defineEmits<Emits>()
const authStore = useAuthStore()

const gridClass = computed(() => {
  if (props.gridClass) {
    return props.gridClass
  }
  
  // Default grid classes based on variant
  if (props.variant === 'map') {
    return 'grid md:grid-cols-2 lg:grid-cols-3 gap-4'
  }
  
  return 'space-y-4'
})

// Determine if create button should be shown based on auth status
const showCreateButton = computed(() => {
  return props.showCreateButton && authStore.isAuthenticated
})

const getCategoryLabel = (category: string) => {
  return CATEGORIES.find(cat => cat.value === category)?.label || category
}

const formatRelativeTime = (dateString: string) => {
  return formatDistanceToNow(new Date(dateString), { addSuffix: true })
}

const handleRequestClick = (request: Request, index: number) => {
  emit('request-click', request, index)
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.request-item {
  @apply transition-all duration-200;
}

.request-item:hover {
  @apply transform -translate-y-0.5;
}

/* Ensure consistent spacing in different variants */
.request-list .space-y-4 > * + * {
  margin-top: 1rem;
}

/* Map variant specific styles */
.request-list .grid .request-item {
  @apply h-full;
}

/* Responsive adjustments */
@media (max-width: 640px) {
  .request-list .grid {
    @apply grid-cols-1;
  }
}
</style>