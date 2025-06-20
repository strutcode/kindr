<template>
  <div class="mapview-root">
    <!-- The header is global, so content below should not be hidden under it -->
    <Teleport to="body">
      <div v-if="requestsStore.showFiltersPopover" class="filters-sidebar-overlay">
        <FiltersPopover />
      </div>
    </Teleport>
    <div class="mapview-content">
      <RequestsSidebar
        :requests="filteredRequests"
        :clusters="clusters"
        :loading="isLoading"
        :selected-request-id="selectedRequest?.id"
        @request-click="selectRequest"
        @show-more-cluster="zoomToCluster"
      />
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
    <SelectedRequestOverlay
      v-if="selectedRequest"
      :selected-request="selectedRequest"
      :get-category-label="getCategoryLabel"
      :get-subcategory-label="getSubcategoryLabel"
      :get-duration-label="getDurationLabel"
      :format-relative-time="formatRelativeTime"
      :format-distance="formatDistance"
      :can-respond="canRespond"
      @close="selectedRequest = null"
    />
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
  import FiltersPopover from '@/components/common/FiltersPopover.vue'
  import RequestsSidebar from '@/components/requests/RequestsSidebar.vue'
  import SelectedRequestOverlay from '@/components/requests/SelectedRequestOverlay.vue'
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
  import { useRequestsStore } from '@/stores/requests'

  const { log, debug, info, warn, error } = createLogger('MapView')

  const router = useRouter()
  const authStore = useAuthStore()
  const requestsStore = useRequestsStore()

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
    height: 100%;
    width: 100vw;
    overflow: hidden;
    margin-top: 64px; /* header height */
  }
  .mapview-map-container {
    flex: 1 1 0;
    position: relative;
    height: 100%;
    width: 100%;
    z-index: 1;
  }
  .filters-sidebar-overlay {
    position: fixed;
    top: 64px;
    left: 0;
    height: calc(100vh - 64px);
    width: 340px;
    z-index: 1000;
    display: flex;
    flex-direction: column;
    pointer-events: none;
  }
  .filters-sidebar-overlay > * {
    pointer-events: auto;
    width: 100%;
    height: 100%;
  }
  /* Remove old popover overlay styles */

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
