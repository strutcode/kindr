<template>
  <div class="listing-create-view">
    <div class="mb-8">
      <h1 class="text-2xl font-bold text-gray-900 mb-2">Create New Request</h1>
      <p class="text-gray-600">Share what you need or offer help to your community</p>
    </div>

    <ListingCreateUpdateForm @submit="submitForm" />
  </div>
</template>

<script lang="ts" setup>
  import { useRouter } from 'vue-router'

  import { useListingsStore } from '@/stores/listings'
  import { Listing } from '@/types'

  import ListingCreateUpdateForm from '@/components/listings/ListingCreateUpdateForm.vue'

  const router = useRouter()
  const listingsStore = useListingsStore()

  const submitForm = async (form: Partial<Listing>) => {
    try {
      // Validate form data
      if (!form.title || !form.description) {
        throw new Error('Title and description are required')
      }

      // Create the listing
      const listing = await listingsStore.createListing(form)

      // Redirect to the newly created listing
      if (listing) {
        // Assuming you have a router instance available
        router.push({ name: 'show', params: { id: listing.id } })
      }
    } catch (error) {
      console.error('Error creating listing:', error)
      // Handle error (e.g., show notification)
    }
  }
</script>

<style scoped>
  .listing-create-view {
    @apply max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8;
  }
</style>
