<template>
  <div class="container" v-if="!locating">
    <div class="sidebar">
      <div class="w-full p-4">
        <div class="flex">
          <h2 class="text-lg font-semibold grow">Listings</h2>
          <Button icon-left="tabler:plus" :link="{ name: 'create' }"> Create </Button>
        </div>
        <ul class="space-y-8 mt-4">
          <ListingMini
            v-for="pin in mapPins"
            :key="pin.listing.id"
            :index="pin.index"
            :listing="pin.listing"
            @click="selectedListing = pin.listing"
            class="w-full"
          />
        </ul>
      </div>
    </div>
    <div>
      <Map
        class="absolute w-full h-full"
        :center="mapPos"
        :zoom="zoom"
        :minZoom="1"
        :maxZoom="19"
        :pins="mapPins"
        @view-change="mapViewChanged"
      />
      <div class="pullbar" :class="{ active: pullbarActive }">
        <div class="grabber" @click="pullbarActive = !pullbarActive">
          <div class="grabber-pill"></div>
        </div>

        <ul class="space-y-4 mt-4 grow overflow-y-scroll">
          <ListingMini
            v-for="pin in mapPins"
            :key="pin.listing.id"
            :index="pin.index"
            :listing="pin.listing"
            @click="selectedListing = pin.listing"
            class="w-full"
          />
        </ul>
      </div>
    </div>
  </div>
  <div v-if="locating" class="overlay light">
    <Icon icon="mdi:map-search-outline" class="text-4xl text-gray-700 animate-bounce" />
  </div>
  <div v-if="selectedListing" class="overlay dark">
    <ListingOverlay :listing="selectedListing" @close="selectedListing = null" />
  </div>
</template>

<script setup lang="ts">
  import { computed, onMounted, ref } from 'vue'
  import { LocationService } from '@/services/location'
  import { Icon } from '@iconify/vue'
  import type { Listing, MapView } from '@/types'

  import { CATEGORIES } from '@/constants/categories'
  import { useLocationStore } from '@/stores/location'
  import { useListingsStore } from '@/stores/listings'

  import Map from '@/components/geo/Map.vue'
  import ListingMini from '@/components/listings/ListingMini.vue'
  import Button from '@/components/widgets/Button.vue'
  import ListingOverlay from '@/components/listings/ListingOverlay.vue'

  const locationStore = useLocationStore()
  const listingsStore = useListingsStore()

  const locating = ref(true)
  const mapPos = ref({ lat: 0, lng: 0 })
  const zoom = ref(12)
  const pullbarActive = ref(false)
  const selectedListing = ref<Listing | null>(null)

  const fetchListings = async () => {
    await listingsStore.fetchListings()
  }

  const getCategoryColor = (category: string) => {
    return CATEGORIES.find(cat => cat.value === category)?.color ?? 'gray'
  }

  const mapPins = computed(() => {
    return listingsStore.listings.map((listing, index) => ({
      index: index + 1,
      lat: listing.location.lat,
      lng: listing.location.lng,
      color: getCategoryColor(listing.category),
      listing,
    }))
  })

  const mapViewChanged = (view: MapView) => {
    mapPos.value = view.center
    locationStore.setViewingLocation(view)
    fetchListings()
  }

  onMounted(async () => {
    fetchListings()

    if (locationStore.viewingLocation) {
      const loc = locationStore.viewingLocation
      mapPos.value = loc.center
      zoom.value = loc.zoom
    } else {
      const pos = await LocationService.getCurrentPosition()
      locationStore.setViewingLocation({
        center: { lat: pos.latitude, lng: pos.longitude },
        zoom: 12,
      })
      mapPos.value = { lat: pos.latitude, lng: pos.longitude }
    }

    locating.value = false
  })
</script>

<style scoped>
  .container {
    @apply absolute w-full h-full flex;
  }

  .sidebar {
    @apply w-96 collapse overflow-y-scroll;
    @apply relative bg-gray-100 border-r border-gray-300 shadow-lg z-10;
    @apply md:visible;
  }

  .pullbar {
    @apply absolute bottom-0 left-0 w-full h-24 p-2;
    @apply flex flex-col block;
    @apply bg-white border border-gray-300 rounded-t-lg;
    @apply md:hidden;
    transition: height 0.2s ease-in-out;
  }

  .pullbar.active {
    height: 96%;
  }

  .grabber {
    @apply py-2 px-24 bg-gray-50 rounded-lg;
    @apply cursor-pointer;
  }

  .grabber-pill {
    @apply w-24 h-1 bg-gray-300 rounded-full mx-auto;
  }

  .overlay {
    @apply absolute inset-0 flex items-center justify-center bg-white bg-opacity-75;
  }

  .overlay .dark {
    @apply bg-black bg-opacity-25;
  }
</style>
