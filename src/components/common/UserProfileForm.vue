<template>
  <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
    <!-- Header -->
    <div class="mb-8">
      <h2 class="text-2xl font-bold text-gray-900 mb-2">
        {{ isNewProfile ? "Welcome! Let's set up your profile" : 'Edit Your Profile' }}
      </h2>
      <p class="text-gray-600">
        {{
          isNewProfile
            ? 'Please provide some basic information to get started with LocalHelp'
            : 'Update your profile information and preferences'
        }}
      </p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center py-8">
      <LoadingSpinner size="lg" text="Loading profile..." />
    </div>

    <!-- Form -->
    <form v-else @submit.prevent="handleSubmit" class="space-y-6">
      <!-- Basic Information -->
      <div class="space-y-6">
        <h3 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
          Basic Information
        </h3>

        <div class="grid md:grid-cols-2 gap-6">
          <div>
            <label for="fullName" class="block text-sm font-medium text-gray-700 mb-2">
              Full Name *
            </label>
            <input
              id="fullName"
              v-model="form.full_name"
              type="text"
              required
              class="input"
              :class="{
                'border-error-300 focus:border-error-500 focus:ring-error-500': errors.full_name,
              }"
              placeholder="Enter your full name"
            />
            <p v-if="errors.full_name" class="mt-1 text-sm text-error-600">
              {{ errors.full_name }}
            </p>
          </div>

          <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
              Email Address
            </label>
            <input
              id="email"
              :value="authStore.user?.email"
              type="email"
              disabled
              class="input bg-gray-50 text-gray-500"
            />
            <p class="text-xs text-gray-500 mt-1">Email cannot be changed</p>
          </div>
        </div>

        <div>
          <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">
            Phone Number
          </label>
          <input
            id="phone"
            v-model="form.phone"
            type="tel"
            class="input md:w-1/2"
            :class="{
              'border-error-300 focus:border-error-500 focus:ring-error-500': errors.phone,
            }"
            placeholder="Enter your phone number (optional)"
          />
          <p v-if="errors.phone" class="mt-1 text-sm text-error-600">
            {{ errors.phone }}
          </p>
        </div>
      </div>

      <!-- Location & Preferences -->
      <div class="space-y-6">
        <h3 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
          Location & Preferences
        </h3>

        <!-- Location Setup -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2"> Your Location </label>

          <div v-if="locationStatus === 'loading'" class="p-4 bg-gray-50 rounded-md">
            <LoadingSpinner text="Getting your location..." />
          </div>

          <div v-else-if="locationStatus === 'error'" class="p-4 bg-error-50 rounded-md">
            <div class="flex items-start">
              <ExclamationTriangleIcon class="w-5 h-5 text-error-600 mt-0.5 mr-3 flex-shrink-0" />
              <div class="flex-1">
                <p class="text-sm text-error-700 mb-2">{{ locationError }}</p>
                <button type="button" @click="requestLocation" class="btn btn-outline btn-sm">
                  Try Again
                </button>
              </div>
            </div>
          </div>

          <div v-else-if="form.location" class="p-4 bg-success-50 rounded-md">
            <div class="flex items-start justify-between">
              <div class="flex items-start">
                <CheckCircleIcon class="w-5 h-5 text-success-600 mt-0.5 mr-3 flex-shrink-0" />
                <div>
                  <p class="text-sm text-success-700 font-medium">Location set successfully</p>
                  <p class="text-sm text-success-600 mt-1">{{ form.location.address }}</p>
                </div>
              </div>
              <button type="button" @click="requestLocation" class="btn btn-outline btn-sm">
                Update Location
              </button>
            </div>
          </div>

          <div v-else class="p-4 bg-gray-50 rounded-md">
            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <MapPinIcon class="w-5 h-5 text-gray-400 mr-3" />
                <span class="text-sm text-gray-600">Location not set</span>
              </div>
              <button type="button" @click="requestLocation" class="btn btn-primary btn-sm">
                Set Location
              </button>
            </div>
          </div>
        </div>

        <!-- Notification Radius -->
        <div>
          <label for="notificationRadius" class="block text-sm font-medium text-gray-700 mb-2">
            Notification Radius: {{ form.notification_radius }} miles
          </label>
          <input
            id="notificationRadius"
            v-model.number="form.notification_radius"
            type="range"
            min="0.5"
            max="10"
            step="0.5"
            class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer slider md:w-1/2"
          />
          <div class="flex justify-between text-xs text-gray-500 mt-1 md:w-1/2">
            <span>0.5mi</span>
            <span>10mi</span>
          </div>
          <p class="text-xs text-gray-500 mt-1">
            You'll receive notifications for requests within this radius
          </p>
        </div>
      </div>

      <!-- Error/Success Messages -->
      <div v-if="submitError" class="rounded-md bg-error-50 p-4">
        <div class="flex">
          <ExclamationTriangleIcon class="w-5 h-5 text-error-400 mr-3 flex-shrink-0" />
          <div class="text-sm text-error-700">
            {{ submitError }}
          </div>
        </div>
      </div>

      <div v-if="submitSuccess" class="rounded-md bg-success-50 p-4">
        <div class="flex">
          <CheckCircleIcon class="w-5 h-5 text-success-400 mr-3 flex-shrink-0" />
          <div class="text-sm text-success-700">
            {{ isNewProfile ? 'Profile created successfully!' : 'Profile updated successfully!' }}
          </div>
        </div>
      </div>

      <!-- Submit Button -->
      <div class="flex justify-end pt-6 border-t border-gray-200">
        <button type="submit" :disabled="isSubmitting || !isFormValid" class="btn btn-primary">
          <LoadingSpinner v-if="isSubmitting" size="sm" />
          {{ isNewProfile ? 'Create Profile' : 'Update Profile' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, onMounted } from 'vue'
  import { ExclamationTriangleIcon, CheckCircleIcon, MapPinIcon } from '@heroicons/vue/24/outline'
  import { useAuthStore } from '@/stores/auth'
  import { LocationService } from '@/services/location'
  import type { User } from '@/types'

  interface Props {
    /** Optional existing profile data */
    existingProfile?: User | null
    /** Whether to show the form in a compact layout */
    compact?: boolean
  }

  interface Emits {
    /** Emitted when profile is successfully created or updated */
    (e: 'success', profile: User): void
    /** Emitted when an error occurs */
    (e: 'error', error: string): void
  }

  const props = withDefaults(defineProps<Props>(), {
    existingProfile: null,
    compact: false,
  })

  const emit = defineEmits<Emits>()

  const authStore = useAuthStore()

  // Form state
  const loading = ref(false)
  const isSubmitting = ref(false)
  const submitError = ref('')
  const submitSuccess = ref(false)

  // Location state
  const locationStatus = ref<'idle' | 'loading' | 'success' | 'error'>('idle')
  const locationError = ref('')

  // Form validation errors
  const errors = reactive({
    full_name: '',
    phone: '',
  })

  // Form data
  const form = reactive({
    full_name: '',
    phone: '',
    location: null as Location | null,
    notification_radius: 2,
  })

  // Computed properties
  const isNewProfile = computed(() => !props.existingProfile)

  const isFormValid = computed(() => {
    return !!(form.full_name.trim() && !errors.full_name && !errors.phone)
  })

  // Validation functions
  const validateFullName = () => {
    errors.full_name = ''
    if (!form.full_name.trim()) {
      errors.full_name = 'Full name is required'
    } else if (form.full_name.trim().length < 2) {
      errors.full_name = 'Full name must be at least 2 characters'
    }
  }

  const validatePhone = () => {
    errors.phone = ''
    if (form.phone && form.phone.trim()) {
      // Basic phone validation - adjust regex as needed
      const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/
      if (!phoneRegex.test(form.phone.replace(/[\s\-\(\)]/g, ''))) {
        errors.phone = 'Please enter a valid phone number'
      }
    }
  }

  // Location handling
  const requestLocation = async () => {
    locationStatus.value = 'loading'
    locationError.value = ''

    try {
      const position = await LocationService.getCurrentPosition()
      const address = await LocationService.reverseGeocode(position.latitude, position.longitude)

      form.location = {
        latitude: position.latitude,
        longitude: position.longitude,
        address,
      }

      locationStatus.value = 'success'
    } catch (error: any) {
      locationStatus.value = 'error'
      locationError.value =
        error.message || 'Unable to get your location. Please ensure location services are enabled.'
      console.error('Location error:', error)
    }
  }

  // Form submission
  const handleSubmit = async () => {
    // Validate form
    validateFullName()
    validatePhone()

    if (!isFormValid.value) {
      return
    }

    if (!authStore.session) {
      submitError.value = 'Not authenticated'
      return
    }

    isSubmitting.value = true
    submitError.value = ''
    submitSuccess.value = false

    try {
      const profileData = {
        full_name: form.full_name.trim(),
        phone: form.phone.trim() || undefined,
        location: form.location || undefined,
        notification_radius: form.notification_radius,
      }

      let result
      if (isNewProfile.value) {
        // Create new profile
        result = await authStore.updateProfile(profileData)
      } else {
        // Update existing profile
        result = await authStore.updateProfile(profileData)
      }

      if (result.error) {
        submitError.value = result.error
        emit('error', result.error)
      } else {
        submitSuccess.value = true
        emit('success', result.data)

        // Clear success message after 3 seconds
        setTimeout(() => {
          submitSuccess.value = false
        }, 3000)
      }
    } catch (error: any) {
      const errorMessage = error.message || 'An error occurred while saving your profile'
      submitError.value = errorMessage
      emit('error', errorMessage)
    } finally {
      isSubmitting.value = false
    }
  }

  // Initialize form
  const initializeForm = () => {
    if (props.existingProfile) {
      // Populate form with existing data
      form.full_name = props.existingProfile.full_name || ''
      form.phone = props.existingProfile.phone || ''
      form.location = props.existingProfile.location || null
      form.notification_radius = props.existingProfile.notification_radius || 2

      if (form.location) {
        locationStatus.value = 'success'
      }
    } else {
      // New profile - try to get location
      requestLocation()
    }
  }

  // Lifecycle
  onMounted(() => {
    initializeForm()
  })

  // Watch for form changes to clear errors
  const clearFieldError = (field: keyof typeof errors) => {
    errors[field] = ''
  }

  // Expose methods for parent components
  defineExpose({
    requestLocation,
    validateForm: () => {
      validateFullName()
      validatePhone()
      return isFormValid.value
    },
    resetForm: initializeForm,
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
