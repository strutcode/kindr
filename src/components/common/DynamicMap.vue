<template>
  <div class="dynamic-map-container">
    <!-- Map Container - Always rendered -->
    <div ref="mapContainer" class="map-container" :style="{ minHeight: `${minHeight}px` }" />

    <!-- Loading State Overlay -->
    <div v-if="isLoading" class="map-overlay map-loading" :style="{ minHeight: `${minHeight}px` }">
      <LoadingSpinner size="lg" text="Loading map..." />
    </div>

    <!-- Error State Overlay -->
    <div v-if="error" class="map-overlay map-error" :style="{ minHeight: `${minHeight}px` }">
      <ExclamationTriangleIcon class="w-12 h-12 text-error-500 mx-auto mb-4" />
      <h3 class="text-lg font-medium text-gray-900 mb-2">Map Error</h3>
      <p class="text-gray-600 mb-4">{{ error }}</p>
      <button @click="initializeMap" class="btn btn-primary">Retry</button>
    </div>

    <!-- Map Info Overlay -->
    <div v-if="showMapInfo && !isLoading && !error" class="map-info-overlay">
      <div class="bg-white/90 backdrop-blur-sm rounded-lg p-3 shadow-lg border border-gray-200">
        <div class="text-sm text-gray-700">
          <div class="flex items-center space-x-4">
            <span>{{ visibleRequestsCount }} requests visible</span>
            <span v-if="clusteringEnabled && clusterStats">
              {{ clusterStats.clusters }} clusters
            </span>
            <span v-if="lastUpdateTime"> Updated {{ formatRelativeTime(lastUpdateTime) }} </span>
          </div>
          <div v-if="currentBounds" class="text-xs text-gray-500 mt-1">
            Zoom: {{ currentZoom }} | Bounds: {{ formatBounds(currentBounds) }}
          </div>
        </div>
      </div>
    </div>

    <!-- Cluster Popup -->
    <ClusterPopup
      :requests="clusterPopupRequests"
      :is-visible="showClusterPopup"
      @close="closeClusterPopup"
      @request-click="handleClusterRequestClick"
      @zoom-to-fit="handleZoomToFit"
    />
  </div>
</template>

