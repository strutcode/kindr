<template>
  <form @submit.prevent="onSubmit" class="space-y-8">
    <!-- Basic Information -->
    <div class="space-y-6">
      <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
        Basic Information
      </h2>
      <Text
        id="title"
        v-model="form.title"
        label="Title"
        required
        placeholder="Brief description of your request"
      />
      <TextBox
        id="description"
        v-model="form.description"
        label="Description"
        required
        placeholder="Provide detailed information about what you need or offer"
      />
    </div>

    <!-- Category and Details -->
    <div class="space-y-6">
      <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
        Category & Details
      </h2>
      <div class="grid md:grid-cols-2 gap-6">
        <Dropdown
          id="category"
          v-model="form.category"
          :options="CATEGORIES"
          label="Category"
          required
          placeholder="Select a category"
          @change="handleCategoryChange"
        />
        <Dropdown
          v-if="form.category"
          id="subcategory"
          v-model="form.subcategory"
          :options="selectedCategorySubcategories"
          label="Subcategory"
          required
          placeholder="Select a subcategory"
        />
        <Dropdown
          v-if="showDurationField"
          id="duration"
          v-model="form.duration_estimate"
          :options="DURATION_OPTIONS"
          label="Estimated Duration"
          helper="How long do you estimate this task will take?"
          :required="isDurationRequired"
          placeholder="Select duration"
        />
      </div>
      <div>
        <Tags
          id="tags"
          v-model="form.skills_required"
          label="Skills Required (Optional)"
          placeholder="e.g., driving, heavy lifting, computer skills (press Enter to add)"
        />
      </div>
      <Text
        id="compensation"
        v-model="form.compensation"
        label="Compensation (Optional)"
        placeholder="e.g., $20, Coffee & snacks, Gas money"
      />
    </div>

    <!-- Images -->
    <div class="space-y-6">
      <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
        Images (Optional)
      </h2>
      <div>
        <p class="text-sm text-gray-600 mb-4">
          Add images to help others understand your request better. You can upload up to 8 images.
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
      <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">Location</h2>
      <div v-if="locationStatus === 'loading'" class="p-4 bg-gray-50 rounded-md">
        <LoadingSpinner text="Getting your location..." />
      </div>
      <div v-else-if="locationStatus === 'error'" class="mb-4">
        <StatusBanner type="error">
          <div class="flex items-center">
            <ExclamationTriangleIcon class="w-5 h-5 text-error-600 mr-3 flex-shrink-0" />
            <div>
              <p class="text-sm text-error-700 mb-2">{{ locationError }}</p>
              <Button variant="outline" size="sm" type="button" @click="requestLocation">
                Try Again
              </Button>
            </div>
          </div>
        </StatusBanner>
      </div>
      <div v-else-if="form.location" class="p-4 bg-success-50 rounded-md">
        <p class="text-sm text-success-700">✓ Location set: {{ form.location.address }}</p>
      </div>
    </div>

    <!-- Expiry Period -->
    <div class="space-y-6">
      <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
        Auto-Expire After
      </h2>
      <Dropdown
        id="expiry_seconds"
        v-model="form.expiry_seconds"
        :options="EXPIRY_OPTIONS"
        label="Auto-Expire After"
        required
        placeholder="Select expiry period"
        helper="Your request will be automatically marked inactive after this period."
      />
    </div>

    <!-- Submit -->
    <div class="flex items-center justify-between pt-6 border-t border-gray-200">
      <slot name="cancel"></slot>
      <Button
        type="submit"
        :disabled="isSubmitting || !isFormValid || isUploadingImages"
        :loading="isSubmitting"
        variant="primary"
      >
        <template v-if="isUploadingImages">Uploading Images...</template>
        <template v-else>{{ submitLabel }}</template>
      </Button>
    </div>
  </form>
</template>

