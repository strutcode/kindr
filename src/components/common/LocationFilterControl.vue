<template>
  <div class="mb-6">
    <div class="flex items-center justify-between mb-2">
      <label class="block text-sm font-medium text-gray-700"> Search Location </label>
      <button
        @click="showLocationPicker"
        class="text-sm text-primary-600 hover:text-primary-500 font-medium"
      >
        Change
      </button>
    </div>
    <div class="p-3 bg-gray-50 rounded-md border border-gray-200">
      <div class="flex items-start">
        <MapPinIcon class="w-4 h-4 text-gray-500 mt-0.5 mr-2 flex-shrink-0" />
        <div class="flex-1 min-w-0">
          <p class="text-sm text-gray-700 truncate">
            {{ currentLocationDisplay }}
          </p>
          <p class="text-xs text-gray-500 mt-1">
            {{ locationStatusText }}
          </p>
        </div>
      </div>
    </div>
    <LocationPickerModal
      :is-visible="showLocationModal"
      :current-location="locationStore.viewingLocation"
      :initial-location="initialLocation"
      mode="viewing"
      @close="hideLocationPicker"
      @location-selected="handleLocationSelected"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed } from 'vue'
  import { MapPinIcon } from '@heroicons/vue/24/outline'
  import { useLocationStore } from '@/stores/location'
  import LocationPickerModal from '@/components/common/LocationPickerModal.vue'

  const locationStore = useLocationStore()
  const showLocationModal = ref(false)
  const initialLocation = computed(() => {
    const loc = locationStore.viewingLocation
    return loc ? { latitude: loc.latitude, longitude: loc.longitude, address: loc.address } : null
  })

  const currentLocationDisplay = computed(() => {
    const loc = locationStore.viewingLocation
    if (!loc) return 'No location set'
    return loc.address || `${loc.latitude.toFixed(4)}, ${loc.longitude.toFixed(4)}`
  })

  const locationStatusText = computed(() => {
    const loc = locationStore.viewingLocation
    if (!loc) return 'No location set'
    if (loc.source === 'fallback') return 'Default location (enable GPS for accuracy)'
    if (loc.source === 'gps') return 'Current location'
    if (loc.source === 'ip') return 'Estimated location'
    if (loc.source === 'manual') return 'Custom location selected'
    return ''
  })

  function showLocationPicker() {
    showLocationModal.value = true
  }
  function hideLocationPicker() {
    showLocationModal.value = false
  }
  function handleLocationSelected() {
    // No-op: store is already updated by modal
    showLocationModal.value = false
  }
</script>
