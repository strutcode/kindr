<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Anonymous User Banner -->
    <div v-if="!authStore.isAuthenticated" class="bg-primary-50 border border-primary-200 rounded-lg p-4 mb-6">
      <div class="flex items-start justify-between">
        <div class="flex items-start">
          <InformationCircleIcon class="w-5 h-5 text-primary-600 mt-0.5 mr-3 flex-shrink-0" />
          <div>
            <h3 class="text-sm font-medium text-primary-800">Browsing as Guest</h3>
            <p class="text-sm text-primary-700 mt-1">
              You can view all community requests. 
              <router-link to="/auth" class="font-medium underline hover:no-underline">
                Sign in or join
              </router-link> 
              to create requests and respond to others.
            </p>
          </div>
        </div>
        <router-link to="/auth" class="btn btn-primary btn-sm ml-4 flex-shrink-0">
          Join Community
        </router-link>
      </div>
    </div>

    <div class="flex flex-col lg:flex-row gap-8">
      <!-- Filters Sidebar -->
      <div class="lg:w-80 flex-shrink-0">
        <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 sticky top-24">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">Filters</h2>
          
          <!-- Category Filter -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Category
            </label>
            <select 
              v-model="filters.category"
              class="input"
              @change="handleFiltersChange"
            >
              <option value="">All Categories</option>
              <option 
                v-for="category in CATEGORIES" 
                :key="category.value" 
                :value="category.value"
              >
                {{ category.label }}
              </option>
            </select>
          </div>

          <!-- Subcategory Filter -->
          <div v-if="filters.category" class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Subcategory
            </label>
            <select 
              v-model="filters.subcategory"
              class="input"
              @change="handleFiltersChange"
            >
              <option value="">All Subcategories</option>
              <option 
                v-for="subcategory in selectedCategorySubcategories" 
                :key="subcategory.value" 
                :value="subcategory.value"
              >
                {{ subcategory.label }}
              </option>
            </select>
          </div>

          <!-- Radius Filter -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Radius: {{ filters.radius }} miles
            </label>
            <input
              v-model.number="filters.radius"
              type="range"
              min="0.5"
              max="10"
              step="0.5"
              class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer slider"
              @input="handleFiltersChange"
            />
            <div class="flex justify-between text-xs text-gray-500 mt-1">
              <span>0.5mi</span>
              <span>10mi</span>
            </div>
          </div>

          <!-- Location Override Section -->
          <div class="mb-6">
            <div class="flex items-center justify-between mb-2">
              <label class="block text-sm font-medium text-gray-700">
                Search Location
              </label>
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
          </div>

          <!-- Location Status -->
          <div class="mb-6">
            <div v-if="locationStatus === 'fallback'" class="p-3 bg-warning-50 rounded-md border border-warning-200">
              <div class="flex items-start">
                <ExclamationTriangleIcon class="w-4 h-4 text-warning-600 mt-0.5 mr-2 flex-shrink-0" />
                <div>
                  <p class="text-sm text-warning-800 font-medium">Using Default Location</p>
                  <p class="text-xs text-warning-700 mt-1">
                    Showing requests around Los Angeles, CA
                  </p>
                  <button 
                    @click="requestLocation"
                    class="mt-2 text-xs text-warning-600 hover:text-warning-500 font-medium underline"
                  >
                    Try enabling location again
                  </button>
                </div>
              </div>
            </div>
            <div v-else-if="locationStatus === 'loading'" class="p-3 bg-gray-50 rounded-md">
              <p class="text-sm text-gray-700">Getting your location...</p>
            </div>
            <div v-else-if="locationStatus === 'success'" class="p-3 bg-success-50 rounded-md">
              <p class="text-sm text-success-700">✓ Location enabled</p>
            </div>
            <div v-else-if="locationStatus === 'custom'" class="p-3 bg-blue-50 rounded-md">
              <p class="text-sm text-blue-700">✓ Custom location selected</p>
            </div>
          </div>

          <!-- Clear Filters -->
          <button 
            @click="clearFilters"
            class="btn btn-outline w-full"
          >
            Clear Filters
          </button>
        </div>
      </div>

      <!-- Main Content -->
      <div class="flex-1">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Community Requests</h1>
            <p class="text-gray-600 mt-1">
              {{ isLoading ? 'Loading...' : `${displayedRequests.length} requests found` }}
              <span v-if="userLocation && !isLoading"> within {{ filters.radius }} miles</span>
              <span v-if="locationStatus === 'fallback' && !isLoading"> of Los Angeles, CA</span>
              <span v-if="locationStatus === 'custom' && !isLoading"> of selected location</span>
            </p>
          </div>
          
          <!-- Create Request Button - Only for authenticated users -->
          <router-link 
            v-if="authStore.isAuthenticated"
            to="/requests/create" 
            class="btn btn-primary"
          >
            <PlusIcon class="w-4 h-4 mr-2" />
            Create Request
          </router-link>
          
          <!-- Sign In Prompt for Anonymous Users -->
          <router-link 
            v-else
            to="/auth" 
            class="btn btn-primary"
          >
            <UserPlusIcon class="w-4 h-4 mr-2" />
            Join to Create Requests
          </router-link>
        </div>

        <!-- Request List Component -->
        <RequestList
          :requests="displayedRequests"
          :loading="isLoading"
          variant="list"
          :empty-message="getEmptyMessage()"
          :show-actions="authStore.isAuthenticated"
          @request-click="handleRequestClick"
          @respond="handleRespond"
        />
      </div>
    </div>

    <!-- Location Picker Modal -->
    <LocationPickerModal
      :is-visible="showLocationModal"
      :current-location="userLocation"
      :initial-location="initialLocation"
      @close="hideLocationPicker"
      @location-selected="handleLocationSelected"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive, watch } from 'vue'
