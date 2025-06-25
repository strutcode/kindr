<template>
  <div class="listing-pills">
    <p class="pill" :class="listing.subcategory">{{ subcategoryText }}</p>
    <p class="pill" v-for="skill in listing.skills_required">{{ skill }}</p>
    <p v-if="listing.duration_estimate" class="pill" :class="listing.duration_estimate">
      {{ durationText }}
    </p>
  </div>
</template>

<script lang="ts" setup>
  import { computed } from 'vue'
  import { Listing } from '@/types'
  import { CATEGORIES, DURATION_OPTIONS } from '@/constants'

  const props = defineProps<{
    listing: Listing
  }>()

  const subcategoryText = computed(() => {
    if (props.listing.subcategory) {
      return CATEGORIES.find(cat => cat.value === props.listing.category)?.subcategories?.find(
        sub => sub.value === props.listing.subcategory,
      )?.label
    }
    return ''
  })

  const durationText = computed(() => {
    if (props.listing.category === 'help-needed') {
      return DURATION_OPTIONS.find(opt => opt.value === props.listing.duration_estimate)?.label
    }

    return ''
  })
</script>

<style scoped>
  .listing-pills {
    @apply flex flex-wrap gap-2;
    @apply text-sm;
  }

  .pill {
    @apply inline-block px-2 py-1 text-xs font-medium rounded-full;
    @apply text-white bg-gray-400;
  }

  .pill.help-needed {
    @apply bg-blue-500;
  }

  .pill.offer-help {
    @apply bg-green-500;
  }

  .pill.request-help {
    @apply bg-yellow-500;
  }

  .pill.other {
    @apply bg-gray-500;
  }
</style>
