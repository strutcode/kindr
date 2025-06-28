<template>
  <form @submit.prevent="$emit('submit', form)" class="space-y-8">
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
        />
        <Dropdown
          v-if="form.category"
          id="subcategory"
          v-model="form.subcategory"
          :options="activeSubcategories"
          label="Subcategory"
          required
          placeholder="Select a subcategory"
        />
        <Dropdown
          v-if="isDurationType"
          id="duration"
          v-model="form.duration_estimate"
          :options="DURATION_OPTIONS"
          label="Estimated Duration"
          helper="How long do you estimate this task will take?"
          :required="isDurationType"
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

    <!-- Location -->
    <div class="space-y-6">
      <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">Location</h2>
      <LocationSelector v-model="form.location" label="Location" :required="true" />
    </div>

    <!-- Images -->
    <div class="space-y-6">
      <h2 class="text-lg font-semibold text-gray-900 border-b border-gray-200 pb-2">
        Images (Optional)
      </h2>
      <div>
        <p class="text-sm text-gray-600 mb-4">
          Add images to help others understand your request better.
        </p>
        <ImageUpload
          ref="imageUploadRef"
          :max-images="8"
          :existing-images="form.images"
          @images-changed="handleImagesChanged"
        />
        <p class="text-xs text-gray-500 mt-2">
          You can upload up to 8 images. Supported formats: JPG, PNG, GIF. No larger than 2MB after
          compression.
        </p>
      </div>
    </div>

    <Button type="submit">Create Listing</Button>
  </form>
</template>

<script lang="ts" setup>
  import { computed, reactive, watch } from 'vue'

  import { CATEGORIES, DURATION_OPTIONS } from '@/constants'

  import Button from '@/components/widgets/Button.vue'
  import Text from '@/components/widgets/Text.vue'
  import TextBox from '@/components/widgets/TextBox.vue'
  import { Location, RequestCategory } from '@/types'
  import Dropdown from '../widgets/Dropdown.vue'
  import Tags from '../widgets/Tags.vue'
  import ImageUpload from '../common/ImageUpload.vue'
  import LocationSelector from '../widgets/LocationSelector.vue'

  interface ListingForm {
    title: string
    description: string
    category: RequestCategory | ''
    subcategory: string
    duration_estimate: string
    compensation: string
    skills_required: string[]
    images: string[]
    location: Location | null
  }

  defineEmits<{
    (e: 'submit', form: ListingForm): void
  }>()

  const form = reactive<ListingForm>({
    title: '',
    description: '',
    category: '',
    subcategory: '',
    compensation: '',
    duration_estimate: '',
    skills_required: [],
    images: [],
    location: null,
  })

  const activeSubcategories = computed(() => {
    if (!form.category) return []

    // Find the category object based on the selected category value
    const category = CATEGORIES.find(c => c.value === form.category)

    // Safely return the subcategories if they exist
    return category?.subcategories ?? []
  })

  const isDurationType = computed(() => {
    return form.category === 'help-needed'
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

  const handleImagesChanged = (urls: string[]) => {
    form.images = urls
  }
</script>
