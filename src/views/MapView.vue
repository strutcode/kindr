<template>
  <div class="mapview-root">
    <!-- Header (AppHeader) -->
    <AppHeader @toggle-filters="toggleFiltersPopover" />

    <!-- Filters Popover -->
    <FiltersPopover
      v-if="showFiltersPopover"
      :filters="filters"
      :categories="CATEGORIES"
      :selected-category-subcategories="selectedCategorySubcategories"
      @update:filters="onFiltersUpdate"
      @close="showFiltersPopover = false"
    />

    <!-- Map and Sidebar Layout -->
    <div class="mapview-content">
      <!-- Requests Sidebar -->
      <RequestsSidebar
        :requests="filteredRequests"
        :clusters="clusters"
        :loading="isLoading"
        :selected-request-id="selectedRequest?.id"
        @request-click="selectRequest"
        @show-more-cluster="zoomToCluster"
      />

      <!-- Map Container -->
      <div class="mapview-map-container">
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
          :numbered-pins="true"
          :pin-numbers="pinNumbers"
          @pin-click="handlePinClick"
          @map-click="handleMapClick"
          @bounds-change="handleBoundsChange"
          @view-change="handleViewChange"
          @map-ready="handleMapReady"
          @clusters-change="onClustersChange"
          ref="mapComponent"
        />
      </div>
    </div>

    <!-- Selected Request Details (overlay, optional) -->
    <div v-if="selectedRequest" class="mapview-request-details-overlay">
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
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, reactive, watch } from 'vue'
  import { useRouter } from 'vue-router'
  import { useAuthStore } from '@/stores/auth'
  import { LocationService } from '@/services/location'
  import {
    SpatialQueryService,
    type MapBounds,
    type RequestWithDistance,
  } from '@/services/spatialQueries'
  import { CATEGORIES } from '@/constants/categories'
  import DynamicMap from '@/components/common/DynamicMap.vue'
  import RequestList from '@/components/requests/RequestList.vue'
  import { createLogger } from '@/lib/logger'
  import { useRequestFormatting } from '@/composables/useRequestFormatting'
  import UserInfo from '@/components/common/UserInfo.vue'
  import StatusBanner from '@/components/common/StatusBanner.vue'
  import AppHeader from '@/components/common/AppHeader.vue'
  import FiltersPopover from '@/components/common/FiltersPopover.vue'
  import RequestsSidebar from '@/components/requests/RequestsSidebar.vue'
  import {
    InformationCircleIcon,
    ArrowPathIcon,
    MagnifyingGlassIcon,
    ExclamationTriangleIcon,
    XMarkIcon,
    MapPinIcon,
    ClockIcon,
    UserIcon,
  } from '@heroicons/vue/24/outline'

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

  const { getCategoryLabel, getSubcategoryLabel, getDurationLabel, formatRelativeTime } =
    useRequestFormatting()

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

  const showFiltersPopover = ref(false)
  const toggleFiltersPopover = () => {
    showFiltersPopover.value = !showFiltersPopover.value
  }

  const onFiltersUpdate = (newFilters: typeof filters) => {
    filters.category = newFilters.category
    filters.subcategory = newFilters.subcategory
    showFiltersPopover.value = false
    handleFiltersChange()
  }

  // For sidebar and map pin numbering
  const pinNumbers = ref<Record<string, number>>({})

  // Clusters for sidebar grouping (to be provided by DynamicMap or clustering logic)
  const clusters = ref([])

  function onClustersChange(newClusters: any[]) {
    clusters.value = newClusters
    // Build pinNumbers map for both clusters and requests
    const map: Record<string, number> = {}
    newClusters.forEach((cluster, idx) => {
      if (cluster.isCluster) {
        map[cluster.id] = idx + 1
        cluster.requests.forEach(req => {
          map[req.id] = idx + 1
        })
      } else {
        map[cluster.id] = idx + 1
      }
    })
    pinNumbers.value = map
  }

  function zoomToCluster(clusterId: string) {
    mapComponent.value?.zoomToCluster(clusterId)
  }
</script>

<style scoped>
  .mapview-root {
    position: fixed;
    inset: 0;
    display: flex;
    flex-direction: column;
    height: 100vh;
    width: 100vw;
    overflow: hidden;
  }

  .mapview-content {
    flex: 1 1 0;
    display: flex;
    height: calc(100vh - 64px); /* header height */
    width: 100vw;
    overflow: hidden;
  }

  .mapview-map-container {
    flex: 1 1 0;
    position: relative;
    height: 100%;
    width: 100%;
    z-index: 1;
  }

  /* Sidebar overlay styles */
  .mapview-requests-sidebar {
    width: 380px;
    max-width: 100vw;
    height: 100%;
    background: white;
    box-shadow: 2px 0 8px rgba(0, 0, 0, 0.08);
    z-index: 10;
    overflow-y: auto;
    position: relative;
  }

  /* Filters popover overlay */
  .filters-popover {
    position: absolute;
    top: 64px;
    left: 50px;
    z-index: 20;
    background: white;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
    border-radius: 0.5rem;
    padding: 1.5rem;
    min-width: 320px;
  }

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