<script setup lang="ts">
  import 'ol/ol.css'
  import { ref, onMounted, onBeforeUnmount, watch, nextTick, computed } from 'vue'
  import { Map, View } from 'ol'
  import TileLayer from 'ol/layer/Tile'
  import OSM from 'ol/source/OSM'
  import VectorLayer from 'ol/layer/Vector'
  import VectorSource from 'ol/source/Vector'
  import Feature from 'ol/Feature'
  import Point from 'ol/geom/Point'
  import { Style, Icon, Text, Fill, Stroke, Circle } from 'ol/style'
  import { fromLonLat, toLonLat } from 'ol/proj'
  import { getBottomLeft, getBottomRight, getTopLeft, getTopRight } from 'ol/extent'
  import { formatDistanceToNow } from 'date-fns'
  import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
  import LoadingSpinner from './LoadingSpinner.vue'
  import ClusterPopup from './ClusterPopup.vue'
  import { MapClusteringService, type ClusterFeature } from '@/services/mapClustering'
  import type { MapBounds, RequestWithDistance } from '@/services/spatialQueries'

  /**
   * Pin location interface for map markers
   */
  export interface MapPin {
    /** Latitude coordinate */
    lat: number
    /** Longitude coordinate */
    lng: number
    /** Optional title for the pin */
    title?: string
    /** Optional unique identifier */
    id?: string
    /** Optional additional data */
    data?: any
  }

  interface Props {
    /** Array of pin locations to display on the map */
    pins?: MapPin[]
    /** Minimum height of the map container in pixels */
    minHeight?: number
    /** Initial map position as { latitude, longitude } */
    initialPosition?: { latitude: number; longitude: number }
    /** Initial zoom level (1-20) */
    initialZoom?: number
    /** Whether to show zoom controls */
    showZoomControls?: boolean
    /** Whether to enable map interactions */
    interactive?: boolean
    /** Whether to show map info overlay */
    showMapInfo?: boolean
    /** Whether to enable bounds-based queries */
    enableBoundsQueries?: boolean
    /** Debounce delay for bounds change events (ms) */
    boundsChangeDelay?: number
    /** Whether to enable clustering */
    enableClustering?: boolean
    /** Clustering options */
    clusteringOptions?: {
      radius?: number
      minDistance?: number
      maxZoom?: number
    }
  }

  interface Emits {
    /** Emitted when a pin is clicked */
    (e: 'pin-click', pin: MapPin, event: Event): void
    /** Emitted when the map is clicked (not on a pin) */
    (e: 'map-click', coordinates: { lat: number; lng: number }, event: Event): void
    /** Emitted when the map is ready */
    (e: 'map-ready', map: Map): void
    /** Emitted when map bounds change */
    (e: 'bounds-change', bounds: MapBounds): void
    /** Emitted when map view changes (move, zoom) */
    (e: 'view-change', center: { lat: number; lng: number }, zoom: number): void
  }

  const props = withDefaults(defineProps<Props>(), {
    pins: () => [],
    minHeight: 400,
    initialPosition: { longitude: -118.2437, latitude: 34.0522 }, // Default center position
    initialZoom: 10,
    showZoomControls: true,
    interactive: true,
    showMapInfo: false,
    enableBoundsQueries: true,
    boundsChangeDelay: 500,
    enableClustering: true,
    clusteringOptions: () => ({
      radius: 60,
      minDistance: 40,
      maxZoom: 16,
    }),
  })

  const emit = defineEmits<Emits>()

  // Reactive references
  const mapContainer = ref<HTMLElement>()
  const map = ref<Map>()
  const vectorLayer = ref<VectorLayer<VectorSource>>()
  const isLoading = ref(true)
  const error = ref('')
  const currentBounds = ref<MapBounds | null>(null)
  const currentZoom = ref(props.initialZoom)
  const lastUpdateTime = ref<Date | null>(null)

  // Clustering state
  const clusteringService = ref<MapClusteringService>()
  const clusteringEnabled = computed(() => props.enableClustering)
  const showClusterPopup = ref(false)
  const clusterPopupRequests = ref<RequestWithDistance[]>([])
  const clusterStats = ref<{ clusters: number; points: number } | null>(null)

  // Debounce timer for bounds changes
  let boundsChangeTimer: NodeJS.Timeout | null = null

  // Computed properties
  const visibleRequestsCount = computed(() => {
    if (clusteringEnabled.value && clusterStats.value) {
      return clusterStats.value.points
    }
    return props.pins.length
  })

  /**
   * Initialize clustering service
   */
  const initializeClustering = () => {
    if (!clusteringEnabled.value) return

    clusteringService.value = new MapClusteringService({
      radius: props.clusteringOptions?.radius || 60,
      minDistance: props.clusteringOptions?.minDistance || 40,
      maxZoom: props.clusteringOptions?.maxZoom || 16,
      minZoom: 0,
      maxPointsPerCluster: 100,
    })

    console.log('Clustering service initialized')
  }

  /**
   * Convert pins to requests for clustering
   */
  const pinsToRequests = (pins: MapPin[]): RequestWithDistance[] => {
    return pins
      .filter(pin => pin.data && typeof pin.data === 'object')
      .map(pin => pin.data as RequestWithDistance)
      .filter(request => request.id && request.location)
  }

  /**
   * Create cluster marker style
   */
  const createClusterStyle = (feature: ClusterFeature): Style => {
    const properties = feature.properties
    const isCluster = properties.cluster
    const count = properties.point_count || 1

    if (isCluster) {
      // Cluster marker
      const colors = MapClusteringService.getClusterColor(count)
      const size = MapClusteringService.getClusterSize(count)
      const displayCount = MapClusteringService.formatClusterCount(count)

      return new Style({
        image: new Circle({
          radius: size / 2,
          fill: new Fill({ color: colors.background }),
          stroke: new Stroke({ color: '#ffffff', width: 3 }),
        }),
        text: new Text({
          text: displayCount,
          fill: new Fill({ color: colors.text }),
          font: 'bold 14px Inter, sans-serif',
          textAlign: 'center',
          textBaseline: 'middle',
        }),
      })
    } else {
      // Individual marker
      const request = properties.request
      const categoryColor = getCategoryColor(request?.category || 'help-needed')

      return new Style({
        image: new Icon({
          src: createMarkerSVG(categoryColor),
          scale: 1,
          anchor: [0.5, 1],
        }),
      })
    }
  }

  /**
   * Get category color for markers
   */
  const getCategoryColor = (category: string): string => {
    switch (category) {
      case 'free-stuff':
        return '#22c55e' // Green
      case 'help-needed':
        return '#0ea5e9' // Blue
      case 'skills-offered':
        return '#f97316' // Orange
      default:
        return '#6b7280' // Gray
    }
  }

  /**
   * Create SVG marker
   */
  const createMarkerSVG = (color: string): string => {
    return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(`
      <svg width="32" height="40" viewBox="0 0 32 40" xmlns="http://www.w3.org/2000/svg">
        <path d="M16 0C7.163 0 0 7.163 0 16c0 16 16 24 16 24s16-8 16-24C32 7.163 24.837 0 16 0z" fill="${color}"/>
        <circle cx="16" cy="16" r="8" fill="white"/>
        <circle cx="16" cy="16" r="4" fill="${color}"/>
      </svg>
    `)}`
  }

  /**
   * Update map with clusters or individual markers
   */
  const updateMapMarkers = () => {
    if (!vectorLayer.value || !map.value) return

    const source = vectorLayer.value.getSource()
    if (!source) return

    // Clear existing features
    source.clear()

    if (clusteringEnabled.value && clusteringService.value) {
      // Use clustering
      const requests = pinsToRequests(props.pins)

      if (requests.length === 0) {
        clusterStats.value = { clusters: 0, points: 0 }
        return
      }

      // Load requests into clustering service
      clusteringService.value.loadRequests(requests)

      // Get current bounds and zoom
      const bounds = getCurrentBounds()
      const zoom = currentZoom.value

      if (bounds) {
        // Get clusters for current view
        const clusters = clusteringService.value.getClusters(
          [bounds.west, bounds.south, bounds.east, bounds.north],
          zoom,
        )

        console.log(`Rendering ${clusters.length} clusters/markers at zoom ${zoom}`)

        // Create features for clusters
        const features = clusters.map(cluster => {
          const feature = new Feature({
            geometry: new Point(fromLonLat(cluster.geometry.coordinates)),
            cluster: cluster,
          })

          feature.setStyle(createClusterStyle(cluster))
          return feature
        })

        source.addFeatures(features)

        // Update stats
        const clusterCount = clusters.filter(c => c.properties.cluster).length
        const pointCount = clusters.filter(c => !c.properties.cluster).length
        clusterStats.value = {
          clusters: clusterCount,
          points: requests.length,
        }
      }
    } else {
      // Use individual markers (original behavior)
      const validPins = props.pins.filter(
        pin =>
          typeof pin.lat === 'number' &&
          typeof pin.lng === 'number' &&
          pin.lat >= -90 &&
          pin.lat <= 90 &&
          pin.lng >= -180 &&
          pin.lng <= 180,
      )

      if (validPins.length === 0) {
        clusterStats.value = { clusters: 0, points: 0 }
        return
      }

      // Create features for individual pins
      const features = validPins.map((pin, index) => {
        const feature = new Feature({
          geometry: new Point(fromLonLat([pin.lng, pin.lat])),
          pin: pin,
          index: index,
        })

        const request = pin.data as RequestWithDistance
        const categoryColor = getCategoryColor(request?.category || 'help-needed')

        feature.setStyle(
          new Style({
            image: new Icon({
              src: createMarkerSVG(categoryColor),
              scale: 1,
              anchor: [0.5, 1],
            }),
          }),
        )

        return feature
      })

      source.addFeatures(features)
      clusterStats.value = { clusters: 0, points: validPins.length }
    }

    // Update last update time
    lastUpdateTime.value = new Date()
  }

  /**
   * Handle feature click (cluster or individual marker)
   */
  const handleFeatureClick = (feature: Feature, event: any) => {
    const cluster = feature.get('cluster') as ClusterFeature
    const pin = feature.get('pin') as MapPin

    if (cluster) {
      if (cluster.properties.cluster) {
        // Cluster clicked - show popup with all requests
        const clusterId = cluster.properties.cluster_id!
        const requests = clusteringService.value?.getClusterExpansionPoints(clusterId) || []

        console.log(`Cluster clicked with ${requests.length} requests`)

        clusterPopupRequests.value = requests
        showClusterPopup.value = true
      } else {
        // Individual marker in clustering mode
        const request = cluster.properties.request
        if (request) {
          const pin: MapPin = {
            lat: request.location.latitude,
            lng: request.location.longitude,
            title: request.title,
            id: request.id,
            data: request,
          }
          emit('pin-click', pin, event.originalEvent)
        }
      }
    } else if (pin) {
      // Individual marker in non-clustering mode
      emit('pin-click', pin, event.originalEvent)
    }
  }

  /**
   * Gets current map bounds
   */
  const getCurrentBounds = (): MapBounds | null => {
    if (!map.value) return null

    try {
      const view = map.value.getView()
      const extent = view.calculateExtent(map.value.getSize())

      // Convert extent to lat/lng bounds
      const bottomLeft = toLonLat(getBottomLeft(extent))
      const topRight = toLonLat(getTopRight(extent))

      return {
        west: bottomLeft[0],
        south: bottomLeft[1],
        east: topRight[0],
        north: topRight[1],
      }
    } catch (err) {
      console.warn('Error getting map bounds:', err)
      return null
    }
  }

  /**
   * Handles map view changes (move, zoom)
   */
  const handleViewChange = () => {
    if (!map.value || !props.enableBoundsQueries) return

    const view = map.value.getView()
    const center = toLonLat(view.getCenter() || [0, 0])
    const zoom = view.getZoom() || 0

    currentZoom.value = zoom

    // Emit view change
    emit('view-change', { lat: center[1], lng: center[0] }, zoom)

    // Update markers when zoom changes (for clustering)
    if (clusteringEnabled.value) {
      updateMapMarkers()
    }

    // Debounce bounds change events
    if (boundsChangeTimer) {
      clearTimeout(boundsChangeTimer)
    }

    boundsChangeTimer = setTimeout(() => {
      const bounds = getCurrentBounds()
      if (bounds) {
        currentBounds.value = bounds
        emit('bounds-change', bounds)
      }
    }, props.boundsChangeDelay)
  }

  /**
   * Handle window resize events
   */
  const handleResize = () => {
    if (map.value) {
      // Trigger map resize
      nextTick(() => {
        map.value?.updateSize()
      })
    }
  }

  /**
   * Initialize the OpenLayers map
   */
  const initializeMap = async () => {
    try {
      if (!mapContainer.value) {
        throw new Error('Map container is not available')
      }

      isLoading.value = true
      error.value = ''

      // Initialize clustering if enabled
      if (clusteringEnabled.value) {
        initializeClustering()
      }

      // Create OSM tile layer
      const osmLayer = new TileLayer({
        source: new OSM({
          url: 'https://{a-c}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          attributions:
            '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
          crossOrigin: 'anonymous',
        }),
        preload: 4,
      })

      // Create vector source and layer for markers
      const vectorSource = new VectorSource()
      const newVectorLayer = new VectorLayer({
        source: vectorSource,
        zIndex: 10,
      })
      vectorLayer.value = newVectorLayer

      const defaultCenter = fromLonLat([
        props.initialPosition.longitude,
        props.initialPosition.latitude,
      ])

      // Create the map
      const newMap = new Map({
        target: mapContainer.value,
        layers: [osmLayer, newVectorLayer],
        view: new View({
          center: defaultCenter,
          zoom: props.initialZoom,
          maxZoom: 20,
          minZoom: 2,
        }),
        controls: props.showZoomControls ? undefined : [],
        interactions: props.interactive ? undefined : [],
      })

      map.value = newMap

      // Add click handler
      newMap.on('click', event => {
        const feature = newMap.forEachFeatureAtPixel(event.pixel, feature => feature)

        if (feature) {
          // Feature clicked
          handleFeatureClick(feature, event)
        } else {
          // Map clicked (not on a feature)
          const coordinates = toLonLat(event.coordinate)
          emit('map-click', { lat: coordinates[1], lng: coordinates[0] }, event.originalEvent)
        }
      })

      // Add pointer cursor on hover over features
      newMap.on('pointermove', event => {
        const feature = newMap.forEachFeatureAtPixel(event.pixel, feature => feature)
        newMap.getTargetElement().style.cursor = feature ? 'pointer' : ''
      })

      // Add view change listeners for bounds tracking
      if (props.enableBoundsQueries) {
        const view = newMap.getView()
        view.on('change:center', handleViewChange)
        view.on('change:resolution', handleViewChange)
      }

      // Wait for the map to be properly rendered
      await new Promise<void>(resolve => {
        let attempts = 0
        const maxAttempts = 50 // 5 seconds max

        const checkReady = () => {
          attempts++
          const size = newMap.getSize()

          if (size && size[0] > 0 && size[1] > 0) {
            setTimeout(() => {
              resolve()
            }, 200)
          } else if (attempts < maxAttempts) {
            setTimeout(checkReady, 100)
          } else {
            console.warn('Map initialization timeout, continuing...')
            resolve()
          }
        }

        checkReady()
      })

      // Update markers after map is ready
      updateMapMarkers()

      // Add resize listener
      window.addEventListener('resize', handleResize)

      // Force a map update to ensure tiles load
      nextTick(() => {
        newMap.updateSize()
        newMap.renderSync()
      })

      // Emit initial bounds if bounds queries are enabled
      if (props.enableBoundsQueries) {
        setTimeout(() => {
          const bounds = getCurrentBounds()
          if (bounds) {
            currentBounds.value = bounds
            emit('bounds-change', bounds)
          }
        }, 1000)
      }

      emit('map-ready', newMap)
    } catch (err: any) {
      error.value = err.message || 'Failed to initialize map'
      console.error('Map initialization error:', err)
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Cleanup function
   */
  const cleanup = () => {
    if (boundsChangeTimer) {
      clearTimeout(boundsChangeTimer)
    }

    window.removeEventListener('resize', handleResize)

    if (map.value) {
      map.value.setTarget(undefined)
      map.value = undefined
    }

    vectorLayer.value = undefined
    clusteringService.value?.clear()
  }

  /**
   * Recenter map to specific coordinates
   */
  const recenter = (latitude: number, longitude: number, zoom?: number) => {
    if (!map.value) {
      console.warn('Map not initialized, cannot recenter')
      return
    }

    const center = fromLonLat([longitude, latitude])

    map.value.getView().animate({
      center: center,
      zoom: zoom || 12,
      duration: 1000,
    })
  }

  /**
   * Fit map to show all pins
   */
  const fitMapToPins = (pins: MapPin[] = props.pins) => {
    if (!map.value || pins.length === 0) return

    try {
      if (pins.length === 1) {
        const pin = pins[0]
        recenter(pin.lat, pin.lng, props.initialZoom)
      } else {
        const coordinates = pins.map(pin => fromLonLat([pin.lng, pin.lat]))
        const extent = coordinates.reduce(
          (acc, coord) => {
            return [
              Math.min(acc[0], coord[0]),
              Math.min(acc[1], coord[1]),
              Math.max(acc[2], coord[0]),
              Math.max(acc[3], coord[1]),
            ]
          },
          [coordinates[0][0], coordinates[0][1], coordinates[0][0], coordinates[0][1]],
        )

        const padding = 0.01
        const paddedExtent = [
          extent[0] - padding,
          extent[1] - padding,
          extent[2] + padding,
          extent[3] + padding,
        ]

        map.value.getView().fit(paddedExtent, {
          padding: [50, 50, 50, 50],
          maxZoom: 15,
        })
      }
    } catch (err) {
      console.warn('Error fitting map to pins:', err)
    }
  }

  /**
   * Close cluster popup
   */
  const closeClusterPopup = () => {
    showClusterPopup.value = false
    clusterPopupRequests.value = []
  }

  /**
   * Handle request click from cluster popup
   */
  const handleClusterRequestClick = (request: RequestWithDistance) => {
    const pin: MapPin = {
      lat: request.location.latitude,
      lng: request.location.longitude,
      title: request.title,
      id: request.id,
      data: request,
    }
    emit('pin-click', pin, new Event('click'))
  }

  /**
   * Handle zoom to fit from cluster popup
   */
  const handleZoomToFit = (requests: RequestWithDistance[]) => {
    const pins: MapPin[] = requests.map(request => ({
      lat: request.location.latitude,
      lng: request.location.longitude,
      title: request.title,
      id: request.id,
      data: request,
    }))
    fitMapToPins(pins)
  }

  /**
   * Format bounds for display
   */
  const formatBounds = (bounds: MapBounds): string => {
    return `N:${bounds.north.toFixed(3)} S:${bounds.south.toFixed(3)} E:${bounds.east.toFixed(
      3,
    )} W:${bounds.west.toFixed(3)}`
  }

  /**
   * Format relative time
   */
  const formatRelativeTime = (date: Date): string => {
    return formatDistanceToNow(date, { addSuffix: true })
  }

  // Watch for pin changes
  watch(() => props.pins, updateMapMarkers, { deep: true })

  // Watch for clustering option changes
  watch(
    () => props.clusteringOptions,
    () => {
      if (clusteringEnabled.value && clusteringService.value) {
        clusteringService.value.updateOptions({
          radius: props.clusteringOptions?.radius || 60,
          minDistance: props.clusteringOptions?.minDistance || 40,
          maxZoom: props.clusteringOptions?.maxZoom || 16,
        })
        updateMapMarkers()
      }
    },
    { deep: true },
  )

  // Lifecycle hooks
  onMounted(async () => {
    await nextTick()
    await initializeMap()
  })

  onBeforeUnmount(() => {
    cleanup()
  })

  // Expose methods to parent components
  defineExpose({
    recenter,
    getBounds: getCurrentBounds,
    fitMapToPins,
    updateMarkers: updateMapMarkers,
    getClusterStats: () => clusterStats.value,
  })
</script>

<style scoped>
  .dynamic-map-container {
    @apply relative w-full rounded-lg overflow-hidden border border-gray-200;
  }

  .map-container {
    @apply w-full bg-gray-100;
  }

  .map-overlay {
    @apply absolute inset-0 z-10;
  }

  .map-loading {
    @apply flex items-center justify-center bg-gray-50;
  }

  .map-error {
    @apply flex flex-col items-center justify-center bg-gray-50 text-center p-8;
  }

  .map-info-overlay {
    @apply absolute top-4 right-4 z-20 pointer-events-none;
  }

  /* OpenLayers specific styles */
  :deep(.ol-viewport) {
    position: absolute !important;
  }

  :deep(.ol-zoom) {
    @apply top-4 left-4;
  }

  :deep(.ol-zoom button) {
    @apply bg-white border border-gray-300 text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary-500;
  }

  :deep(.ol-attribution) {
    @apply text-xs bg-white/90 backdrop-blur-sm;
  }

  :deep(.ol-attribution ul) {
    @apply text-gray-600;
  }

  :deep(.ol-layer) {
    @apply opacity-100;
  }

  /* Responsive adjustments */
  @media (max-width: 640px) {
    :deep(.ol-zoom) {
      @apply top-2 left-2;
    }

    :deep(.ol-zoom button) {
      @apply text-sm;
    }

    .map-info-overlay {
      @apply top-2 right-2;
    }
  }

  /* High contrast mode support */
  @media (prefers-contrast: high) {
    .map-container {
      @apply border-2 border-gray-900;
    }
  }

  /* Reduced motion support */
  @media (prefers-reduced-motion: reduce) {
    :deep(.ol-viewport) {
      transition: none !important;
    }
  }
</style>
