<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <StatusBanner v-if="submitError" type="error">
      <div class="flex items-center">
        <ExclamationTriangleIcon class="w-5 h-5 text-error-600 mr-3 flex-shrink-0" />
        <div class="text-sm text-error-700">
          {{ submitError }}
        </div>
      </div>
    </StatusBanner>

    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900 mb-2">Create New Request</h1>
        <p class="text-gray-600">Share what you need or offer help to your community</p>
      </div>

      <form @submit.prevent="handleSubmit" class="space-y-8">
        <!-- Basic Information -->
        <div class="space-y-6">
          <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
            Basic Information
          </h2>

          <div>
            <label for="title" class="block text-sm font-medium text-gray-700 mb-2">
              Title *
            </label>
            <input
              id="title"
              v-model="form.title"
              type="text"
              required
              class="input"
              placeholder="Brief description of your request"
            />
          </div>

          <div>
            <label for="description" class="block text-sm font-medium text-gray-700 mb-2">
              Description *
            </label>
            <textarea
              id="description"
              v-model="form.description"
              rows="4"
              required
              class="input"
              placeholder="Provide detailed information about what you need or offer"
            />
          </div>
        </div>

        <!-- Category and Details -->
        <div class="space-y-6">
          <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
            Category & Details
          </h2>

          <div class="grid md:grid-cols-2 gap-6">
            <div>
              <label for="category" class="block text-sm font-medium text-gray-700 mb-2">
                Category *
              </label>
              <select
                id="category"
                v-model="form.category"
                required
                class="input"
                @change="handleCategoryChange"
              >
                <option value="">Select a category</option>
                <option
                  v-for="category in CATEGORIES"
                  :key="category.value"
                  :value="category.value"
                >
                  {{ category.label }}
                </option>
              </select>
            </div>

            <div v-if="form.category">
              <label for="subcategory" class="block text-sm font-medium text-gray-700 mb-2">
                Subcategory *
              </label>
              <select id="subcategory" v-model="form.subcategory" required class="input">
                <option value="">Select a subcategory</option>
                <option
                  v-for="subcategory in selectedCategorySubcategories"
                  :key="subcategory.value"
                  :value="subcategory.value"
                >
                  {{ subcategory.label }}
                </option>
              </select>
            </div>
          </div>

          <!-- Conditional Duration Field - Only for Help Needed -->
          <div v-if="showDurationField" class="transition-all duration-300 ease-in-out">
            <label for="duration" class="block text-sm font-medium text-gray-700 mb-2">
              Estimated Duration *
            </label>
            <select
              id="duration"
              v-model="form.duration_estimate"
              :required="isDurationRequired"
              class="input md:w-1/2"
            >
              <option value="">Select duration</option>
              <option
                v-for="duration in DURATION_OPTIONS"
                :key="duration.value"
                :value="duration.value"
              >
                {{ duration.label }}
              </option>
            </select>
            <p class="text-xs text-gray-500 mt-1">How long do you estimate this task will take?</p>
          </div>

          <div>
            <label for="skills" class="block text-sm font-medium text-gray-700 mb-2">
              Skills Required
            </label>
            <input
              id="skills"
              v-model="skillsInput"
              type="text"
              class="input"
              placeholder="e.g., driving, heavy lifting, computer skills (press Enter to add)"
              @keydown.enter.prevent="addSkill"
            />
            <div v-if="form.skills_required.length" class="mt-2 flex flex-wrap gap-2">
              <span
                v-for="(skill, index) in form.skills_required"
                :key="index"
                class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-primary-100 text-primary-800"
              >
                {{ skill }}
                <button
                  type="button"
                  @click="removeSkill(index)"
                  class="ml-2 text-primary-600 hover:text-primary-500"
                >
                  <XMarkIcon class="w-4 h-4" />
                </button>
              </span>
            </div>
          </div>

          <div>
            <label for="compensation" class="block text-sm font-medium text-gray-700 mb-2">
              Compensation (Optional)
            </label>
            <input
              id="compensation"
              v-model="form.compensation"
              type="text"
              class="input"
              placeholder="e.g., $20, Coffee & snacks, Gas money"
            />
          </div>
        </div>

        <!-- Images -->
        <div class="space-y-6">
          <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
            Images (Optional)
          </h2>

          <div>
            <p class="text-sm text-gray-600 mb-4">
              Add images to help others understand your request better. You can upload up to 8
              images.
            </p>

            <ImageUpload
              ref="imageUploadRef"
              :max-images="8"
              @images-changed="handleImagesChanged"
              @upload-error="handleImageUploadError"
            />
          </div>
        </div>

        <!-- Location -->
        <div class="space-y-6">
          <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
            Location
          </h2>

          <div v-if="locationStatus === 'loading'" class="p-4 bg-gray-50 rounded-md">
            <LoadingSpinner text="Getting your location..." />
          </div>

          <div v-else-if="locationStatus === 'error'" class="mb-4">
            <StatusBanner type="error">
              <div class="flex items-center">
                <ExclamationTriangleIcon class="w-5 h-5 text-error-600 mr-3 flex-shrink-0" />
                <div>
                  <p class="text-sm text-error-700 mb-2">{{ locationError }}</p>
                  <button type="button" @click="requestLocation" class="btn btn-outline btn-sm">
                    Try Again
                  </button>
                </div>
              </div>
            </StatusBanner>
          </div>

          <div v-else-if="form.location" class="p-4 bg-success-50 rounded-md">
            <p class="text-sm text-success-700">✓ Location set: {{ form.location.address }}</p>
          </div>
        </div>

        <!-- Submit -->
        <div class="flex items-center justify-between pt-6 border-t border-gray-200">
          <router-link to="/requests" class="btn btn-outline"> Cancel </router-link>

          <button
            type="submit"
            :disabled="isSubmitting || !isFormValid || isUploadingImages"
            class="btn btn-primary"
          >
            <LoadingSpinner v-if="isSubmitting" size="sm" />
            <span v-if="isUploadingImages">Uploading Images...</span>
            <span v-else>Create Request</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, reactive, watch } from 'vue'
  import { useRouter } from 'vue-router'
  import { XMarkIcon, ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
  import { useRequestsStore } from '@/stores/requests'
  import { useAuthStore } from '@/stores/auth'
  import { LocationService } from '@/services/location'
  import { CATEGORIES, DURATION_OPTIONS } from '@/constants/categories'
  import LoadingSpinner from '@/components/common/LoadingSpinner.vue'
  import ImageUpload from '@/components/common/ImageUpload.vue'
  import StatusBanner from '@/components/common/StatusBanner.vue'
  import type { Request, RequestCategory, DurationEstimate } from '@/types'

  const router = useRouter()
  const requestsStore = useRequestsStore()
  const authStore = useAuthStore()

  const isSubmitting = ref(false)
  const skillsInput = ref('')
  const locationStatus = ref<'idle' | 'loading' | 'success' | 'error'>('idle')
  const locationError = ref('')
  const submitError = ref('')
  const imageUploadRef = ref<InstanceType<typeof ImageUpload>>()
  const uploadedImageUrls = ref<string[]>([])

  const form = reactive({
    title: '',
    description: '',
    category: '' as RequestCategory | '',
    subcategory: '',
    duration_estimate: '' as DurationEstimate | '',
    skills_required: [] as string[],
    compensation: '',
    location: null as { latitude: number; longitude: number; address: string } | null,
  })

  const selectedCategorySubcategories = computed(() => {
    if (!form.category) return []
    return CATEGORIES.find(cat => cat.value === form.category)?.subcategories || []
  })

  // Show duration field only for "help-needed" category
  const showDurationField = computed(() => {
    return form.category === 'help-needed'
  })

  // Duration is required only for "help-needed" category
  const isDurationRequired = computed(() => {
    return form.category === 'help-needed'
  })

  const isUploadingImages = computed(() => {
    return imageUploadRef.value?.isUploading() || false
  })

  const isFormValid = computed(() => {
    const baseValidation = !!(
      form.title &&
      form.description &&
      form.category &&
      form.subcategory &&
      form.location &&
      !isUploadingImages.value
    )

    // Additional validation for duration when it's required
    if (isDurationRequired.value) {
      return baseValidation && !!form.duration_estimate
    }

    return baseValidation
  })

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

  const addSkill = () => {
    const skill = skillsInput.value.trim()
    if (skill && !form.skills_required.includes(skill)) {
      form.skills_required.push(skill)
      skillsInput.value = ''
    }
  }

  const removeSkill = (index: number) => {
    form.skills_required.splice(index, 1)
  }

  const handleCategoryChange = () => {
    // Clear subcategory when category changes
    form.subcategory = ''

    // Clear duration when switching away from help-needed
    if (form.category !== 'help-needed') {
      form.duration_estimate = ''
    }
  }

  const handleImagesChanged = (urls: string[]) => {
    uploadedImageUrls.value = urls
  }

  const handleImageUploadError = (errors: string[]) => {
    console.error('Image upload errors:', errors)
    // Errors are already displayed in the ImageUpload component
  }

  const handleSubmit = async () => {
    if (!authStore.user) {
      submitError.value = 'Not authenticated'
      return
    }

    if (!isFormValid.value) {
      submitError.value = 'Please fill in all required fields'
      return
    }

    // Wait for any pending image uploads
    if (isUploadingImages.value) {
      submitError.value = 'Please wait for image uploads to complete'
      return
    }

    isSubmitting.value = true
    submitError.value = ''

    try {
      const requestData = {
        user_id: authStore.user.id,
        title: form.title,
        description: form.description,
        category: form.category as RequestCategory,
        subcategory: form.subcategory,
        // Only include duration_estimate if it's required and provided
        duration_estimate: isDurationRequired.value
          ? (form.duration_estimate as DurationEstimate)
          : undefined,
        skills_required: form.skills_required,
        compensation: form.compensation || undefined,
        images: uploadedImageUrls.value,
        location: form.location!,
        status: 'active' as const,
      }

      const result = await requestsStore.createRequest(requestData)

      if (result.error) {
        throw new Error(result.error)
      }

      router.push('/requests')
    } catch (error: any) {
      submitError.value = error.message || 'Failed to create request'
      console.error('Error creating request:', error)
    } finally {
      isSubmitting.value = false
    }
  }

  onMounted(() => {
    requestLocation()
  })

  // Clear subcategory when category changes
  watch(
    () => form.category,
    () => {
      form.subcategory = ''
      // Clear duration when switching away from help-needed
      if (form.category !== 'help-needed') {
        form.duration_estimate = ''
      }
    },
  )
</script>
