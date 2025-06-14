<template>
  <div class="image-upload">
    <!-- Upload Area -->
    <div
      ref="dropZone"
      class="upload-zone"
      :class="{
        'border-primary-500 bg-primary-50': isDragOver,
        'border-error-300 bg-error-50': hasError,
        'border-gray-300': !isDragOver && !hasError
      }"
      @click="triggerFileInput"
      @dragover.prevent="handleDragOver"
      @dragleave.prevent="handleDragLeave"
      @drop.prevent="handleDrop"
    >
      <input
        ref="fileInput"
        type="file"
        multiple
        accept="image/jpeg,image/jpg,image/png,image/gif"
        class="hidden"
        @change="handleFileSelect"
      />

      <div class="text-center py-8">
        <div class="w-12 h-12 mx-auto mb-4 text-gray-400">
          <PhotoIcon v-if="!isDragOver" class="w-full h-full" />
          <CloudArrowUpIcon v-else class="w-full h-full text-primary-500" />
        </div>
        
        <div class="text-sm text-gray-600 mb-2">
          <span v-if="isDragOver" class="font-medium text-primary-600">
            Drop images here
          </span>
          <span v-else>
            <button type="button" class="font-medium text-primary-600 hover:text-primary-500">
              Click to upload
            </button>
            or drag and drop
          </span>
        </div>
        
        <p class="text-xs text-gray-500">
          PNG, JPG, GIF up to 2MB each (max {{ maxImages }} images)
        </p>
      </div>
    </div>

    <!-- Error Messages -->
    <div v-if="errors.length > 0" class="mt-4 space-y-2">
      <div
        v-for="(error, index) in errors"
        :key="index"
        class="flex items-start p-3 bg-error-50 border border-error-200 rounded-md"
      >
        <ExclamationTriangleIcon class="w-5 h-5 text-error-600 mt-0.5 mr-3 flex-shrink-0" />
        <p class="text-sm text-error-700">{{ error }}</p>
      </div>
    </div>

    <!-- Image Previews -->
    <div v-if="images.length > 0" class="mt-6">
      <div class="flex items-center justify-between mb-4">
        <h4 class="text-sm font-medium text-gray-900">
          Images ({{ images.length }}/{{ maxImages }})
        </h4>
        <button
          v-if="images.length > 0"
          type="button"
          @click="clearAllImages"
          class="text-sm text-error-600 hover:text-error-500"
        >
          Remove All
        </button>
      </div>

      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        <div
          v-for="image in images"
          :key="image.id"
          class="relative group aspect-square bg-gray-100 rounded-lg overflow-hidden"
        >
          <!-- Image Preview -->
          <img
            :src="image.preview"
            :alt="`Preview ${image.id}`"
            class="w-full h-full object-cover"
          />

          <!-- Upload Progress Overlay -->
          <div
            v-if="image.uploading"
            class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center"
          >
            <div class="text-center">
              <div class="w-8 h-8 border-2 border-white border-t-transparent rounded-full animate-spin mx-auto mb-2" />
              <p class="text-xs text-white">Uploading...</p>
            </div>
          </div>

          <!-- Success Indicator -->
          <div
            v-else-if="image.uploaded"
            class="absolute top-2 left-2 w-6 h-6 bg-success-500 rounded-full flex items-center justify-center"
          >
            <CheckIcon class="w-4 h-4 text-white" />
          </div>

          <!-- Error Indicator -->
          <div
            v-else-if="image.error"
            class="absolute inset-0 bg-error-500 bg-opacity-75 flex items-center justify-center"
          >
            <div class="text-center">
              <ExclamationTriangleIcon class="w-6 h-6 text-white mx-auto mb-1" />
              <p class="text-xs text-white">Failed</p>
            </div>
          </div>

          <!-- Remove Button -->
          <button
            type="button"
            @click="removeImage(image.id)"
            class="absolute top-2 right-2 w-6 h-6 bg-error-500 hover:bg-error-600 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <XMarkIcon class="w-4 h-4 text-white" />
          </button>

          <!-- Retry Button for Failed Uploads -->
          <button
            v-if="image.error"
            type="button"
            @click="retryUpload(image.id)"
            class="absolute bottom-2 left-2 right-2 bg-white hover:bg-gray-50 text-gray-900 text-xs py-1 px-2 rounded border"
          >
            Retry
          </button>
        </div>
      </div>
    </div>

    <!-- Upload Summary -->
    <div v-if="uploadStats.total > 0" class="mt-4 p-3 bg-gray-50 rounded-md">
      <div class="flex items-center justify-between text-sm">
        <span class="text-gray-600">
          {{ uploadStats.completed }} of {{ uploadStats.total }} uploaded
        </span>
        <span v-if="uploadStats.failed > 0" class="text-error-600">
          {{ uploadStats.failed }} failed
        </span>
      </div>
      
      <!-- Overall Progress Bar -->
      <div v-if="uploadStats.inProgress > 0" class="mt-2">
        <div class="w-full bg-gray-200 rounded-full h-2">
          <div
            class="bg-primary-600 h-2 rounded-full transition-all duration-300"
            :style="{ width: `${uploadStats.progressPercentage}%` }"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onUnmounted, nextTick } from 'vue'
