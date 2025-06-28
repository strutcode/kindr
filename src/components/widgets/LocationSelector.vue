<template>
  <div class="location-selector">
    <div class="address-input">
      <Text
        v-model="addressInput"
        placeholder="Type an address or location..."
        @enter="handleAddressSearch"
      />
      <Button variant="gray" @click="handleAddressSearch" :loading="isGeocoding" class="ml-4">
        Search
      </Button>
    </div>

    <div class="map-picker">
      <Map
        :center="selectedLocation"
        :zoom="zoom"
        :pins="selectedPin"
        @map-click="handleMapClick"
      />
    </div>
    <p class="mt-2 text-sm text-gray-500">
      Click on the map to select a location or search for an address above.
    </p>

    <div v-if="error" class="mt-2 text-red-600 text-sm">
      {{ error }}
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, ref, watch } from 'vue'
  import Map from '@/components/geo/Map.vue'
  import Text from '@/components/widgets/Text.vue'
  import { LocationService } from '@/services/location'
  import type { Location } from '@/types'
  import Button from './Button.vue'

  interface Props {
    modelValue?: Location | null
    zoom?: number
  }

  const props = withDefaults(defineProps<Props>(), {
    zoom: 13,
  })

  const emit = defineEmits<{
    (e: 'update:modelValue', location: Location): void
  }>()

  const addressInput = ref('')
  const selectedLocation = ref<Location>(props.modelValue || { lat: 34.0522, lng: -118.2437 })
  const isGeocoding = ref(false)
  const error = ref('')

  const selectedPin = computed(() => [
    {
      ...selectedLocation.value,
      color: '#d45f0d',
    },
  ])

  const handleMapClick = async (location: { lat: number; lng: number }) => {
    selectedLocation.value = location
    emit('update:modelValue', location)

    // Reverse geocode to get address
    try {
      const address = await LocationService.reverseGeocode(location.lat, location.lng)
      addressInput.value = address
      error.value = ''
    } catch (err) {
      console.error('Reverse geocoding failed:', err)
    }
  }

  const handleAddressSearch = async () => {
    if (!addressInput.value.trim()) return

    isGeocoding.value = true
    error.value = ''

    try {
      const result = await LocationService.geocodeAddress(addressInput.value)
      const location = { lat: result.latitude, lng: result.longitude }

      selectedLocation.value = location
      emit('update:modelValue', location)
    } catch (err) {
      console.error('Geocoding failed:', err)
      error.value = 'Could not find the specified location. Please try a different address.'
    } finally {
      isGeocoding.value = false
    }
  }

  // Initialize address display when component loads with a location
  const initializeAddress = async () => {
    if (props.modelValue) {
      try {
        const address = await LocationService.reverseGeocode(
          props.modelValue.lat,
          props.modelValue.lng,
        )
        addressInput.value = address
      } catch (err) {
        console.error('Reverse geocoding failed on init:', err)
      }
    }
  }

  // Watch for prop changes
  watch(
    () => props.modelValue,
    newValue => {
      if (newValue) {
        selectedLocation.value = newValue
        initializeAddress()
      }
    },
    { immediate: true },
  )
</script>

<style scoped>
  .address-input {
    @apply flex mb-4;
  }

  .map-picker {
    @apply relative h-96 border rounded;
  }
</style>
