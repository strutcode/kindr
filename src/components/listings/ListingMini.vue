<template>
  <div class="listing-mini" @click="emit('click', listing)">
    <img v-if="listing.images?.length" :src="listing.images[0]" alt="Listing Image" />
    <div class="flex items-center mb-2">
      <div class="mr-4">
        <div v-if="index != null" class="index" :style="{ background: categoryColor }">
          {{ index }}
        </div>
      </div>
      <div class="grow">
        <div class="flex-col">
          <h3>{{ listing.title }}</h3>
          <div class="text-xs text-gray-600">{{ categoryText }}</div>
        </div>
      </div>
    </div>
    <div>
      <p>{{ listing.description }}</p>
      <ListingPills :listing="listing" class="mt-2" />
    </div>
  </div>
</template>

<script lang="ts" setup>
  import { computed } from 'vue'
  import { CATEGORIES } from '@/constants'
  import { Listing } from '@/types'

  import ListingPills from './ListingPills.vue'

  interface Props {
    index?: number
    listing: Listing
  }

  const props = defineProps<Props>()

  const emit = defineEmits<{
    (e: 'click', listing: Listing): void
  }>()

  const categoryText = computed(() => {
    return CATEGORIES.find(cat => cat.value === props.listing.category)?.label ?? 'Unknown'
  })

  const categoryColor = computed(() => {
    return CATEGORIES.find(cat => cat.value === props.listing.category)?.color
  })
</script>

<style scoped>
  .listing-mini {
    @apply bg-white p-4;
    @apply hover:cursor-pointer hover:bg-gray-100;
  }

  .listing-mini .index {
    @apply bg-gray-300 text-white font-bold;
    @apply rounded-full w-8 h-8 mb-2;
    @apply flex items-center justify-center;
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
