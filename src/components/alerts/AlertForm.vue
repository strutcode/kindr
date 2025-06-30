<template>
  <div class="alert-form">
    <form @submit.prevent="handleSubmit" class="space-y-6">
      <!-- Alert Name -->
      <div>
        <label for="alert-name" class="block text-sm font-medium text-gray-700 mb-2">
          Alert Name
        </label>
        <input
          id="alert-name"
          v-model="form.name"
          type="text"
          required
          placeholder="e.g. 'Downtown alerts' or 'Help needed in my area'"
          class="input"
          :disabled="loading"
        />
        <p class="mt-1 text-sm text-gray-500">
          Give your alert a descriptive name to help you identify it later.
        </p>
      </div>

      <!-- Location -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2"> Location </label>
        <LocationSelector v-model="form.location" :disabled="loading" class="mb-2" />
        <p class="text-sm text-gray-500">Set the center point for your alert area.</p>
      </div>

      <!-- Radius -->
      <div>
        <label for="alert-radius" class="block text-sm font-medium text-gray-700 mb-2">
          Alert Radius: {{ radiusDisplay }}
        </label>
        <input
          id="alert-radius"
          v-model.number="form.radius_meters"
          type="range"
          min="500"
          max="50000"
          step="500"
          class="slider"
          :disabled="loading"
        />
        <div class="flex justify-between text-xs text-gray-500 mt-1">
          <span>500m</span>
          <span>50km</span>
        </div>
        <p class="mt-1 text-sm text-gray-500">
          You'll be notified about new listings within this distance from your location.
        </p>
      </div>

      <!-- Category Filter -->
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-2">
          Category Filter (Optional)
        </label>
        <div class="space-y-2">
          <label class="flex items-center">
            <input
              v-model="form.category"
              type="radio"
              value=""
              class="radio"
              :disabled="loading"
            />
            <span class="ml-2 text-sm text-gray-700">All categories</span>
          </label>
          <label v-for="category in CATEGORIES" :key="category.value" class="flex items-center">
            <input
              v-model="form.category"
              type="radio"
              :value="category.value"
              class="radio"
              :disabled="loading"
            />
            <span class="ml-2 text-sm text-gray-700">{{ category.label }}</span>
          </label>
        </div>
        <p class="mt-1 text-sm text-gray-500">
          Only get notified about listings in specific categories, or leave unselected for all.
        </p>
      </div>

      <!-- Error Message -->
      <div v-if="error" class="error-message">
        <Icon icon="tabler:alert-triangle" class="error-icon" />
        <span>{{ error }}</span>
      </div>

      <!-- Form Actions -->
      <div class="form-actions">
        <Button :loading="loading" :disabled="!isFormValid">
          {{ isEditing ? 'Update Alert' : 'Create Alert' }}
        </Button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, onMounted } from 'vue'
  import { Icon } from '@iconify/vue'
  import type { Alert, Location } from '@/types'
  import { CATEGORIES } from '@/constants'
  import Button from '@/components/widgets/Button.vue'
  import LocationSelector from '@/components/widgets/LocationSelector.vue'
  import { useLocationStore } from '@/stores/location'

  interface Props {
    alert?: Alert | null
    loading?: boolean
  }

  interface Emits {
    (
      e: 'submit',
      data: {
        name: string
        location: Location
        radius_meters: number
        category?: string
      },
    ): void
    (e: 'cancel'): void
  }

  const props = withDefaults(defineProps<Props>(), {
    alert: null,
    loading: false,
  })

  const emit = defineEmits<Emits>()
  const locationStore = useLocationStore()

  const error = ref('')

  const form = reactive({
    name: '',
    location: { lat: 0, lng: 0 } as Location,
    radius_meters: 5000, // Default 5km
    category: '', // Empty string means all categories
  })

  const isEditing = computed(() => !!props.alert)

  const radiusDisplay = computed(() => {
    const km = form.radius_meters / 1000
    return km < 1 ? `${form.radius_meters}m` : `${km.toFixed(1)}km`
  })

  const isFormValid = computed(() => {
    return (
      form.name.trim().length > 0 &&
      form.location.lat !== 0 &&
      form.location.lng !== 0 &&
      form.radius_meters >= 500 &&
      form.radius_meters <= 50000
    )
  })

  const handleSubmit = () => {
    if (!isFormValid.value) return

    error.value = ''

    const submitData = {
      name: form.name.trim(),
      location: form.location,
      radius_meters: form.radius_meters,
      category: form.category || undefined,
    }

    emit('submit', submitData)
  }

  // Initialize form data
  onMounted(async () => {
    if (props.alert) {
      // Editing existing alert
      form.name = props.alert.name
      form.location = { ...props.alert.location }
      form.radius_meters = props.alert.radius_meters
      form.category = props.alert.category || ''
    } else {
      // Creating new alert - use current location if available
      if (locationStore.creationLocation) {
        form.location = { ...locationStore.creationLocation }
      }
    }
  })
</script>

<style scoped>
  .alert-form {
    @apply bg-white rounded-lg border border-gray-200 p-6;
  }

  .input {
    @apply w-full px-3 py-2 border border-gray-300 rounded-md;
    @apply focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent;
    @apply disabled:bg-gray-100 disabled:cursor-not-allowed;
  }

  .slider {
    @apply w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer;
    @apply disabled:cursor-not-allowed disabled:opacity-50;
  }

  .slider::-webkit-slider-thumb {
    @apply appearance-none w-4 h-4 bg-blue-500 rounded-full cursor-pointer;
    @apply hover:bg-blue-600 transition-colors;
  }

  .slider::-moz-range-thumb {
    @apply w-4 h-4 bg-blue-500 rounded-full cursor-pointer border-0;
    @apply hover:bg-blue-600 transition-colors;
  }

  .radio {
    @apply w-4 h-4 text-blue-600 border-gray-300;
    @apply focus:ring-blue-500 focus:ring-2;
  }

  .error-message {
    @apply flex items-center gap-2 p-3 bg-red-50 border border-red-200 rounded-md;
    @apply text-red-700 text-sm;
  }

  .error-icon {
    @apply w-5 h-5 text-red-500 flex-shrink-0;
  }

  .form-actions {
    @apply flex gap-3 pt-4 border-t border-gray-200;
  }
</style>
