import { defineStore } from 'pinia'
import { ref } from 'vue'
import { LocationService } from '@/services/location'

export interface Location {
  latitude: number
  longitude: number
  address?: string
  city?: string
  country?: string
  countryCode?: string
  timeZone?: string
  accuracy?: 'high' | 'medium' | 'low'
  source?: 'gps' | 'ip' | 'fallback'
}

export const useLocationStore = defineStore('location', () => {
  // For browsing/filtering
  const viewingLocation = ref<Location | null>(null)
  // For request creation
  const creationLocation = ref<Location | null>(null)

  // Setters
  function setViewingLocation(loc: Location | null) {
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

  // Initialize viewing location using LocationService
  async function initViewingLocation() {
    if (!viewingLocation.value) {
      const loc = await LocationService.getCurrentPosition()
      viewingLocation.value = loc
    }
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
    initViewingLocation,
    geocodeAddress,
    reverseGeocode,
  }
})