import {
  PhotoIcon,
  CloudArrowUpIcon,
  ExclamationTriangleIcon,
  XMarkIcon,
  CheckIcon,
} from '@heroicons/vue/24/outline'
import { ImageUploadService, type ImageFile } from '@/services/imageUpload'
import { useAuthStore } from '@/stores/auth'

interface Props {
  /** Maximum number of images allowed */
  maxImages?: number
  /** Existing image URLs to display */
  existingImages?: string[]
  /** Whether the component is disabled */
  disabled?: boolean
}

interface Emits {
  /** Emitted when images are successfully uploaded */
  (e: 'upload-complete', urls: string[]): void
  /** Emitted when images are removed */
  (e: 'images-changed', urls: string[]): void
  /** Emitted when upload errors occur */
  (e: 'upload-error', errors: string[]): void
}

const props = withDefaults(defineProps<Props>(), {
  maxImages: 8,
  existingImages: () => [],
  disabled: false,
})

const emit = defineEmits<Emits>()

const authStore = useAuthStore()

// Refs
const dropZone = ref<HTMLElement>()
const fileInput = ref<HTMLInputElement>()
const images = ref<ImageFile[]>([])
const errors = ref<string[]>([])
const isDragOver = ref(false)

// Computed
const hasError = computed(() => errors.value.length > 0)

const uploadStats = computed(() => {
  const total = images.value.length
  const completed = images.value.filter(img => img.uploaded).length
  const failed = images.value.filter(img => img.error).length
  const inProgress = images.value.filter(img => img.uploading).length
  const progressPercentage = total > 0 ? (completed / total) * 100 : 0

  return {
    total,
    completed,
    failed,
    inProgress,
    progressPercentage,
  }
})

const allImageUrls = computed(() => {
  const uploadedUrls = images.value
    .filter(img => img.uploaded && img.url)
    .map(img => img.url!)
  
  return [...props.existingImages, ...uploadedUrls]
})

// Methods
const triggerFileInput = () => {
  if (props.disabled) return
  fileInput.value?.click()
}

const handleDragOver = (e: DragEvent) => {
  if (props.disabled) return
  e.preventDefault()
  isDragOver.value = true
}

const handleDragLeave = (e: DragEvent) => {
  if (props.disabled) return
  e.preventDefault()
  isDragOver.value = false
}

const handleDrop = (e: DragEvent) => {
  if (props.disabled) return
  e.preventDefault()
  isDragOver.value = false
  
  const files = e.dataTransfer?.files
  if (files) {
    processFiles(files)
  }
}

const handleFileSelect = (e: Event) => {
  if (props.disabled) return
  const target = e.target as HTMLInputElement
  const files = target.files
  if (files) {
    processFiles(files)
    // Clear the input so the same file can be selected again
    target.value = ''
  }
}

