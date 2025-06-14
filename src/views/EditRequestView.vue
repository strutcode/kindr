<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Loading State -->
    <div v-if="loading" class="text-center py-12">
      <LoadingSpinner size="lg" text="Loading request..." />
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="text-center py-12">
      <div class="w-16 h-16 bg-error-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <ExclamationTriangleIcon class="w-8 h-8 text-error-600" />
      </div>
      <h3 class="text-lg font-medium text-gray-900 mb-2">Unable to load request</h3>
      <p class="text-gray-600 mb-6">{{ error }}</p>
      <div class="flex justify-center space-x-3">
        <router-link to="/requests" class="btn btn-outline">
          Back to Requests
        </router-link>
        <button @click="fetchRequest" class="btn btn-primary">
          Try Again
        </button>
      </div>
    </div>

    <!-- Edit Form -->
    <div v-else-if="request" class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900 mb-2">Edit Request</h1>
        <p class="text-gray-600">Update your community request details</p>
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
              :class="{ 'border-error-300 focus:border-error-500 focus:ring-error-500': errors.title }"
              placeholder="Brief description of your request"
            />
            <p v-if="errors.title" class="mt-1 text-sm text-error-600">
              {{ errors.title }}
            </p>
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
              :class="{ 'border-error-300 focus:border-error-500 focus:ring-error-500': errors.description }"
              placeholder="Provide detailed information about what you need or offer"
            />
            <p v-if="errors.description" class="mt-1 text-sm text-error-600">
              {{ errors.description }}
            </p>
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
                :class="{ 'border-error-300 focus:border-error-500 focus:ring-error-500': errors.category }"
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
              <p v-if="errors.category" class="mt-1 text-sm text-error-600">
                {{ errors.category }}
              </p>
            </div>

            <div v-if="form.category">
              <label for="subcategory" class="block text-sm font-medium text-gray-700 mb-2">
                Subcategory *
              </label>
              <select
                id="subcategory"
                v-model="form.subcategory"
                required
                class="input"
                :class="{ 'border-error-300 focus:border-error-500 focus:ring-error-500': errors.subcategory }"
              >
                <option value="">Select a subcategory</option>
                <option 
                  v-for="subcategory in selectedCategorySubcategories" 
                  :key="subcategory.value" 
                  :value="subcategory.value"
                >
                  {{ subcategory.label }}
                </option>
              </select>
              <p v-if="errors.subcategory" class="mt-1 text-sm text-error-600">
                {{ errors.subcategory }}
              </p>
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
              :class="{ 'border-error-300 focus:border-error-500 focus:ring-error-500': errors.duration_estimate }"
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
            <p v-if="errors.duration_estimate" class="mt-1 text-sm text-error-600">
              {{ errors.duration_estimate }}
            </p>
            <p class="text-xs text-gray-500 mt-1">
              How long do you estimate this task will take?
            </p>
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
              Add or update images to help others understand your request better. You can upload up to 8 images.
            </p>
            
            <ImageUpload
              ref="imageUploadRef"
              :max-images="8"
              :existing-images="form.images"
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
          
          <div v-else-if="locationStatus === 'error'" class="p-4 bg-error-50 rounded-md">
            <p class="text-sm text-error-700 mb-2">{{ locationError }}</p>
            <button 
              type="button"
              @click="requestLocation"
              class="btn btn-outline btn-sm"
            >
              Try Again
            </button>
          </div>
          
          <div v-else-if="form.location" class="p-4 bg-success-50 rounded-md">
            <div class="flex items-start justify-between">
              <div class="flex items-start">
                <CheckCircleIcon class="w-5 h-5 text-success-600 mt-0.5 mr-3 flex-shrink-0" />
                <div>
                  <p class="text-sm text-success-700 font-medium">Location set</p>
                  <p class="text-sm text-success-600 mt-1">{{ form.location.address }}</p>
                </div>
              </div>
              <button 
                type="button"
                @click="requestLocation"
                class="btn btn-outline btn-sm"
              >
                Update Location
              </button>
            </div>
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
              Request updated successfully!
            </div>
          </div>
        </div>

        <!-- Submit Button -->
        <div class="flex items-center justify-between pt-6 border-t border-gray-200">
          <router-link 
            :to="`/requests/${request.id}`"
            class="btn btn-outline"
          >
            Cancel
          </router-link>
          
          <button
            type="submit"
            :disabled="isSubmitting || !isFormValid || isUploadingImages"
            class="btn btn-primary"
          >
            <LoadingSpinner v-if="isSubmitting" size="sm" />
            <span v-if="isUploadingImages">Uploading Images...</span>
            <span v-else>Update Request</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { XMarkIcon, ExclamationTriangleIcon, CheckCircleIcon } from '@heroicons/vue/24/outline'
import { useRequestsStore } from '@/stores/requests'
import { useAuthStore } from '@/stores/auth'
import { useSecurity } from '@/composables/useSecurity'
import { LocationService } from '@/services/location'
import { CATEGORIES, DURATION_OPTIONS } from '@/constants/categories'
import LoadingSpinner from '@/components/common/LoadingSpinner.vue'
import ImageUpload from '@/components/common/ImageUpload.vue'
import type { Request, RequestCategory, DurationEstimate } from '@/types'

const route = useRoute()
const router = useRouter()
const requestsStore = useRequestsStore()
const authStore = useAuthStore()
const { checkPermission, validateInput } = useSecurity()

