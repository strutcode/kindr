<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Anonymous User Banner -->
    <div
      v-if="!authStore.isAuthenticated"
      class="bg-primary-50 border border-primary-200 rounded-lg p-4 mb-6"
    >
      <div class="flex items-start justify-between">
        <div class="flex items-start">
          <InformationCircleIcon class="w-5 h-5 text-primary-600 mt-0.5 mr-3 flex-shrink-0" />
          <div>
            <h3 class="text-sm font-medium text-primary-800">Browsing as Guest</h3>
            <p class="text-sm text-primary-700 mt-1">
              You can view all community requests on the map.
              <router-link to="/auth" class="font-medium underline hover:no-underline">
                Sign in or join
              </router-link>
              to create requests and respond to others.
            </p>
          </div>
        </div>
        <router-link to="/auth" class="btn btn-primary btn-sm ml-4 flex-shrink-0">
          Join Community
        </router-link>
      </div>
    </div>

    <!-- Filters and Controls -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-4 mb-6">
      <div class="flex flex-wrap items-center gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Category</label>
          <select v-model="filters.category" class="input w-48" @change="handleFiltersChange">
            <option value="">All Categories</option>
            <option v-for="category in CATEGORIES" :key="category.value" :value="category.value">
              {{ category.label }}
            </option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Subcategory</label>
          <select
            v-model="filters.subcategory"
            class="input w-48"
            :disabled="!filters.category"
            @change="handleFiltersChange"
          >
            <option value="">All Subcategories</option>
            <option
              v-for="subcategory in selectedCategorySubcategories"
              :key="subcategory.value"
              :value="subcategory.value"
            >
              {{ subcategory.label }}
            </option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Clustering</label>
          <div class="flex items-center space-x-4">
            <label class="flex items-center">
              <input
                v-model="clusteringEnabled"
                type="checkbox"
                class="rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                @change="handleClusteringToggle"
              />
              <span class="ml-2 text-sm text-gray-700">Enable clustering</span>
            </label>
            <div v-if="clusteringEnabled" class="flex items-center space-x-2">
              <label class="text-sm text-gray-600">Radius:</label>
              <input
                v-model.number="clusteringOptions.radius"
                type="range"
                min="30"
                max="100"
                step="10"
                class="w-20"
                @input="handleClusteringOptionsChange"
              />
              <span class="text-sm text-gray-500">{{ clusteringOptions.radius }}px</span>
            </div>
          </div>
        </div>

        <div class="flex items-end space-x-2">
          <button @click="clearFilters" class="btn btn-outline">Clear Filters</button>

          <button @click="refreshRequests" :disabled="isLoading" class="btn btn-secondary">
            <ArrowPathIcon class="w-4 h-4 mr-2" :class="{ 'animate-spin': isLoading }" />
            Refresh
          </button>

          <button
            @click="fitToAllMarkers"
            :disabled="filteredRequests.length === 0"
            class="btn btn-outline"
          >
            <MagnifyingGlassIcon class="w-4 h-4 mr-2" />
            Fit All
          </button>
        </div>
      </div>
    </div>

    <!-- Location Status Banner -->
    <div
      v-if="locationStatus === 'fallback'"
      class="bg-warning-50 border border-warning-200 rounded-lg p-4 mb-6"
    >
      <div class="flex items-start">
        <ExclamationTriangleIcon class="w-5 h-5 text-warning-600 mt-0.5 mr-3 flex-shrink-0" />
        <div class="flex-1">
          <h3 class="text-sm font-medium text-warning-800">Using Default Location</h3>
          <p class="text-sm text-warning-700 mt-1">
            We couldn't access your precise location, so we're showing requests around Los Angeles,
            CA.
            <button @click="requestLocation" class="font-medium underline hover:no-underline">
              Try enabling location again
            </button>
          </p>
        </div>
      </div>
    </div>

    <!-- Map Container -->
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden mb-8">
      <DynamicMap
        v-if="userLocation"
        :pins="mapPins"
        :min-height="500"
        :initial-position="userLocation"
        :initial-zoom="12"
        :show-map-info="true"
        :enable-bounds-queries="true"
        :bounds-change-delay="300"
        :enable-clustering="clusteringEnabled"
        :clustering-options="clusteringOptions"
        @pin-click="handlePinClick"
        @map-click="handleMapClick"
        @bounds-change="handleBoundsChange"
        @view-change="handleViewChange"
        @map-ready="handleMapReady"
        ref="mapComponent"
      />
    </div>

    <!-- Selected Request Details -->
    <div
      v-if="selectedRequest"
      class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8"
    >
      <div class="flex items-start justify-between mb-4">
        <h3 class="text-lg font-semibold text-gray-900">Selected Request</h3>
        <button @click="selectedRequest = null" class="text-gray-400 hover:text-gray-600">
          <XMarkIcon class="w-5 h-5" />
        </button>
      </div>

      <div class="grid md:grid-cols-2 gap-6">
        <div>
          <h4 class="font-semibold text-gray-900 mb-2">
            {{ selectedRequest.title }}
          </h4>
          <p class="text-gray-600 mb-4">{{ selectedRequest.description }}</p>

          <div class="flex flex-wrap gap-2 mb-4">
            <span
              class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800"
            >
              {{ getCategoryLabel(selectedRequest.category) }}
            </span>
            <span
              class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
            >
              {{ getSubcategoryLabel(selectedRequest.category, selectedRequest.subcategory) }}
            </span>
            <span
              v-if="selectedRequest.duration_estimate"
              class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-accent-100 text-accent-800"
            >
              {{ getDurationLabel(selectedRequest.duration_estimate) }}
            </span>
            <span
              v-if="selectedRequest.distance_meters"
              class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-secondary-100 text-secondary-800"
            >
              {{ formatDistance(selectedRequest.distance_meters) }}
            </span>
          </div>

          <div class="flex items-center text-sm text-gray-500 space-x-4">
            <div class="flex items-center space-x-1">
              <MapPinIcon class="w-4 h-4" />
              <span>{{ selectedRequest.location.address || 'Location provided' }}</span>
            </div>
            <div class="flex items-center space-x-1">
              <ClockIcon class="w-4 h-4" />
              <span>{{ formatRelativeTime(selectedRequest.created_at) }}</span>
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
                  {{ selectedRequest.user?.full_name || 'Anonymous' }}
                </p>
                <!-- Hide email for anonymous users -->
                <p v-if="authStore.isAuthenticated" class="text-sm text-gray-500">
                  {{ selectedRequest.user?.email }}
                </p>
                <p v-else class="text-sm text-gray-500">Community Member</p>
              </div>
            </div>

            <div v-if="selectedRequest.compensation" class="text-secondary-600 font-medium mb-4">
              Compensation: {{ selectedRequest.compensation }}
            </div>
          </div>

          <div class="flex space-x-3">
            <button
              @click="router.push(`/requests/${selectedRequest.id}`)"
              class="btn btn-primary flex-1"
            >
              View Details
            </button>
            <!-- Authenticated user response -->
            <button
              v-if="canRespond(selectedRequest) && authStore.isAuthenticated"
              @click="handleRespond(selectedRequest)"
              class="btn btn-secondary flex-1"
            >
              Respond
            </button>
            <!-- Anonymous user prompt -->
            <router-link
              v-else-if="canRespond(selectedRequest) && !authStore.isAuthenticated"
              :to="`/auth?redirect=/requests/${selectedRequest.id}`"
              class="btn btn-secondary flex-1"
            >
              Sign In to Respond
            </router-link>
          </div>
        </div>
      </div>
    </div>

    <!-- Requests List -->
    <div>
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-lg font-semibold text-gray-900">
          {{ isLoading ? 'Loading requests...' : `Visible Requests (${filteredRequests.length})` }}
        </h2>
        <div class="text-sm text-gray-500">
          {{
            currentBounds ? 'Showing requests in current map view' : 'Move the map to load requests'
          }}
          <span v-if="clusteringEnabled && mapComponent?.getClusterStats()">
            • {{ mapComponent.getClusterStats()?.clusters || 0 }} clusters
          </span>
        </div>
      </div>

      <!-- Request List Component -->
      <RequestList
        :requests="filteredRequests"
        :loading="isLoading"
        :selected-request-id="selectedRequest?.id"
        variant="map"
        empty-message="Move the map to explore requests in different areas."
        :show-actions="authStore.isAuthenticated"
        @request-click="selectRequest"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, reactive, watch } from 'vue'
  import { useRouter } from 'vue-router'
  import { formatDistanceToNow } from 'date-fns'
  import {
    ExclamationTriangleIcon,
    XMarkIcon,
    MapPinIcon,
    ClockIcon,
    UserIcon,
    InformationCircleIcon,
    ArrowPathIcon,
    MagnifyingGlassIcon,
  } from '@heroicons/vue/24/outline'
  import { useAuthStore } from '@/stores/auth'
  import { LocationService } from '@/services/location'
  import {
    SpatialQueryService,
    type MapBounds,
    type RequestWithDistance,
  } from '@/services/spatialQueries'
  import { CATEGORIES, DURATION_OPTIONS } from '@/constants/categories'
  import DynamicMap from '@/components/common/DynamicMap.vue'
  import RequestList from '@/components/requests/RequestList.vue'
  import type { MapPin } from '@/components/common/DynamicMap.vue'
  import { createLogger } from '@/lib/logger'

  const { log, debug, info, warn, error } = createLogger('MapView')

  const router = useRouter()
  const authStore = useAuthStore()

  const userLocation = ref<{ latitude: number; longitude: number } | null>(null)
  const locationStatus = ref<'loading' | 'success' | 'fallback'>('loading')
  const selectedRequest = ref<RequestWithDistance | null>(null)
  const mapComponent = ref<InstanceType<typeof DynamicMap> | null>(null)
  const localLoading = ref(false)
  const requests = ref<RequestWithDistance[]>([])
  const currentBounds = ref<MapBounds | null>(null)

  // Clustering state
  const clusteringEnabled = ref(true)
  const clusteringOptions = reactive({
    radius: 60,
    minDistance: 40,
    maxZoom: 16,
  })

  // Default location: Los Angeles, CA
  const DEFAULT_LOCATION = {
    latitude: 34.0522,
    longitude: -118.2437,
  }

  const filters = reactive({
    category: '',
    subcategory: '',
  })

  // Combine loading states
  const isLoading = computed(() => localLoading.value)

  const selectedCategorySubcategories = computed(() => {
    if (!filters.category) return []
    return CATEGORIES.find(cat => cat.value === filters.category)?.subcategories || []
  })

  const filteredRequests = computed(() => {
    let filtered = [...requests.value]

    // Apply category filter
    if (filters.category) {
      filtered = filtered.filter(req => req.category === filters.category)
    }

    // Apply subcategory filter
    if (filters.subcategory) {
      filtered = filtered.filter(req => req.subcategory === filters.subcategory)
    }

    return filtered
  })

  const mapPins = computed((): MapPin[] => {
    return filteredRequests.value.map((request, index) => ({
      lat: request.location.latitude,
      lng: request.location.longitude,
      title: request.title,
      id: request.id,
      data: request,
    }))
  })

  const requestLocation = async () => {
    try {
      locationStatus.value = 'loading'
      localLoading.value = true

      const position = await LocationService.getCurrentPosition()
      userLocation.value = {
        latitude: position.latitude,
        longitude: position.longitude,
      }
      recenterMap(position.latitude, position.longitude)
      locationStatus.value = position.source === 'fallback' ? 'fallback' : 'success'
    } catch (e: any) {
      warn('Location access failed, using default location:', e)
      userLocation.value = DEFAULT_LOCATION
      recenterMap(DEFAULT_LOCATION.latitude, DEFAULT_LOCATION.longitude)
      locationStatus.value = 'fallback'
    } finally {
      localLoading.value = false
    }
  }

  const handleFiltersChange = async () => {
    // Clear subcategory if category changed
    if (!filters.category) {
      filters.subcategory = ''
    }

    // Refresh requests with current bounds
    if (currentBounds.value) {
      await fetchRequestsInBounds(currentBounds.value)
    }
  }

  const clearFilters = async () => {
    filters.category = ''
    filters.subcategory = ''
    await handleFiltersChange()
  }

  const handleClusteringToggle = () => {
    // Map will automatically update due to reactive props
  }

  const handleClusteringOptionsChange = () => {
    // Map will automatically update due to reactive props
  }

  const fetchRequestsInBounds = async (bounds: MapBounds) => {
    try {
      localLoading.value = true
      info('Fetching requests in bounds:', bounds)

      const spatialRequests = await SpatialQueryService.getRequestsInBounds(bounds, {
        category: filters.category || undefined,
        subcategory: filters.subcategory || undefined,
        status: 'active',
        limit: 200,
      })

      info(`Loaded ${spatialRequests.length} requests from spatial query`)
      requests.value = spatialRequests
    } catch (e) {
      error('Error fetching requests in bounds:', e)
      requests.value = []
    } finally {
      localLoading.value = false
    }
  }

  const refreshRequests = async () => {
    if (currentBounds.value) {
      await fetchRequestsInBounds(currentBounds.value)
    }
  }

  const fitToAllMarkers = () => {
    if (mapComponent.value && filteredRequests.value.length > 0) {
      mapComponent.value.fitMapToPins(mapPins.value)
    }
  }

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

  const formatDistance = (meters: number) => {
    const miles = SpatialQueryService.metersToMiles(meters)
    if (miles < 0.1) {
      return `${Math.round(meters)} m`
    } else if (miles < 1) {
      return `${(miles * 5280).toFixed(0)} ft`
    } else {
      return `${miles.toFixed(1)} mi`
    }
  }

  const formatRelativeTime = (dateString: string) => {
    return formatDistanceToNow(new Date(dateString), { addSuffix: true })
  }

  const canRespond = (request: RequestWithDistance) => {
    return authStore.user?.id !== request.user_id && request.status === 'active'
  }

  const selectRequest = (request: RequestWithDistance) => {
    selectedRequest.value = request
  }

  const handlePinClick = (pin: MapPin) => {
    const request = pin.data as RequestWithDistance
    if (request) {
      selectedRequest.value = request
    }
  }

  const handleMapClick = (coordinates: { lat: number; lng: number }) => {}

  const handleBoundsChange = async (bounds: MapBounds) => {
    currentBounds.value = bounds
    await fetchRequestsInBounds(bounds)
  }

  const handleViewChange = (center: { lat: number; lng: number }, zoom: number) => {}

  const handleMapReady = (map: any) => {}

  const handleRespond = (request: RequestWithDistance) => {
    if (!authStore.isAuthenticated) {
      router.push(`/auth?redirect=/requests/${request.id}`)
      return
    }
    router.push(`/requests/${request.id}`)
  }

  const recenterMap = (latitude: number, longitude: number) => {
    mapComponent.value?.recenter(latitude, longitude)
  }

  // Watch for category changes to clear subcategory
  watch(
    () => filters.category,
    newCategory => {
      if (!newCategory) {
        filters.subcategory = ''
      }
    },
  )

  onMounted(async () => {
    try {
      // Initialize location
      await requestLocation()
    } catch (e) {
      error('Error during initialization:', e)
    }
  })
</script>

<style scoped>
  /* Additional styles for map view specific components */
  .map-container {
    min-height: 500px;
  }

  /* Responsive adjustments */
  @media (max-width: 640px) {
    .map-container {
      min-height: 400px;
    }
  }
</style>
