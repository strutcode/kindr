<template>
  <div
    class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow cursor-pointer"
  >
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
          <span
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800"
          >
            {{ getCategoryLabel(request.category) }}
          </span>
          <span
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
          >
            {{ getSubcategoryLabel(request.category, request.subcategory) }}
          </span>
          <span
            v-if="request.duration_estimate"
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-accent-100 text-accent-800"
          >
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
        <UserInfo :user="request.user" :show-email="authStore.isAuthenticated" />
      </div>
    </div>
    <div v-if="showActions" class="flex items-center justify-between pt-4 border-t border-gray-100">
      <RequestActions
        :request="request"
        :can-edit="canEdit"
        :can-delete="canDelete"
        :can-respond="canRespond"
        @delete="$emit('delete', request)"
        @respond="$emit('respond', request)"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed } from 'vue'
  import { MapPinIcon, ClockIcon } from '@heroicons/vue/24/outline'
  import { useAuthStore } from '@/stores/auth'
  import type { Request } from '@/types'
  import UserInfo from '@/components/common/UserInfo.vue'
  import RequestActions from '@/components/common/RequestActions.vue'
  import { useRequestFormatting } from '@/composables/useRequestFormatting'

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

  const canEdit = computed(
    () => authStore.isAuthenticated && authStore.user?.id === props.request.user_id,
  )

  const canDelete = computed(
    () => authStore.isAuthenticated && authStore.user?.id === props.request.user_id,
  )

  const canRespond = computed(
    () => authStore.user?.id !== props.request.user_id && props.request.status === 'active',
  )

  const { getCategoryLabel, getSubcategoryLabel, getDurationLabel, formatRelativeTime } =
    useRequestFormatting()
</script>

<style scoped>
  .line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
</style>
