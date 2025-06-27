<template>
  <div class="browse-view" v-if="!locating">
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
        @bounds-change="mapBoundsChanged"
      />
      <div class="absolute top-4 right-4 z-20 flex items-center space-x-4">
        <Text v-model="query" placeholder="Search listings..." class="w-64" @enter="textSearch" />
        <Button :loading="locating" @click="jumpToCurrentLocation">
          <Icon icon="mdi:crosshairs-gps" class="w-6 h-6" />
        </Button>
      </div>
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
  import type { Listing, MapBounds, MapView } from '@/types'

  import { CATEGORIES } from '@/constants/categories'
  import { useLocationStore } from '@/stores/location'
  import { useListingsStore } from '@/stores/listings'

  import Map from '@/components/geo/Map.vue'
  import ListingMini from '@/components/listings/ListingMini.vue'
  import Button from '@/components/widgets/Button.vue'
  import ListingOverlay from '@/components/listings/ListingOverlay.vue'
  import Text from '@/components/widgets/Text.vue'

  const locationStore = useLocationStore()
  const listingsStore = useListingsStore()

  const locating = ref(true)
  const mapPos = ref({ lat: 0, lng: 0 })
  const mapBounds = ref({ north: 0, south: 0, east: 0, west: 0 })
  const zoom = ref(12)
  const pullbarActive = ref(false)
  const selectedListing = ref<Listing | null>(null)
  const query = ref('')

  const fetchListings = async () => {
    await listingsStore.fetchListingsInBounds(mapBounds.value)
  }

  const getCategoryColor = (category: string) => {
    return CATEGORIES.find(cat => cat.value === category)?.color ?? 'gray'
  }

  const jumpToCurrentLocation = async () => {
    locating.value = true
    const pos = await LocationService.getCurrentPosition()
    mapPos.value = { lat: pos.latitude, lng: pos.longitude }
    zoom.value = 12
    locationStore.setViewingLocation({
      center: mapPos.value,
      zoom: zoom.value,
    })
    locating.value = false
  }

  const textSearch = async () => {
    if (query.value.trim() === '') {
      fetchListings()
      return
    }

    await listingsStore.searchListings(query.value.trim())

    if (listingsStore.listings.length === 0) {
      alert('No listings found for that search.')
    }
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
    locationStore.setViewingLocation(view)
    fetchListings()
  }
  const mapBoundsChanged = (bounds: MapBounds) => {
    mapBounds.value = bounds
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
  .browse-view {
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
