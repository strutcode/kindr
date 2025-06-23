<template>
  <div class="listing-mini" @click="emit('click', listing)">
    <img v-if="listing.images?.length" :src="listing.images[0]" alt="Listing Image" />
    <h3>{{ listing.title }}</h3>
    <p>{{ listing.description }}</p>
    <p class="text-sm text-gray-500">{{ listing.category }}</p>
  </div>
</template>

<script lang="ts" setup>
  import { Listing } from '@/types'

  interface Props {
    listing: Listing
  }

  defineProps<Props>()

  const emit = defineEmits<{
    (e: 'click', listing: Listing): void
  }>()
</script>

<style scoped>
  .listing-mini {
    @apply p-4 bg-white rounded-lg shadow hover:shadow-lg transition-shadow;
    @apply hover:cursor-pointer;
  }

  .listing-mini h3 {
    @apply text-lg font-semibold text-gray-900;
  }

  .listing-mini p {
    @apply text-sm text-gray-600;
  }

  .listing-mini img {
    @apply w-full h-32 object-cover rounded-md mb-2;
  }
</style>