const processFiles = async (files: FileList) => {
  errors.value = []

  // Validate image count
  const countError = ImageUploadService.validateImageCount(
    allImageUrls.value.length,
    files.length
  )
  if (countError) {
    errors.value.push(countError)
    return
  }

  // Validate files
  const { valid, errors: validationErrors } = ImageUploadService.validateFiles(files)
  if (validationErrors.length > 0) {
    errors.value.push(...validationErrors)
  }

  if (valid.length === 0) return

  // Create image objects with unique IDs
  const newImages: ImageFile[] = valid.map((file, index) => ({
    id: `${Date.now()}_${index}_${Math.random().toString(36).substring(2, 8)}`,
    file,
    preview: ImageUploadService.createPreviewUrl(file),
    uploading: false,
    uploaded: false,
  }))

  images.value.push(...newImages)

  // Start uploads
  await uploadImages(images)
}

const uploadImages = async (imagesToUpload: Ref<ImageFile[]>) => {
  if (!authStore.user?.id) {
    errors.value.push('User not authenticated')
    return
  }

  console.log(`Starting upload process for ${imagesToUpload.length} images`)

  for (const imageFile of imagesToUpload.value) {
    if (imageFile.uploaded) {
      continue
    }
    
    try {
      console.log(`Starting upload for image: ${imageFile.file.name}`)
      
      // Set uploading state
      imageFile.uploading = true
      imageFile.error = undefined
      
      // Upload the image
      const result = await ImageUploadService.uploadImage(
        imageFile.file,
        authStore.user.id
      )

      console.log(`Upload completed for image: ${imageFile.file.name}`, result)

      // Update image state on success
      imageFile.uploading = false
      imageFile.uploaded = true
      imageFile.url = result.url
      imageFile.error = undefined

      // Emit events
      emit('images-changed', allImageUrls.value)
      emit('upload-complete', allImageUrls.value)

    } catch (error) {
      console.error(`Upload failed for image: ${imageFile.file.name}`, error)
      
      // Update image state on error
      imageFile.uploading = false
      imageFile.uploaded = false
      imageFile.error = error instanceof Error ? error.message : 'Upload failed'

      emit('upload-error', [imageFile.error])
    }
  }

  console.log('Upload process completed')
}

const removeImage = (imageId: string) => {
  const imageIndex = images.value.findIndex(img => img.id === imageId)
  if (imageIndex === -1) return

  const image = images.value[imageIndex]
  
  // Revoke preview URL to free memory
  ImageUploadService.revokePreviewUrl(image.preview)
  
  // Remove from array
  images.value.splice(imageIndex, 1)
  
  // Emit updated URLs
  emit('images-changed', allImageUrls.value)
}

const clearAllImages = () => {
  // Revoke all preview URLs
  images.value.forEach(image => {
    ImageUploadService.revokePreviewUrl(image.preview)
  })
  
  images.value = []
  errors.value = []
  
  emit('images-changed', allImageUrls.value)
}

const retryUpload = async (imageId: string) => {
  const image = images.value.find(img => img.id === imageId)
  if (!image) return

  image.error = undefined
  await uploadImages([image])
}

// Cleanup on unmount
onUnmounted(() => {
  images.value.forEach(image => {
    ImageUploadService.revokePreviewUrl(image.preview)
  })
})

// Expose methods for parent components
defineExpose({
  clearAllImages,
  getUploadedUrls: () => allImageUrls.value,
  hasUploads: () => images.value.some(img => img.uploaded),
  isUploading: () => images.value.some(img => img.uploading),
})
</script>

<style scoped>
.upload-zone {
  @apply border-2 border-dashed rounded-lg cursor-pointer transition-colors duration-200;
}

.upload-zone:hover {
  @apply border-primary-400 bg-primary-50;
}

.upload-zone.disabled {
  @apply cursor-not-allowed opacity-50;
}

.aspect-square {
  aspect-ratio: 1 / 1;
}

/* Animation for upload progress */
@keyframes upload-pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.uploading {
  animation: upload-pulse 2s infinite;
}
</style>