<template>
  <div class="overlay-backdrop" @click="emit('close')">
    <div class="overlay-content" @click.stop>
      <!-- Header with close button -->
      <div class="overlay-header">
        <h2 class="title">{{ listing.title }}</h2>
        <button class="close-button" @click="emit('close')">
          <Icon icon="mdi:close" class="w-6 h-6" />
        </button>
      </div>

      <!-- Main content -->
      <div class="overlay-body">
        <!-- Image section -->
        <div v-if="listing.images?.length" class="image-section">
          <img :src="listing.images[currentImageIndex]" :alt="listing.title" class="main-image" />
          <div v-if="listing.images.length > 1" class="image-nav">
            <button
              v-for="(image, index) in listing.images"
              :key="index"
              @click="currentImageIndex = index"
              :class="['image-dot', { active: index === currentImageIndex }]"
            />
          </div>
        </div>

        <!-- Info section -->
        <div class="info-section">
          <!-- Category and status -->
          <div class="category-row">
            <div class="category-badge" :style="{ backgroundColor: categoryColor }">
              {{ categoryText }}
            </div>
            <div class="status-badge" :class="{ active: listing.active }">
              {{ listing.active ? 'Active' : 'Inactive' }}
            </div>
          </div>

          <!-- Description -->
          <div class="description">
            <p>{{ listing.description }}</p>
          </div>

          <!-- Pills for subcategory, skills, duration -->
          <div class="pills-section">
            <ListingPills :listing="listing" />
          </div>

          <!-- Details grid -->
          <div class="details-grid">
            <div v-if="listing.duration_estimate" class="detail-item">
              <Icon icon="mdi:clock-outline" class="detail-icon" />
              <span class="detail-label">Duration:</span>
              <span class="detail-value">{{ durationText }}</span>
            </div>

            <div v-if="listing.compensation" class="detail-item">
              <Icon icon="mdi:currency-usd" class="detail-icon" />
              <span class="detail-label">Compensation:</span>
              <span class="detail-value">{{ listing.compensation }}</span>
            </div>

            <div class="detail-item">
              <Icon icon="mdi:map-marker" class="detail-icon" />
              <span class="detail-label">Location:</span>
              <span class="detail-value">{{ formatLocation(listing.location) }}</span>
            </div>

            <div class="detail-item">
              <Icon icon="mdi:calendar" class="detail-icon" />
              <span class="detail-label">Posted:</span>
              <span class="detail-value">{{ formatDate(listing.created_at) }}</span>
            </div>

            <div v-if="listing.expires_at" class="detail-item">
              <Icon icon="mdi:calendar-clock" class="detail-icon" />
              <span class="detail-label">Expires:</span>
              <span class="detail-value">{{ formatDate(listing.expires_at) }}</span>
            </div>
          </div>

          <!-- User info -->
          <div v-if="listing.user" class="user-section">
            <DisplayUser :user="listing.user" class="user-info" />
          </div>
        </div>
      </div>

      <!-- Footer with actions -->
      <div class="overlay-footer">
        <Button variant="outline" :link="{ name: 'show', params: { id: listing.id } }"
          >Details</Button
        >
        <Button v-if="authStore.isAuthenticated" variant="primary" @click="contactUser">
          <Icon icon="mdi:message" class="w-4 h-4 mr-2" />
          Contact
        </Button>
        <Button v-else variant="primary" :link="{ name: 'auth' }">
          <Icon icon="mdi:message" class="w-4 h-4 mr-2" />
          Log in or Sign Up To Connect
        </Button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, ref } from 'vue'
  import { Icon } from '@iconify/vue'
  import { useRouter } from 'vue-router'

  import { useAuthStore } from '@/stores/auth'
  import { useChatStore } from '@/stores/chat'
  import type { Listing } from '@/types'
  import { CATEGORIES, DURATION_OPTIONS } from '@/constants'

  import ListingPills from './ListingPills.vue'
  import Button from '@/components/widgets/Button.vue'
  import DisplayUser from '@/components/widgets/UserDisplay.vue'

  interface Props {
    listing: Listing
  }

  const props = defineProps<Props>()
  const router = useRouter()

  const authStore = useAuthStore()
  const chatStore = useChatStore()

  const emit = defineEmits<{
    (e: 'close'): void
    (e: 'contact', listing: Listing): void
  }>()

  const currentImageIndex = ref(0)

  const categoryText = computed(() => {
    return CATEGORIES.find(cat => cat.value === props.listing.category)?.label ?? 'Unknown'
  })

  const categoryColor = computed(() => {
    return CATEGORIES.find(cat => cat.value === props.listing.category)?.color ?? '#6b7280'
  })

  const durationText = computed(() => {
    if (props.listing.duration_estimate) {
      return DURATION_OPTIONS.find(opt => opt.value === props.listing.duration_estimate)?.label
    }
    return ''
  })

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    })
  }

  const formatLocation = (location: { lat: number; lng: number }) => {
    return `${location.lat.toFixed(4)}, ${location.lng.toFixed(4)}`
  }

  const contactUser = async () => {
    if (!authStore.user || !props.listing) return

    // Check if user is trying to contact themselves
    if (authStore.user.id === props.listing.user_id) {
      alert('You cannot start a chat with yourself')
      return
    }

    try {
      // Get or create chat for this listing
      const chatId = await chatStore.getOrCreateChat(props.listing.id)

      // Navigate to the chat
      router.push({ name: 'chat', params: { id: chatId } })
    } catch (error) {
      console.error('Failed to start chat:', error)
      alert('Failed to start chat. Please try again.')
    }
  }
</script>

<style scoped>
  .overlay-backdrop {
    @apply fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4;
  }

  .overlay-content {
    @apply bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-hidden;
    @apply flex flex-col;
  }

  .overlay-header {
    @apply flex items-center justify-between p-6 border-b border-gray-200;
  }

  .title {
    @apply text-xl font-semibold text-gray-900 pr-4;
  }

  .close-button {
    @apply p-1 hover:bg-gray-100 rounded-full transition-colors;
  }

  .overlay-body {
    @apply flex-1 overflow-y-auto;
  }

  .image-section {
    @apply relative;
  }

  .main-image {
    @apply w-full h-64 object-cover;
  }

  .image-nav {
    @apply absolute bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-2;
  }

  .image-dot {
    @apply w-3 h-3 rounded-full bg-white bg-opacity-50 hover:bg-opacity-75 transition-all;
  }

  .image-dot.active {
    @apply bg-white;
  }

  .info-section {
    @apply p-6 space-y-4;
  }

  .category-row {
    @apply flex items-center justify-between;
  }

  .category-badge {
    @apply px-3 py-1 rounded-full text-white text-sm font-medium;
  }

  .status-badge {
    @apply px-3 py-1 rounded-full text-sm font-medium bg-gray-100 text-gray-600;
  }

  .status-badge.active {
    @apply bg-green-100 text-green-800;
  }

  .description {
    @apply text-gray-700 leading-relaxed;
  }

  .pills-section {
    @apply py-2;
  }

  .details-grid {
    @apply space-y-3;
  }

  .detail-item {
    @apply flex items-center space-x-3 text-sm;
  }

  .detail-icon {
    @apply w-5 h-5 text-gray-400;
  }

  .detail-label {
    @apply font-medium text-gray-600 min-w-[80px];
  }

  .detail-value {
    @apply text-gray-900;
  }

  .user-section {
    @apply border-t border-gray-200 pt-4;
  }

  .overlay-footer {
    @apply flex items-center justify-end space-x-3 p-6 border-t border-gray-200 bg-gray-50;
  }
</style>