import { useRouter } from 'vue-router'
import { PlusIcon, ExclamationTriangleIcon, InformationCircleIcon, UserPlusIcon, MapPinIcon } from '@heroicons/vue/24/outline'
import { useRequestsStore } from '@/stores/requests'
import { useAuthStore } from '@/stores/auth'
import { LocationService } from '@/services/location'
import { SpatialQueryService } from '@/services/spatialQueries'
import { CATEGORIES } from '@/constants/categories'
import RequestList from '@/components/requests/RequestList.vue'
import LocationPickerModal, { type LocationSelection } from '@/components/common/LocationPickerModal.vue'
import type { Request, RequestFilters } from '@/types'

const router = useRouter()
const requestsStore = useRequestsStore()
const authStore = useAuthStore()

const userLocation = ref<{ latitude: number; longitude: number } | null>(null)
const initialLocation = ref<LocationSelection | null>(null)
const locationStatus = ref<'loading' | 'success' | 'fallback' | 'custom'>('loading')
const localLoading = ref(false)
const showLocationModal = ref(false)

// Local requests state for spatial queries
const spatialRequests = ref<Request[]>([])

// Default location: Los Angeles, CA
const DEFAULT_LOCATION = {
  latitude: 34.0522,
  longitude: -118.2437
}

const filters = reactive<RequestFilters>({
  category: '',
  subcategory: '',
  radius: 2,
})

// Combine store loading with local loading states
const isLoading = computed(() => requestsStore.loading || localLoading.value)

const selectedCategorySubcategories = computed(() => {
  if (!filters.category) return []
  return CATEGORIES.find(cat => cat.value === filters.category)?.subcategories || []
})

// Use spatial requests when available, otherwise fall back to filtered store requests
const displayedRequests = computed(() => {
  if (locationStatus.value === 'custom' || (userLocation.value && locationStatus.value !== 'loading')) {
    // Use spatial query results
    return spatialRequests.value
  } else {
    // Fall back to store requests with client-side filtering
    let filtered = [...requestsStore.requests]

    // Apply location filtering if user location is available
    if (userLocation.value) {
      filtered = LocationService.filterRequestsByLocation(filtered, {
        latitude: userLocation.value.latitude,
        longitude: userLocation.value.longitude,
        radius: filters.radius,
      })
    }

    return filtered
  }
})

const currentLocationDisplay = computed(() => {
  if (!userLocation.value) {
    return 'No location set'
  }
  
  if (locationStatus.value === 'custom') {
    // Try to show address if available, otherwise coordinates
    const customLocation = userLocation.value as any
    return customLocation.address || `${userLocation.value.latitude.toFixed(4)}, ${userLocation.value.longitude.toFixed(4)}`
  }
  
  if (locationStatus.value === 'fallback') {
    return 'Los Angeles, CA (default)'
  }
  
  return `${userLocation.value.latitude.toFixed(4)}, ${userLocation.value.longitude.toFixed(4)}`
})

const locationStatusText = computed(() => {
  switch (locationStatus.value) {
    case 'loading':
      return 'Getting location...'
    case 'success':
      return 'Current location'
    case 'fallback':
      return 'Default location (enable GPS for accuracy)'
    case 'custom':
      return 'Custom location selected'
    default:
      return ''
  }
})

const getEmptyMessage = () => {
  if (authStore.isAuthenticated) {
    return "Try adjusting your filters or create the first request in your area."
  } else {
    return "No requests found in this area. Join the community to create the first request!"
  }
}

