import { defineStore } from 'pinia'
import { ref, watch } from 'vue'
import { LocationService } from '@/services/location'

export interface ViewLocation {
  latitude: number
  longitude: number
  zoom: number
}

export const useLocationStore = defineStore('location', () => {
  // For browsing/filtering
  const viewingLocation = ref<ViewLocation | null>(null)
  // For request creation
  const creationLocation = ref<Location | null>(null)

  // Load viewingLocation from localStorage if available
  const LOCAL_STORAGE_KEY = 'kindr_viewing_location'
  const stored = localStorage.getItem(LOCAL_STORAGE_KEY)
  if (stored) {
    try {
      viewingLocation.value = JSON.parse(stored)
    } catch (e) {
      // Ignore parse errors
    }
  }

  // Watcher to persist viewingLocation changes
  watch(
    viewingLocation,
    loc => {
      if (loc) {
        localStorage.setItem(LOCAL_STORAGE_KEY, JSON.stringify(loc))
      } else {
        localStorage.removeItem(LOCAL_STORAGE_KEY)
      }
    },
    { deep: true },
  )

  // Setters
  function setViewingLocation(loc: ViewLocation | null) {
    viewingLocation.value = loc
  }
  function setCreationLocation(loc: Location | null) {
    creationLocation.value = loc
  }
  function clearViewingLocation() {
    viewingLocation.value = null
  }
  function clearCreationLocation() {
    creationLocation.value = null
  }

  // Geocode address for manual entry
  async function geocodeAddress(address: string): Promise<Location | null> {
    try {
      const result = await LocationService.geocodeAddress(address)
      return {
        latitude: result.latitude,
        longitude: result.longitude,
        address: result.formatted_address,
        source: 'manual',
      }
    } catch (e) {
      return null
    }
  }

  // Reverse geocode coordinates
  async function reverseGeocode(lat: number, lng: number): Promise<string> {
    return LocationService.reverseGeocode(lat, lng)
  }

  return {
    viewingLocation,
    creationLocation,
    setViewingLocation,
    setCreationLocation,
    clearViewingLocation,
    clearCreationLocation,
    geocodeAddress,
    reverseGeocode,
  }
})
