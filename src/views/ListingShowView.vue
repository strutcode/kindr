<template>
  <div class="listing-show-container">
    <!-- Loading state -->
    <div v-if="loading" class="loading-state">
      <Icon icon="mdi:loading" class="loading-spinner" />
      <p>Loading listing...</p>
    </div>

    <!-- Error state -->
    <div v-else-if="error" class="error-state">
      <Icon icon="mdi:alert-circle" class="error-icon" />
      <h2>Listing not found</h2>
      <p>{{ error }}</p>
      <Button @click="$router.push('/browse')" variant="primary"> Browse Listings </Button>
    </div>

    <!-- Main content -->
    <div v-else-if="listing" class="listing-content">
      <!-- Mobile header -->
      <div class="mobile-header">
        <Button
          @click="$router.back()"
          variant="ghost"
          icon-left="tabler:chevron-left"
          class="back-button"
        >
          Back
        </Button>
      </div>

      <!-- Image gallery -->
      <div v-if="listing.images?.length" class="image-gallery">
        <img :src="listing.images[currentImageIndex]" :alt="listing.title" class="main-image" />
        <div v-if="listing.images.length > 1" class="image-nav">
          <button
            v-for="(image, index) in listing.images"
            :key="index"
            @click="currentImageIndex = index"
            :class="['image-dot', { active: index === currentImageIndex }]"
          />
        </div>
        <div v-if="listing.images.length > 1" class="image-counter">
          {{ currentImageIndex + 1 }} of {{ listing.images.length }}
        </div>
      </div>

      <!-- Content grid -->
      <div class="content-grid">
        <!-- Main content area -->
        <div class="main-content">
          <!-- Header section -->
          <div class="listing-header">
            <div class="category-info">
              <div class="category-badge" :style="{ backgroundColor: categoryColor }">
                {{ categoryText }}
              </div>
              <div class="subcategory-text">{{ subcategoryText }}</div>
            </div>

            <h1 class="listing-title">{{ listing.title }}</h1>

            <div class="status-row">
              <div class="status-badge" :class="{ active: listing.active }">
                <Icon
                  :icon="listing.active ? 'tabler:check' : 'tabler:hourglass'"
                  class="status-icon"
                />
                {{ listing.active ? 'Active' : 'Expired' }}
              </div>
              <div class="date-info">Posted {{ formatDate(listing.created_at) }}</div>
            </div>
          </div>

          <!-- Description section -->
          <div class="description-section">
            <h2 class="section-title">Description</h2>
            <div class="description-content">
              <p>{{ listing.description }}</p>
            </div>
          </div>

          <!-- Pills section -->
          <div class="pills-section">
            <ListingPills :listing="listing" />
          </div>

          <!-- Skills and details -->
          <div v-if="listing.skills_required?.length" class="skills-section">
            <h3 class="section-subtitle">Skills Required</h3>
            <div class="skills-list">
              <span v-for="skill in listing.skills_required" :key="skill" class="skill-tag">
                {{ skill }}
              </span>
            </div>
          </div>
        </div>

        <!-- Sidebar -->
        <div class="sidebar">
          <!-- Map section -->
          <div class="map-section">
            <h3 class="sidebar-title">Location</h3>
            <div class="map-container">
              <Map
                :center="listing.location"
                :zoom="15"
                :pins="mapPins"
                non-interactive
                disable-controls
                class="listing-map"
              />
            </div>
            <div class="location-info">
              <Icon icon="tabler:map-pin" class="location-icon" />
              <span>{{ formatLocation(listing.location) }}</span>
            </div>
          </div>

          <!-- Details card -->
          <div class="details-card">
            <h3 class="sidebar-title">Details</h3>
            <div class="details-list">
              <div v-if="listing.duration_estimate" class="detail-row">
                <Icon icon="tabler:clock" class="detail-icon" />
                <div class="detail-content">
                  <span class="detail-label">Duration</span>
                  <span class="detail-value">{{ durationText }}</span>
                </div>
              </div>

              <div v-if="listing.compensation" class="detail-row">
                <Icon icon="mdi:currency-usd" class="detail-icon" />
                <div class="detail-content">
                  <span class="detail-label">Compensation</span>
                  <span class="detail-value">{{ listing.compensation }}</span>
                </div>
              </div>

              <div v-if="listing.expires_at" class="detail-row">
                <Icon icon="mdi:calendar-clock" class="detail-icon" />
                <div class="detail-content">
                  <span class="detail-label">Expires</span>
                  <span class="detail-value">{{ formatDate(listing.expires_at) }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- User card -->
          <div v-if="listing.user" class="user-card">
            <h3 class="sidebar-title">Posted by</h3>
            <div class="user-info">
              <img
                v-if="listing.user.avatar_url"
                :src="listing.user.avatar_url"
                :alt="listing.user.full_name || 'User'"
                class="user-avatar"
              />
              <div v-else class="user-avatar-placeholder">
                <Icon icon="mdi:account" class="avatar-icon" />
              </div>
              <div class="user-details">
                <h4 class="user-name">{{ listing.user.full_name || 'Anonymous User' }}</h4>
                <p class="user-email">{{ listing.user.email }}</p>
              </div>
            </div>
            <Button
              variant="primary"
              @click="contactUser"
              icon-left="mdi:message"
              class="contact-button"
            >
              Contact
            </Button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, onMounted, ref } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { Icon } from '@iconify/vue'
  import type { Listing } from '@/types'
  import { CATEGORIES, DURATION_OPTIONS } from '@/constants'
  import { useListingsStore } from '@/stores/listings'

  import Map from '@/components/geo/Map.vue'
  import ListingPills from '@/components/listings/ListingPills.vue'
  import Button from '@/components/widgets/Button.vue'

  const route = useRoute()
  const router = useRouter()
  const listingsStore = useListingsStore()

  const listing = ref<Listing | null>(null)
  const loading = ref(true)
  const error = ref<string | null>(null)
  const currentImageIndex = ref(0)

  const categoryText = computed(() => {
    if (!listing.value) return ''
    return CATEGORIES.find(cat => cat.value === listing.value.category)?.label ?? 'Unknown'
  })

  const categoryColor = computed(() => {
    if (!listing.value) return '#6b7280'
    return CATEGORIES.find(cat => cat.value === listing.value.category)?.color ?? '#6b7280'
  })

  const subcategoryText = computed(() => {
    if (!listing.value?.subcategory) return ''
    const category = CATEGORIES.find(cat => cat.value === listing.value.category)
    return (
      category?.subcategories?.find(sub => sub.value === listing.value.subcategory)?.label || ''
    )
  })

  const durationText = computed(() => {
    if (!listing.value?.duration_estimate) return ''
    return DURATION_OPTIONS.find(opt => opt.value === listing.value.duration_estimate)?.label || ''
  })

  const mapPins = computed(() => {
    if (!listing.value) return []
    return [
      {
        index: 1,
        lat: listing.value.location.lat,
        lng: listing.value.location.lng,
        color: categoryColor.value,
      },
    ]
  })

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    })
  }

  const formatLocation = (location: { lat: number; lng: number }) => {
    return `${location.lat.toFixed(4)}, ${location.lng.toFixed(4)}`
  }

  const contactUser = () => {
    // Handle contact user action
    console.log('Contact user clicked')
  }

  const fetchListing = async () => {
    try {
      loading.value = true
      const listingId = route.params.id as string

      // Try to get from store first
      const existingListing = listingsStore.listings.find(l => l.id === listingId)
      if (existingListing) {
        listing.value = existingListing
      } else {
        // Fetch from API if not in store
        await listingsStore.fetchListing(listingId)
        listing.value = listingsStore.listings.find(l => l.id === listingId) || null
      }

      if (!listing.value) {
        error.value = 'Listing not found'
      }
    } catch (err) {
      error.value = 'Failed to load listing'
      console.error('Error fetching listing:', err)
    } finally {
      loading.value = false
    }
  }

  onMounted(() => {
    fetchListing()
  })
