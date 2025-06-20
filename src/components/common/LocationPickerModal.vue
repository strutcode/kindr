<template>
  <div
    v-if="isVisible"
    class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4"
    @click="handleOverlayClick"
  >
    <div
      ref="modalContent"
      class="bg-white rounded-t-lg sm:rounded-lg shadow-xl border border-gray-200 w-full sm:max-w-4xl max-h-screen sm:max-h-[90vh] overflow-hidden flex flex-col"
      @click.stop
    >
      <!-- Header - Fixed -->
      <div
        class="flex items-center justify-between p-4 sm:p-6 border-b border-gray-200 bg-gray-50 flex-shrink-0"
      >
        <div class="flex-1 min-w-0">
          <h2 class="text-lg sm:text-xl font-semibold text-gray-900 truncate">Choose Location</h2>
          <p class="text-xs sm:text-sm text-gray-600 mt-1 hidden sm:block">
            Click on the map to select a new location for browsing requests
          </p>
          <p class="text-xs text-gray-600 mt-1 sm:hidden">Tap on the map to select a location</p>
        </div>
        <button
          @click="close"
          class="p-2 hover:bg-gray-200 rounded-full transition-colors ml-2 flex-shrink-0"
        >
          <XMarkIcon class="w-5 h-5 text-gray-500" />
        </button>
      </div>

      <!-- Scrollable Content Area -->
      <div class="flex-1 overflow-y-auto">
        <!-- Current Location Display -->
        <div
          v-if="selectedLocation"
          class="p-3 sm:p-4 bg-blue-50 border-b border-blue-200 flex-shrink-0"
        >
          <div class="flex items-start justify-between">
            <div class="flex items-start flex-1 min-w-0">
              <MapPinIcon
                class="w-4 h-4 sm:w-5 sm:h-5 text-blue-600 mt-0.5 mr-2 sm:mr-3 flex-shrink-0"
              />
              <div class="flex-1 min-w-0">
                <h3 class="text-sm font-medium text-blue-900">Selected Location</h3>
                <p class="text-xs sm:text-sm text-blue-700 mt-1 break-words">
                  {{
                    selectedLocation.address ||
                    `${selectedLocation.latitude.toFixed(4)}, ${selectedLocation.longitude.toFixed(
                      4,
                    )}`
                  }}
                </p>
              </div>
            </div>
            <button
              @click="clearSelection"
              class="text-blue-600 hover:text-blue-500 text-xs sm:text-sm font-medium ml-2 flex-shrink-0"
            >
              Clear
            </button>
          </div>
        </div>

        <!-- Map Container -->
        <div class="relative">
          <DynamicMap
            :pins="[]"
            :min-height="mapHeight"
            :initial-zoom="currentLocation ? 12 : 10"
            :show-map-info="false"
            :enable-bounds-queries="false"
            :enable-clustering="false"
            @map-click="handleMapClick"
            @map-ready="handleMapReady"
            ref="mapComponent"
            class="border-0"
          />

          <!-- Loading Overlay -->
          <div
            v-if="isLoadingAddress"
            class="absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center"
          >
            <div class="text-center">
              <LoadingSpinner size="lg" />
              <p class="text-xs sm:text-sm text-gray-600 mt-2">Getting address...</p>
            </div>
          </div>

          <!-- Instructions Overlay -->
          <div
            v-if="!selectedLocation"
            class="absolute top-2 sm:top-4 left-2 sm:left-4 right-2 sm:right-4 bg-white/90 backdrop-blur-sm rounded-lg p-2 sm:p-3 shadow-lg border border-gray-200"
          >
            <div class="flex items-start">
              <InformationCircleIcon
                class="w-4 h-4 sm:w-5 sm:h-5 text-blue-600 mr-2 flex-shrink-0 mt-0.5"
              />
              <p class="text-xs sm:text-sm text-gray-700">
                <span class="hidden sm:inline"
                  >Click anywhere on the map to select a location for browsing requests</span
                >
                <span class="sm:hidden">Tap anywhere on the map to select a location</span>
              </p>
            </div>
          </div>
        </div>

        <!-- Mobile Action Buttons - Only visible on small screens -->
        <div class="sm:hidden p-3 space-y-2 bg-gray-50 border-t border-gray-200">
          <button
            @click="useCurrentLocation"
            :disabled="isGettingLocation"
            class="btn btn-outline btn-sm w-full"
          >
            <MapPinIcon class="w-4 h-4 mr-2" />
            {{ isGettingLocation ? 'Getting Location...' : 'Use Current Location' }}
          </button>

          <button
            v-if="initialLocation"
            @click="resetToInitial"
            class="btn btn-outline btn-sm w-full"
          >
            <ArrowPathIcon class="w-4 h-4 mr-2" />
            Reset to Original
          </button>
        </div>
      </div>

      <!-- Footer Actions - Fixed -->
      <div
        class="flex items-center justify-between p-3 sm:p-6 border-t border-gray-200 bg-gray-50 flex-shrink-0"
      >
        <!-- Desktop Action Buttons -->
        <div class="hidden sm:flex items-center space-x-4">
          <button
            @click="useCurrentLocation"
            :disabled="isGettingLocation"
            class="btn btn-outline btn-sm"
          >
            <MapPinIcon class="w-4 h-4 mr-2" />
            {{ isGettingLocation ? 'Getting Location...' : 'Use Current Location' }}
          </button>

          <button v-if="initialLocation" @click="resetToInitial" class="btn btn-outline btn-sm">
            <ArrowPathIcon class="w-4 h-4 mr-2" />
            Reset to Original
          </button>
        </div>

        <!-- Mobile: Only show main actions -->
        <div class="sm:hidden flex-1" />

        <!-- Main Action Buttons -->
        <div class="flex space-x-2 sm:space-x-3">
          <button @click="close" class="btn btn-outline btn-sm sm:btn-base">Cancel</button>
          <button
            @click="confirmSelection"
            :disabled="!selectedLocation"
            class="btn btn-primary btn-sm sm:btn-base"
          >
            <CheckIcon class="w-4 h-4 mr-1 sm:mr-2" />
            <span class="hidden sm:inline">Use This Location</span>
            <span class="sm:hidden">Use Location</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
  import {
    XMarkIcon,
    MapPinIcon,
    InformationCircleIcon,
    CheckIcon,
    ArrowPathIcon,
  } from '@heroicons/vue/24/outline'
  import DynamicMap from './DynamicMap.vue'
  import LoadingSpinner from './LoadingSpinner.vue'
  import { useLocationStore } from '@/stores/location'
  import { LocationService } from '@/services/location'

  export interface LocationSelection {
    latitude: number
    longitude: number
    address?: string
  }

  interface Props {
    /** Whether the modal is visible */
    isVisible: boolean
    /** Current location to center the map on */
    currentLocation?: LocationSelection | null
    /** Initial location for reset functionality */
    initialLocation?: LocationSelection | null
  }

  interface Emits {
    /** Emitted when modal should be closed */
    (e: 'close'): void
    /** Emitted when a location is selected and confirmed */
    (e: 'location-selected', location: LocationSelection): void
  }

  const props = defineProps<Props & { mode: 'viewing' | 'creation' }>()
  const emit = defineEmits<Emits>()

  // Refs
  const modalContent = ref<HTMLElement>()
  const mapComponent = ref<InstanceType<typeof DynamicMap> | null>(null)
  const selectedLocation = ref<LocationSelection | null>(null)
  const isLoadingAddress = ref(false)
  const isGettingLocation = ref(false)

  // Store
  const locationStore = useLocationStore()

  // Computed properties
  const mapHeight = computed(() => {
    // Responsive map height based on screen size
    if (typeof window !== 'undefined') {
      const vh = window.innerHeight
      const isMobile = window.innerWidth < 640

      if (isMobile) {
        // On mobile, use more of the available height
        return Math.max(300, Math.min(500, vh * 0.5))
      } else {
        // On desktop, use a fixed height
        return 400
      }
    }
    return 400
  })

  // Methods
  const handleOverlayClick = () => {
    close()
  }

  const close = () => {
    selectedLocation.value = null
    emit('close')
  }

  const handleMapClick = async (coordinates: { lat: number; lng: number }) => {
    console.log('Map clicked at:', coordinates)

    // Set the selected location immediately (convert lat/lng to latitude/longitude)
    selectedLocation.value = {
      latitude: coordinates.lat,
      longitude: coordinates.lng,
    }

    // Try to get the address in the background
    try {
      isLoadingAddress.value = true
      const address = await LocationService.reverseGeocode(coordinates.lat, coordinates.lng)

      // Update the selected location with the address
      if (
        selectedLocation.value &&
        selectedLocation.value.latitude === coordinates.lat &&
        selectedLocation.value.longitude === coordinates.lng
      ) {
        selectedLocation.value.address = address
      }
    } catch (error) {
      console.warn('Failed to get address for coordinates:', error)
      // Keep the location without address
    } finally {
      isLoadingAddress.value = false
    }
  }

  const handleMapReady = (map: any) => {
    console.log('Location picker map ready')

    // Center on current location if available
    if (props.currentLocation) {
      mapComponent.value?.recenter(
        props.currentLocation.latitude,
        props.currentLocation.longitude,
        12,
      )
    }
  }

  const useCurrentLocation = async () => {
    try {
      isGettingLocation.value = true
      const position = await LocationService.getCurrentPosition()

      selectedLocation.value = {
        latitude: position.latitude,
        longitude: position.longitude,
      }

      // Center map on the new location
      mapComponent.value?.recenter(position.latitude, position.longitude, 14)

      // Get address
      try {
        const address = await LocationService.reverseGeocode(position.latitude, position.longitude)
        if (selectedLocation.value) {
          selectedLocation.value.address = address
        }
      } catch (error) {
        console.warn('Failed to get address for current location:', error)
      }
    } catch (error) {
      console.error('Failed to get current location:', error)
      // Could show an error message here
    } finally {
      isGettingLocation.value = false
    }
  }

  const resetToInitial = () => {
    if (props.initialLocation) {
      selectedLocation.value = { ...props.initialLocation }
      mapComponent.value?.recenter(
        props.initialLocation.latitude,
        props.initialLocation.longitude,
        12,
      )
    }
  }

  const clearSelection = () => {
    selectedLocation.value = null
  }

  const confirmSelection = () => {
    if (selectedLocation.value) {
      // Update the correct location in the store
      if (props.mode === 'viewing') {
        locationStore.setViewingLocation({ ...selectedLocation.value })
      } else {
        locationStore.setCreationLocation({ ...selectedLocation.value })
      }
      emit('location-selected', { ...selectedLocation.value })
      close()
    }
  }

  // Handle escape key
  const handleKeydown = (event: KeyboardEvent) => {
    if (event.key === 'Escape' && props.isVisible) {
      close()
    }
  }

  // Handle window resize to update map height
  const handleResize = () => {
    // Force reactivity update for map height
    if (mapComponent.value) {
      // Small delay to ensure DOM has updated
      setTimeout(() => {
        mapComponent.value?.updateMarkers()
      }, 100)
    }
  }

  // Lifecycle
  onMounted(() => {
    document.addEventListener('keydown', handleKeydown)
    window.addEventListener('resize', handleResize)
  })

  onUnmounted(() => {
    document.removeEventListener('keydown', handleKeydown)
    window.removeEventListener('resize', handleResize)
  })

  // Watch for visibility changes to reset state
  watch(
    () => props.isVisible,
    isVisible => {
      if (isVisible) {
        // Reset selection when modal opens
        selectedLocation.value = null

        // Set initial selection if current location is provided
        if (props.currentLocation) {
          selectedLocation.value = { ...props.currentLocation }
        }

        // Prevent body scroll on mobile
        if (typeof window !== 'undefined' && window.innerWidth < 640) {
          document.body.style.overflow = 'hidden'
        }
      } else {
        // Restore body scroll
        document.body.style.overflow = ''
      }
    },
  )
