<template>
  <Map
    v-if="!locating"
    class="absolute w-full h-full"
    :center="mapPos"
    :zoom="12"
    :minZoom="1"
    :maxZoom="19"
    @view-change="mapViewChanged"
  />
  <div v-if="locating" class="overlay">
    <Icon icon="mdi:map-search-outline" class="text-4xl text-gray-700 animate-bounce" />
  </div>
</template>

<script setup lang="ts">
  import { onMounted, ref } from 'vue'
  import { LocationService } from '@/services/location'
  import { Icon } from '@iconify/vue'
  import type { MapView } from '@/types'

  import Map from '@/components/geo/Map.vue'
  import { useLocationStore } from '@/stores/location'

  const locationStore = useLocationStore()

  const locating = ref(true)
  const mapPos = ref({ lat: 0, lng: 0 })

  const mapViewChanged = (view: MapView) => {
    mapPos.value = view.center
    locationStore.setViewingLocation({
      latitude: view.center.lat,
      longitude: view.center.lng,
    })
  }

  onMounted(async () => {
    if (locationStore.viewingLocation) {
      mapPos.value = {
        lat: locationStore.viewingLocation.latitude,
        lng: locationStore.viewingLocation.longitude,
      }
      locating.value = false
      return
    }

    const pos = await LocationService.getCurrentPosition()
    locationStore.setViewingLocation(pos)

    mapPos.value = { lat: pos.latitude, lng: pos.longitude }

    locating.value = false
  })
</script>

<style scoped>
  .overlay {
    @apply absolute inset-0 flex items-center justify-center bg-white bg-opacity-75;
  }
</style>