const requestLocation = async () => {
  try {
    locationStatus.value = 'loading'
    localLoading.value = true
    
    const position = await LocationService.getCurrentPosition()
    userLocation.value = {
      latitude: position.latitude,
      longitude: position.longitude,
    }
    
    // Store as initial location for reset functionality
    if (!initialLocation.value) {
      initialLocation.value = {
        lat: position.latitude,
        lng: position.longitude
      }
    }
    
    locationStatus.value = position.source === 'fallback' ? 'fallback' : 'success'
    
    // Fetch requests for the new location
    await fetchRequestsForLocation()
  } catch (error: any) {
    console.warn('Location access failed, using default location:', error)
    // Use fallback location instead of showing error
    userLocation.value = DEFAULT_LOCATION
    
    // Store as initial location for reset functionality
    if (!initialLocation.value) {
      initialLocation.value = {
        lat: DEFAULT_LOCATION.latitude,
        lng: DEFAULT_LOCATION.longitude
      }
    }
    
    locationStatus.value = 'fallback'
    
    // Fetch requests for the fallback location
    await fetchRequestsForLocation()
  } finally {
    localLoading.value = false
  }
}

const showLocationPicker = () => {
  showLocationModal.value = true
}

const hideLocationPicker = () => {
  showLocationModal.value = false
}

const handleLocationSelected = async (location: LocationSelection) => {
  console.log('Location selected:', location)
  
  // Update user location with the selected coordinates
  userLocation.value = {
    latitude: location.latitude,
    longitude: location.longitude
  }
  
  // Store the full location data for display purposes
  ;(userLocation.value as any).address = location.address
  
  // Update status to indicate custom location
  locationStatus.value = 'custom'
  
  // Fetch requests for the new location
  await fetchRequestsForLocation()
}

const fetchRequestsForLocation = async () => {
  if (!userLocation.value) {
    console.warn('No user location available for spatial query')
    return
  }

  try {
    localLoading.value = true
    console.log('Fetching requests for location:', userLocation.value, 'radius:', filters.radius)

    // Convert radius from miles to meters
    const radiusMeters = SpatialQueryService.milesToMeters(filters.radius)
    
    // Use spatial query service to get requests in radius
    const requests = await SpatialQueryService.getRequestsInRadius(
      userLocation.value.latitude,
      userLocation.value.longitude,
      radiusMeters,
      {
        category: filters.category || undefined,
        subcategory: filters.subcategory || undefined,
        status: 'active',
        limit: 200
      }
    )

    console.log(`Found ${requests.length} requests within ${filters.radius} miles`)
    spatialRequests.value = requests
  } catch (error) {
    console.error('Error fetching requests for location:', error)
    // Fall back to store requests if spatial query fails
    spatialRequests.value = []
    await requestsStore.fetchRequests({
      category: filters.category || undefined,
      subcategory: filters.subcategory || undefined,
      radius: filters.radius,
      location: userLocation.value || undefined,
    })
  } finally {
    localLoading.value = false
  }
}

const handleFiltersChange = async () => {
  // Update store filters
  requestsStore.updateFilters(filters)
  
  // Clear subcategory if category changed
  if (!filters.category) {
    filters.subcategory = ''
  }
  
  // Fetch requests with new filters
  if (userLocation.value && (locationStatus.value === 'custom' || locationStatus.value === 'success' || locationStatus.value === 'fallback')) {
    // Use spatial query for location-based search
    await fetchRequestsForLocation()
  } else {
    // Fall back to regular store fetch
    await requestsStore.fetchRequests({
      category: filters.category || undefined,
      subcategory: filters.subcategory || undefined,
      radius: filters.radius,
      location: userLocation.value || undefined,
    })
  }
}

const clearFilters = async () => {
  filters.category = ''
  filters.subcategory = ''
  filters.radius = 2
  await handleFiltersChange()
}

const handleRequestClick = (request: Request) => {
  router.push(`/requests/${request.id}`)
}

const handleRespond = (request: Request) => {
  if (!authStore.isAuthenticated) {
    // Redirect to auth with return path
    router.push(`/auth?redirect=/requests/${request.id}`)
    return
  }
  router.push(`/requests/${request.id}`)
}

onMounted(async () => {
  try {
    // Initialize location first
    await requestLocation()
  } catch (error) {
    console.error('Error during initialization:', error)
  }
})

// Watch for category changes to clear subcategory
watch(() => filters.category, (newCategory) => {
  if (!newCategory) {
    filters.subcategory = ''
  }
})

// Watch for radius changes to refetch requests
watch(() => filters.radius, async () => {
  if (userLocation.value) {
    await fetchRequestsForLocation()
  }
})
</script>

<style scoped>
.slider::-webkit-slider-thumb {
  appearance: none;
  height: 20px;
  width: 20px;
  border-radius: 50%;
  background: #0ea5e9;
  cursor: pointer;
}

.slider::-moz-range-thumb {
  height: 20px;
  width: 20px;
  border-radius: 50%;
  background: #0ea5e9;
  cursor: pointer;
  border: none;
}
</style>