</script>

<style scoped>
  .listing-show-container {
    @apply min-h-screen bg-gray-50;
  }

  .loading-state,
  .error-state {
    @apply flex flex-col items-center justify-center min-h-screen p-8 text-center;
  }

  .loading-spinner {
    @apply w-8 h-8 text-blue-500 animate-spin mb-4;
  }

  .error-icon {
    @apply w-12 h-12 text-red-500 mb-4;
  }

  .error-state h2 {
    @apply text-2xl font-bold text-gray-900 mb-2;
  }

  .error-state p {
    @apply text-gray-600 mb-6;
  }

  .listing-content {
    @apply bg-white;
  }

  .mobile-header {
    @apply md:hidden p-4 border-b border-gray-200;
  }

  .back-button {
    @apply text-gray-600;
  }

  .image-gallery {
    @apply relative w-full h-64 md:h-80 lg:h-96 overflow-hidden;
  }

  .main-image {
    @apply w-full h-full object-cover;
  }

  .image-nav {
    @apply absolute bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-2;
  }

  .image-dot {
    @apply w-3 h-3 rounded-full bg-white bg-opacity-50 hover:bg-opacity-75 transition-all cursor-pointer;
  }

  .image-dot.active {
    @apply bg-white;
  }

  .image-counter {
    @apply absolute top-4 right-4 bg-black bg-opacity-50 text-white px-3 py-1 rounded-full text-sm;
  }

  .content-grid {
    @apply max-w-7xl mx-auto px-4 py-8;
    @apply grid grid-cols-1 lg:grid-cols-3 gap-8;
  }

  .main-content {
    @apply lg:col-span-2 space-y-6;
  }

  .listing-header {
    @apply space-y-4;
  }

  .category-info {
    @apply flex items-center space-x-3;
  }

  .category-badge {
    @apply px-3 py-1 rounded-full text-white text-sm font-medium;
  }

  .subcategory-text {
    @apply text-gray-600 text-sm;
  }

  .listing-title {
    @apply text-3xl md:text-4xl font-bold text-gray-900 leading-tight;
    word-wrap: break-word;
    hyphens: auto;
  }

  .status-row {
    @apply flex items-center justify-between flex-wrap gap-4;
  }

  .status-badge {
    @apply flex items-center space-x-2 px-3 py-2 rounded-full text-sm font-medium;
    @apply bg-gray-100 text-gray-600;
  }

  .status-badge.active {
    @apply bg-green-100 text-green-800;
  }

  .status-icon {
    @apply w-4 h-4;
  }

  .date-info {
    @apply text-gray-500 text-sm;
  }

  .description-section {
    @apply space-y-4;
  }

  .section-title {
    @apply text-xl font-semibold text-gray-900;
  }

  .description-content {
    @apply prose prose-gray max-w-none;
  }

  .description-content p {
    @apply text-gray-700 leading-relaxed;
    white-space: pre-wrap;
  }

  .pills-section {
    @apply py-4;
  }

  .skills-section {
    @apply space-y-3;
  }

  .section-subtitle {
    @apply text-lg font-medium text-gray-900;
  }

  .skills-list {
    @apply flex flex-wrap gap-2;
  }

  .skill-tag {
    @apply px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-medium;
  }

  .sidebar {
    @apply space-y-6;
  }

  .map-section,
  .details-card,
  .user-card {
    @apply bg-white border border-gray-200 rounded-lg overflow-hidden;
  }

  .sidebar-title {
    @apply text-lg font-semibold text-gray-900 px-6 py-4 border-b border-gray-200;
  }

  .map-container {
    @apply relative h-48;
  }

  .listing-map {
    @apply w-full h-full;
  }

  .location-info {
    @apply flex items-center space-x-2 px-6 py-4 text-sm text-gray-600;
  }

  .location-icon {
    @apply w-4 h-4;
  }

  .details-list {
    @apply px-6 py-4 space-y-4;
  }

  .detail-row {
    @apply flex items-start space-x-3;
  }

  .detail-icon {
    @apply w-5 h-5 text-gray-400 mt-0.5;
  }

  .detail-content {
    @apply flex flex-col;
  }

  .detail-label {
    @apply text-sm font-medium text-gray-600;
  }

  .detail-value {
    @apply text-sm text-gray-900;
  }

  .user-info {
    @apply flex items-center space-x-3 px-6 py-4;
  }

  .user-avatar {
    @apply w-12 h-12 rounded-full object-cover;
  }

  .user-avatar-placeholder {
    @apply w-12 h-12 rounded-full bg-gray-200 flex items-center justify-center;
  }

  .avatar-icon {
    @apply w-6 h-6 text-gray-400;
  }

  .user-details {
    @apply flex-1;
  }

  .user-name {
    @apply font-medium text-gray-900;
  }

  .user-email {
    @apply text-sm text-gray-600;
  }

  .contact-button {
    @apply mx-6 mb-6;
  }

  /* Responsive adjustments */
  @media (max-width: 1024px) {
    .content-grid {
      @apply grid-cols-1;
    }

    .sidebar {
      @apply grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6;
    }
  }
</style>