<script setup lang="ts">
  import { ref, computed, reactive, watch, onMounted } from 'vue'
  import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
  import { CATEGORIES, DURATION_OPTIONS } from '@/constants/categories'
  // Add expiry options
  const EXPIRY_OPTIONS = [
    { label: '1 hour', value: 3600 },
    { label: '2 hours', value: 7200 },
    { label: '4 hours', value: 14400 },
    { label: '8 hours', value: 28800 },
    { label: '12 hours', value: 43200 },
    { label: '1 day', value: 86400 },
    { label: '2 days', value: 172800 },
    { label: '3 days', value: 259200 },
    { label: '5 days', value: 432000 },
    { label: '7 days', value: 604800 },
    { label: '2 weeks', value: 1209600 },
    { label: '3 weeks', value: 1814400 },
    { label: '4 weeks', value: 2419200 },
  ]
  import LoadingSpinner from '@/components/common/LoadingSpinner.vue'
  import ImageUpload from '@/components/common/ImageUpload.vue'
  import StatusBanner from '@/components/common/StatusBanner.vue'
  import Button from '@/components/widgets/Button.vue'
  import Dropdown from '@/components/widgets/Dropdown.vue'
  import Text from '@/components/widgets/Text.vue'
  import TextBox from '@/components/widgets/TextBox.vue'
  import Tags from '@/components/widgets/Tags.vue'
  import { LocationService } from '@/services/location'
  import type { RequestCategory, DurationEstimate } from '@/types'

  const props = defineProps({
    initialValues: {
      type: Object,
      default: () => ({}),
    },
    isSubmitting: Boolean,
    submitLabel: {
      type: String,
      default: 'Submit',
    },
  })
  const emit = defineEmits(['submit'])

  const form = reactive({
    title: props.initialValues.title || '',
    description: props.initialValues.description || '',
    category: props.initialValues.category || '',
    subcategory: props.initialValues.subcategory || '',
    duration_estimate: props.initialValues.duration_estimate || '',
    skills_required: props.initialValues.skills_required
      ? [...props.initialValues.skills_required]
      : [],
    compensation: props.initialValues.compensation || '',
    images: props.initialValues.images ? [...props.initialValues.images] : [],
    location: props.initialValues.location ? { ...props.initialValues.location } : null,
    expiry_seconds: props.initialValues.expiry_seconds || 86400, // default 1 day
  })

  const locationStatus = ref<'idle' | 'loading' | 'success' | 'error'>('idle')
  const locationError = ref('')
  const imageUploadRef = ref<InstanceType<typeof ImageUpload>>()
  const uploadedImageUrls = ref<string[]>([...form.images])

  const selectedCategorySubcategories = computed(() => {
    if (!form.category) return []
    return CATEGORIES.find(cat => cat.value === form.category)?.subcategories || []
  })
  const showDurationField = computed(() => form.category === 'help-needed')
  const isDurationRequired = computed(() => form.category === 'help-needed')
  const isUploadingImages = computed(() => imageUploadRef.value?.isUploading() || false)
  const isFormValid = computed(() => {
    const baseValidation = !!(
      form.title &&
      form.description &&
      form.category &&
      form.subcategory &&
      form.location &&
      !isUploadingImages.value
    )
    if (isDurationRequired.value) {
      return baseValidation && !!form.duration_estimate
    }
    return baseValidation && form.expiry_seconds > 0
  })

  const handleCategoryChange = () => {
    form.subcategory = ''
    if (form.category !== 'help-needed') {
      form.duration_estimate = ''
    }
  }
  const handleImagesChanged = (urls: string[]) => {
    uploadedImageUrls.value = urls
    form.images = urls
  }
  const handleImageUploadError = (errors: string[]) => {
    // Errors are already displayed in the ImageUpload component
    // Optionally emit or handle here
  }
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
    }
  }
  const onSubmit = () => {
    if (!isFormValid.value) return
    emit('submit', {
      ...form,
      images: uploadedImageUrls.value,
      expiry_seconds: form.expiry_seconds,
    })
  }
  onMounted(() => {
    if (!form.location) requestLocation()
  })
  watch(
    () => form.category,
    () => {
      form.subcategory = ''
      if (form.category !== 'help-needed') {
        form.duration_estimate = ''
      }
    },
  )
</script>
