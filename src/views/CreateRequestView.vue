<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <StatusBanner v-if="submitError" type="error">
      <div class="flex items-center">
        <ExclamationTriangleIcon class="w-5 h-5 text-error-600 mr-3 flex-shrink-0" />
        <div class="text-sm text-error-700">
          {{ submitError }}
        </div>
      </div>
    </StatusBanner>

    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900 mb-2">Create New Request</h1>
        <p class="text-gray-600">Share what you need or offer help to your community</p>
      </div>

      <RequestCreateUpdateForm
        :is-submitting="isSubmitting"
        submit-label="Create Request"
        @submit="handleFormSubmit"
      >
        <template #cancel>
          <router-link to="/requests">
            <Button variant="outline" type="button">Cancel</Button>
          </router-link>
        </template>
      </RequestCreateUpdateForm>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { ExclamationTriangleIcon } from '@heroicons/vue/24/outline'
  import { useRequestsStore } from '@/stores/requests'
  import { useAuthStore } from '@/stores/auth'
  import StatusBanner from '@/components/common/StatusBanner.vue'
  import Button from '@/components/widgets/Button.vue'
  import RequestCreateUpdateForm from '@/components/requests/RequestCreateUpdateForm.vue'

  const router = useRouter()
  const requestsStore = useRequestsStore()
  const authStore = useAuthStore()

  const isSubmitting = ref(false)
  const submitError = ref('')

  const handleFormSubmit = async (formData: any) => {
    if (!authStore.user) {
      submitError.value = 'Not authenticated'
      return
    }
    isSubmitting.value = true
    submitError.value = ''
    try {
      const requestData = {
        user_id: authStore.user.id,
        ...formData,
        status: 'active',
      }
      const result = await requestsStore.createRequest(requestData)
      if (result.error) {
        throw new Error(result.error)
      }
      router.push('/requests')
    } catch (error: any) {
      submitError.value = error.message || 'Failed to create request'
      console.error('Error creating request:', error)
    } finally {
      isSubmitting.value = false
    }
  }
</script>