</script>

<style scoped>
  /* Modal animation */
  .modal-enter-active,
  .modal-leave-active {
    transition: opacity 0.3s ease;
  }

  .modal-enter-from,
  .modal-leave-to {
    opacity: 0;
  }

  /* Ensure map fills container properly */
  :deep(.map-container) {
    border-radius: 0;
  }

  /* Custom scrollbar for modal content */
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

  /* Mobile-specific styles */
  @media (max-width: 639px) {
    /* Full screen modal on mobile */
    .fixed.inset-0 {
      padding: 0;
    }

    /* Ensure modal takes full height on mobile */
    .max-h-screen {
      height: 100vh;
      max-height: 100vh;
    }

    /* Optimize touch targets */
    button {
      min-height: 44px;
    }

    /* Better text wrapping on small screens */
    .break-words {
      word-break: break-word;
      overflow-wrap: break-word;
    }
  }

  /* Smooth height transitions */
  .map-container {
    transition: height 0.3s ease;
  }

  /* Ensure proper flex layout */
  .flex.flex-col {
    min-height: 0;
  }

  .flex-1 {
    min-height: 0;
  }

  /* iOS Safari specific fixes */
  @supports (-webkit-touch-callout: none) {
    .max-h-screen {
      height: 100vh;
      height: -webkit-fill-available;
    }
  }

  /* Landscape mobile optimization */
  @media (max-width: 639px) and (orientation: landscape) {
    .max-h-screen {
      height: 100vh;
    }

    /* Reduce padding in landscape */
    .p-4 {
      padding: 0.75rem;
    }

    .p-3 {
      padding: 0.5rem;
    }
  }

  /* High contrast mode support */
  @media (prefers-contrast: high) {
    .bg-white\/90 {
      background-color: rgba(255, 255, 255, 0.95);
    }

    .border-gray-200 {
      border-color: #000;
    }
  }

  /* Reduced motion support */
  @media (prefers-reduced-motion: reduce) {
    .transition-colors,
    .modal-enter-active,
    .modal-leave-active {
      transition: none;
    }
  }
</style>