const request = ref<Request | null>(null)
const loading = ref(true)
const error = ref('')
const isSubmitting = ref(false)
const skillsInput = ref('')
const locationStatus = ref<'idle' | 'loading' | 'success' | 'error'>('idle')
const locationError = ref('')
const submitError = ref('')
const submitSuccess = ref(false)
const imageUploadRef = ref<InstanceType<typeof ImageUpload>>()
const uploadedImageUrls = ref<string[]>([])

// Form validation errors
const errors = reactive({
  title: '',
  description: '',
  category: '',
  subcategory: '',
  duration_estimate: '',
})

// Form data
const form = reactive({
  title: '',
  description: '',
  category: '' as RequestCategory | '',
  subcategory: '',
  duration_estimate: '' as DurationEstimate | '',
  skills_required: [] as string[],
  compensation: '',
  images: [] as string[],
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

const fetchRequest = async () => {
  const requestId = route.params.id as string
  loading.value = true
  error.value = ''
  
  try {
    // Check if user has permission to edit this request
    const permission = await checkPermission('update', 'request', requestId)
    if (!permission.valid) {
      error.value = permission.message || 'You do not have permission to edit this request'
      return
    }

    // Fetch the request
    const foundRequest = await requestsStore.getRequestById(requestId)
    
    if (!foundRequest) {
      error.value = 'Request not found'
      return
    }
    
    // Double-check ownership on the frontend
    if (foundRequest.user_id !== authStore.user?.id) {
      error.value = 'You can only edit your own requests'
      return
    }
    
    request.value = foundRequest
    
    // Populate form with existing data
    form.title = foundRequest.title
    form.description = foundRequest.description
    form.category = foundRequest.category as RequestCategory
    form.subcategory = foundRequest.subcategory
    form.duration_estimate = foundRequest.duration_estimate as DurationEstimate || ''
    form.skills_required = [...(foundRequest.skills_required || [])]
    form.compensation = foundRequest.compensation || ''
    form.images = [...(foundRequest.images || [])]
    form.location = foundRequest.location ? { ...foundRequest.location } : null
    
    // Set initial uploaded images
    uploadedImageUrls.value = [...(foundRequest.images || [])]
    
    if (form.location) {
      locationStatus.value = 'success'
    }
  } catch (err: any) {
    console.error('Error fetching request:', err)
    error.value = err.message || 'Failed to load request'
  } finally {
    loading.value = false
  }
}

const validateForm = () => {
  // Clear previous errors
  Object.keys(errors).forEach(key => {
    errors[key as keyof typeof errors] = ''
  })

  let isValid = true

  // Validate title
  const titleValidation = validateInput(form.title, 100)
  if (!titleValidation.valid) {
    errors.title = titleValidation.errors[0]
    isValid = false
  }

  // Validate description
  const descriptionValidation = validateInput(form.description, 2000)
  if (!descriptionValidation.valid) {
    errors.description = descriptionValidation.errors[0]
    isValid = false
  }

  // Validate category
  if (!form.category) {
    errors.category = 'Category is required'
    isValid = false
  }

  // Validate subcategory
  if (!form.subcategory) {
    errors.subcategory = 'Subcategory is required'
    isValid = false
  }

  // Validate duration for help-needed category
  if (isDurationRequired.value && !form.duration_estimate) {
    errors.duration_estimate = 'Duration estimate is required for help-needed requests'
    isValid = false
  }

  return isValid
}

const requestLocation = async () => {
  locationStatus.value = 'loading'
  locationError.value = ''
  
  try {
    const position = await LocationService.getCurrentPosition()
    const address = await LocationService.reverseGeocode(
      position.latitude,
      position.longitude
    )
    
    form.location = {
      latitude: position.latitude,
      longitude: position.longitude,
      address,
    }
    
    locationStatus.value = 'success'
  } catch (error: any) {
    locationStatus.value = 'error'
    locationError.value = error.message || 'Unable to get your location. Please ensure location services are enabled.'
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
  form.images = urls
}

const handleImageUploadError = (errors: string[]) => {
  console.error('Image upload errors:', errors)
  // Errors are already displayed in the ImageUpload component
}

const handleSubmit = async () => {
  if (!authStore.user || !request.value) {
    submitError.value = 'Not authenticated or request not found'
    return
  }

  if (!validateForm()) {
    submitError.value = 'Please fix the errors above'
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
  submitSuccess.value = false
  
  try {
    // Check permission again before submitting
    const permission = await checkPermission('update', 'request', request.value.id)
    if (!permission.valid) {
      throw new Error(permission.message || 'You do not have permission to update this request')
    }

    const updateData = {
      title: form.title.trim(),
      description: form.description.trim(),
      category: form.category as RequestCategory,
      subcategory: form.subcategory,
      // Only include duration_estimate if it's required and provided
      duration_estimate: isDurationRequired.value ? form.duration_estimate as DurationEstimate : undefined,
      skills_required: form.skills_required,
      compensation: form.compensation.trim() || undefined,
      images: uploadedImageUrls.value,
      location: form.location!,
    }
    
    const result = await requestsStore.updateRequest(request.value.id, updateData)
    
    if (result.error) {
      throw new Error(result.error)
    }
    
    submitSuccess.value = true
    
    // Redirect to request details after a short delay
    setTimeout(() => {
      router.push(`/requests/${request.value!.id}`)
    }, 1500)
  } catch (error: any) {
    submitError.value = error.message || 'Failed to update request'
    console.error('Error updating request:', error)
  } finally {
    isSubmitting.value = false
  }
}

onMounted(() => {
  fetchRequest()
})

// Clear subcategory when category changes
watch(() => form.category, () => {
  form.subcategory = ''
  // Clear duration when switching away from help-needed
  if (form.category !== 'help-needed') {
    form.duration_estimate = ''
  }
})
</script>