<template>
  <div class="cluster-popup">
    <!-- Popup Overlay -->
    <div 
      v-if="isVisible"
      class="fixed inset-0 bg-black bg-opacity-25 z-50 flex items-center justify-center p-4"
      @click="handleOverlayClick"
    >
      <!-- Popup Content -->
      <div 
        ref="popupContent"
        class="bg-white rounded-lg shadow-xl border border-gray-200 max-w-2xl w-full max-h-[80vh] overflow-hidden"
        @click.stop
      >
        <!-- Header -->
        <div class="flex items-center justify-between p-4 border-b border-gray-200 bg-gray-50">
          <div class="flex items-center space-x-3">
            <div 
              class="w-8 h-8 rounded-full flex items-center justify-center text-white font-bold text-sm"
              :style="{ backgroundColor: clusterColor.background }"
            >
              {{ formatCount(requests.length) }}
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-900">
                {{ requests.length }} Requests in this Area
              </h3>
              <p class="text-sm text-gray-600">
                Click any request to view details
              </p>
            </div>
          </div>
          <button 
            @click="close"
            class="p-2 hover:bg-gray-200 rounded-full transition-colors"
          >
            <XMarkIcon class="w-5 h-5 text-gray-500" />
          </button>
        </div>

        <!-- Filters -->
        <div v-if="showFilters" class="p-4 border-b border-gray-200 bg-gray-50">
          <div class="flex flex-wrap items-center gap-3">
            <select 
              v-model="filterCategory"
              class="text-sm border border-gray-300 rounded-md px-3 py-1 bg-white"
            >
              <option value="">All Categories</option>
              <option 
                v-for="category in availableCategories" 
                :key="category.value" 
                :value="category.value"
              >
                {{ category.label }}
              </option>
            </select>
            
            <select 
              v-model="sortBy"
              class="text-sm border border-gray-300 rounded-md px-3 py-1 bg-white"
            >
              <option value="distance">Sort by Distance</option>
              <option value="date">Sort by Date</option>
              <option value="category">Sort by Category</option>
            </select>

            <span class="text-sm text-gray-500">
              {{ filteredRequests.length }} of {{ requests.length }} shown
            </span>
          </div>
        </div>

        <!-- Request List -->
        <div class="overflow-y-auto max-h-96">
          <div v-if="filteredRequests.length === 0" class="p-8 text-center">
            <DocumentTextIcon class="w-12 h-12 text-gray-400 mx-auto mb-3" />
            <p class="text-gray-600">No requests match your filters</p>
          </div>
          
          <div v-else class="divide-y divide-gray-200">
            <div 
              v-for="(request, index) in filteredRequests" 
              :key="request.id"
              class="p-4 hover:bg-gray-50 cursor-pointer transition-colors"
              @click="handleRequestClick(request)"
            >
              <div class="flex items-start justify-between">
                <div class="flex-1 min-w-0">
                  <!-- Request Title and Category -->
                  <div class="flex items-center space-x-2 mb-2">
                    <h4 class="font-medium text-gray-900 truncate">{{ request.title }}</h4>
                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800 flex-shrink-0">
                      {{ getCategoryLabel(request.category) }}
                    </span>
                  </div>

                  <!-- Description -->
                  <p class="text-sm text-gray-600 line-clamp-2 mb-2">{{ request.description }}</p>

                  <!-- Meta Information -->
                  <div class="flex items-center space-x-4 text-xs text-gray-500">
                    <div class="flex items-center space-x-1">
                      <ClockIcon class="w-3 h-3" />
                      <span>{{ formatRelativeTime(request.created_at) }}</span>
                    </div>
                    <div v-if="request.distance_meters" class="flex items-center space-x-1">
                      <MapPinIcon class="w-3 h-3" />
                      <span>{{ formatDistance(request.distance_meters) }}</span>
                    </div>
                    <div v-if="request.compensation" class="flex items-center space-x-1">
                      <CurrencyDollarIcon class="w-3 h-3" />
                      <span class="text-secondary-600 font-medium">{{ request.compensation }}</span>
                    </div>
                  </div>
                </div>

                <!-- Action Button -->
                <div class="ml-4 flex-shrink-0">
                  <button 
                    @click.stop="handleRequestClick(request)"
                    class="btn btn-outline btn-sm"
                  >
                    View
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer Actions -->
        <div class="p-4 border-t border-gray-200 bg-gray-50">
          <div class="flex items-center justify-between">
            <button 
              @click="zoomToFit"
              class="btn btn-outline btn-sm"
            >
              <MagnifyingGlassIcon class="w-4 h-4 mr-2" />
              Zoom to Fit All
            </button>
            
            <div class="flex space-x-2">
              <button 
                @click="toggleFilters"
                class="btn btn-outline btn-sm"
              >
                <AdjustmentsHorizontalIcon class="w-4 h-4 mr-2" />
                {{ showFilters ? 'Hide' : 'Show' }} Filters
              </button>
              <button 
                @click="close"
                class="btn btn-primary btn-sm"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { formatDistanceToNow } from 'date-fns'
