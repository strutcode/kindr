<template>
  <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow cursor-pointer">
    <div class="flex items-start justify-between mb-4">
      <div class="flex-1">
        <h3 class="text-lg font-semibold text-gray-900 mb-2">{{ request.title }}</h3>
        <p class="text-gray-600 text-sm mb-3 line-clamp-2">{{ request.description }}</p>
        
        <!-- Images Preview -->
        <div v-if="request.images && request.images.length > 0" class="mb-3">
          <div class="flex space-x-2 overflow-x-auto">
            <img
              v-for="(image, index) in request.images.slice(0, 3)"
              :key="index"
              :src="image"
              :alt="`Request image ${index + 1}`"
              class="w-16 h-16 object-cover rounded-md flex-shrink-0"
            />
            <div
              v-if="request.images.length > 3"
              class="w-16 h-16 bg-gray-100 rounded-md flex items-center justify-center flex-shrink-0"
            >
              <span class="text-xs text-gray-500 font-medium">
                +{{ request.images.length - 3 }}
              </span>
            </div>
          </div>
        </div>
        
        <div class="flex flex-wrap items-center gap-2 mb-3">
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800">
            {{ getCategoryLabel(request.category) }}
          </span>
          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
            {{ getSubcategoryLabel(request.category, request.subcategory) }}
          </span>
          <span v-if="request.duration_estimate" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-accent-100 text-accent-800">
            {{ getDurationLabel(request.duration_estimate) }}
          </span>
        </div>

        <div v-if="request.skills_required?.length" class="mb-3">
          <div class="flex flex-wrap gap-1">
            <span 
              v-for="skill in request.skills_required.slice(0, 3)" 
              :key="skill"
              class="inline-flex items-center px-2 py-1 rounded-md text-xs font-medium bg-secondary-100 text-secondary-800"
            >
              {{ skill }}
            </span>
            <span 
              v-if="request.skills_required.length > 3" 
              class="inline-flex items-center px-2 py-1 rounded-md text-xs font-medium bg-gray-100 text-gray-600"
            >
              +{{ request.skills_required.length - 3 }} more
            </span>
          </div>
        </div>

        <div class="flex items-center justify-between text-sm text-gray-500">
          <div class="flex items-center space-x-4">
            <div class="flex items-center space-x-1">
              <MapPinIcon class="w-4 h-4" />
              <span>{{ request.location.address || 'Location provided' }}</span>
            </div>
            <div class="flex items-center space-x-1">
              <ClockIcon class="w-4 h-4" />
              <span>{{ formatRelativeTime(request.created_at) }}</span>
            </div>
          </div>
          
          <div v-if="request.compensation" class="text-secondary-600 font-medium">
            {{ request.compensation }}
          </div>
        </div>
      </div>

      <div class="ml-4 flex-shrink-0">
        <div class="flex items-center space-x-2">
          <div class="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
            <UserIcon class="w-5 h-5 text-gray-600" />
          </div>
          <div class="text-sm">
            <p class="font-medium text-gray-900">{{ request.user?.full_name || 'Anonymous' }}</p>
            <!-- Hide email for anonymous users -->
            <p v-if="authStore.isAuthenticated" class="text-gray-500">{{ request.user?.email }}</p>
            <p v-else class="text-gray-500">Community Member</p>
          </div>
        </div>
      </div>
    </div>

    <div v-if="showActions" class="flex items-center justify-between pt-4 border-t border-gray-100">
      <div class="flex space-x-2">
        <router-link
          v-if="canEdit"
          :to="`/requests/${request.id}/edit`"
          @click.stop
          class="btn btn-outline btn-sm"
        >
          <PencilIcon class="w-4 h-4 mr-2" />
          Edit
        </router-link>
        <button
          v-if="canDelete"
          @click.stop="$emit('delete', request)"
          class="btn btn-outline btn-sm text-error-600 border-error-300 hover:bg-error-50"
        >
          <TrashIcon class="w-4 h-4 mr-2" />
          Delete
        </button>
      </div>
      
      <button
        v-if="canRespond"
        @click.stop="$emit('respond', request)"
        class="btn btn-primary btn-sm"
      >
        Respond
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { formatDistanceToNow } from 'date-fns'
import { MapPinIcon, ClockIcon, UserIcon, PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'
import { CATEGORIES, DURATION_OPTIONS } from '@/constants/categories'
import { useAuthStore } from '@/stores/auth'
import type { Request } from '@/types'

interface Props {
  request: Request
  showActions?: boolean
}

interface Emits {
  (e: 'edit', request: Request): void
  (e: 'delete', request: Request): void
  (e: 'respond', request: Request): void
}

const props = withDefaults(defineProps<Props>(), {
  showActions: true,
})

defineEmits<Emits>()

const authStore = useAuthStore()

const canEdit = computed(() => 
  authStore.isAuthenticated && authStore.user?.id === props.request.user_id
)

const canDelete = computed(() => 
  authStore.isAuthenticated && authStore.user?.id === props.request.user_id
)

const canRespond = computed(() => 
  authStore.user?.id !== props.request.user_id && props.request.status === 'active'
)

const getCategoryLabel = (category: string) => {
  return CATEGORIES.find(cat => cat.value === category)?.label || category
}

const getSubcategoryLabel = (category: string, subcategory: string) => {
  const cat = CATEGORIES.find(cat => cat.value === category)
  return cat?.subcategories.find(sub => sub.value === subcategory)?.label || subcategory
}

const getDurationLabel = (duration: string) => {
  return DURATION_OPTIONS.find(opt => opt.value === duration)?.label || duration
}

const formatRelativeTime = (dateString: string) => {
  return formatDistanceToNow(new Date(dateString), { addSuffix: true })
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>