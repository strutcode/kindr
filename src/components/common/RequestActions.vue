<template>
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
    <button
      v-if="canRespond"
      @click.stop="$emit('respond', request)"
      class="btn btn-primary btn-sm"
    >
      Respond
    </button>
  </div>
</template>
<script setup lang="ts">
  import { PencilIcon, TrashIcon } from '@heroicons/vue/24/outline'
  import type { Request } from '@/types'

  interface Props {
    request: Request
    canEdit?: boolean
    canDelete?: boolean
    canRespond?: boolean
  }

  defineProps<Props>()
  defineEmits(['delete', 'respond'])
</script>