import { 
  XMarkIcon, 
  ClockIcon, 
  MapPinIcon, 
  CurrencyDollarIcon,
  DocumentTextIcon,
  MagnifyingGlassIcon,
  AdjustmentsHorizontalIcon
} from '@heroicons/vue/24/outline'
import { CATEGORIES } from '@/constants/categories'
import { MapClusteringService } from '@/services/mapClustering'
import type { RequestWithDistance } from '@/services/spatialQueries'

interface Props {
  /** Array of requests in the cluster */
  requests: RequestWithDistance[]
  /** Whether the popup is visible */
  isVisible: boolean
  /** Cluster position for positioning */
  position?: { x: number; y: number }
}

interface Emits {
  /** Emitted when popup should be closed */
  (e: 'close'): void
  /** Emitted when a request is clicked */
  (e: 'request-click', request: RequestWithDistance): void
  /** Emitted when zoom to fit is requested */
  (e: 'zoom-to-fit', requests: RequestWithDistance[]): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

// Refs
const popupContent = ref<HTMLElement>()
const filterCategory = ref('')
const sortBy = ref<'distance' | 'date' | 'category'>('distance')
const showFilters = ref(false)

// Computed properties
const clusterColor = computed(() => 
  MapClusteringService.getClusterColor(props.requests.length)
)

const availableCategories = computed(() => {
  const usedCategories = new Set(props.requests.map(r => r.category))
  return CATEGORIES.filter(cat => usedCategories.has(cat.value))
})

const filteredRequests = computed(() => {
  let filtered = [...props.requests]

  // Apply category filter
  if (filterCategory.value) {
    filtered = filtered.filter(req => req.category === filterCategory.value)
  }

  // Apply sorting
  switch (sortBy.value) {
    case 'distance':
      filtered.sort((a, b) => (a.distance_meters || 0) - (b.distance_meters || 0))
      break
    case 'date':
      filtered.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
      break
    case 'category':
      filtered.sort((a, b) => a.category.localeCompare(b.category))
      break
  }

  return filtered
})

// Methods
const formatCount = (count: number): string => {
  return MapClusteringService.formatClusterCount(count)
}

const getCategoryLabel = (category: string): string => {
  return CATEGORIES.find(cat => cat.value === category)?.label || category
}

const formatRelativeTime = (dateString: string): string => {
  return formatDistanceToNow(new Date(dateString), { addSuffix: true })
}

const formatDistance = (meters: number): string => {
  const miles = meters / 1609.34
  if (miles < 0.1) {
    return `${Math.round(meters)} m`
  } else if (miles < 1) {
    return `${(miles * 5280).toFixed(0)} ft`
  } else {
    return `${miles.toFixed(1)} mi`
  }
}

const handleOverlayClick = () => {
  close()
}

const handleRequestClick = (request: RequestWithDistance) => {
  emit('request-click', request)
  close()
}

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const zoomToFit = () => {
  emit('zoom-to-fit', filteredRequests.value)
  close()
}

const close = () => {
  emit('close')
}

// Handle escape key
const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape' && props.isVisible) {
    close()
  }
}

// Lifecycle
onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})

// Watch for visibility changes to reset filters
watch(() => props.isVisible, (isVisible) => {
  if (isVisible) {
    // Reset filters when popup opens
    filterCategory.value = ''
    sortBy.value = 'distance'
    showFilters.value = false
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

/* Custom scrollbar for the request list */
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: #f1f5f9;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

/* Animation for popup */
.cluster-popup {
  animation: fadeIn 0.2s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

/* Responsive adjustments */
@media (max-width: 640px) {
  .cluster-popup .max-w-2xl {
    max-width: calc(100vw - 2rem);
  }
  
  .cluster-popup .max-h-96 {
    max-height: 60vh;
  }
}
</style>