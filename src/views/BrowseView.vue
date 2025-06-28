<template>
  <div class="browse-view" v-if="!locating">
    <div class="sidebar">
      <div class="w-full p-4">
        <h2 class="text-lg font-semibold">Listings</h2>
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
      <div class="listing-controls">
        <Text
          v-model="filters.search"
          placeholder="Search listings..."
          class="w-64"
          @input="textSearch"
        />
        <Button variant="gray" @click="filtersVisible = !filtersVisible">
          <Icon icon="tabler:filter" class="w-6 h-6" />
        </Button>
        <Button :loading="locating" @click="jumpToCurrentLocation">
          <Icon icon="mdi:crosshairs-gps" class="w-6 h-6" />
        </Button>
      </div>
      <div v-show="filtersVisible" class="filters">
        <div>
          <Dropdown
            v-model="filters.category"
            label="Category"
            :options="CATEGORIES"
            placeholder="Select Category"
            @change="fetchListings"
          />
        </div>
        <div v-if="filters.category">
          <Dropdown
            v-model="filters.subcategory"
            label="Subcategory"
            :options="filterSubCategories"
            placeholder="Select Subcategory"
            @change="fetchListings"
          />
        </div>
        <div>
          <Checkbox
            v-model="filters.activeOnly"
            label="Active Listings Only"
            @change="fetchListings"
          />
        </div>
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
  import { computed, onMounted, ref, watch } from 'vue'
  import { LocationService } from '@/services/location'
  import { Icon } from '@iconify/vue'
  import { ListingFilters, type Listing, type MapBounds, type MapView } from '@/types'
  import { debounce } from 'lodash'

  import { CATEGORIES } from '@/constants/categories'
  import { useLocationStore } from '@/stores/location'
  import { useListingsStore } from '@/stores/listings'

  import Map from '@/components/geo/Map.vue'
  import ListingMini from '@/components/listings/ListingMini.vue'
  import Button from '@/components/widgets/Button.vue'
  import ListingOverlay from '@/components/listings/ListingOverlay.vue'
  import Text from '@/components/widgets/Text.vue'
  import Dropdown from '@/components/widgets/Dropdown.vue'
  import Checkbox from '@/components/widgets/Checkbox.vue'

  const locationStore = useLocationStore()
  const listingsStore = useListingsStore()

  const locating = ref(true)
  const mapPos = ref({ lat: 0, lng: 0 })
  const mapBounds = ref<MapBounds | null>(null)
  const zoom = ref(12)
  const pullbarActive = ref(false)
  const selectedListing = ref<Listing | null>(null)
  const filtersVisible = ref(false)
  const filters = ref<ListingFilters>({
    search: '',
    category: '',
    subcategory: '',
    activeOnly: true,
  })
  const query = ref('')

  const fetchListings = debounce(async () => {
    if (!mapBounds.value) {
      return
    }

    await listingsStore.fetchListingsInBounds(mapBounds.value, filters.value)
  }, 250)

  const getCategoryColor = (category: string) => {
    return CATEGORIES.find(cat => cat.value === category)?.color ?? 'gray'
  }

  watch(
    () => filters.value.category,
    () => {
      filters.value.subcategory = ''
    },
  )

  const filterSubCategories = computed(() => {
    const category = filters.value.category
    if (!category) return []

    return CATEGORIES.find(cat => cat.value === category)?.subcategories || []
  })

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

    fetchListings()

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

  .listing-controls {
    @apply absolute top-4 right-4 z-20 flex items-center space-x-4;
    @apply bg-gray-100 bg-opacity-75 rounded-lg p-2 shadow-md;
  }

  .filters {
    @apply absolute top-20 right-4 z-20 w-96 flex flex-col items-start space-y-4;
    @apply bg-white rounded-lg p-4 shadow-lg;
  }

  .filters > div {
    @apply w-full;
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
