<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <StatusBanner v-if="error" type="error">
      <div class="flex items-center">
        <ExclamationTriangleIcon class="w-5 h-5 text-error-600 mr-3 flex-shrink-0" />
        <div>
          <h3 class="text-lg font-medium text-gray-900 mb-2">Unable to load request</h3>
          <p class="text-gray-600 mb-6">{{ error }}</p>
          <div class="flex justify-center space-x-3">
            <router-link to="/requests" class="btn btn-outline"> Back to Requests </router-link>
            <button @click="fetchRequest" class="btn btn-primary">Try Again</button>
          </div>
        </div>
      </div>
    </StatusBanner>

    <div v-if="loading" class="text-center py-12">
      <LoadingSpinner size="lg" text="Loading request..." />
    </div>

    <div v-else-if="request" class="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
      <div class="mb-8">
        <h1 class="text-2xl font-bold text-gray-900 mb-2">Edit Request</h1>
        <p class="text-gray-600">Update your community request details</p>
      </div>

      <RequestCreateUpdateForm
        v-if="request"
        :initial-values="request"
        :is-submitting="isSubmitting"
        submit-label="Update Request"
        @submit="handleFormSubmit"
      >
        <template #cancel>
          <router-link :to="`/requests/${request.id}`">
            <Button variant="outline" type="button">Cancel</Button>
          </router-link>
        </template>
      </RequestCreateUpdateForm>

      <div v-if="submitError" class="rounded-md bg-error-50 p-4 mt-6">
        <div class="flex">
          <ExclamationTriangleIcon class="w-5 h-5 text-error-400 mr-3 flex-shrink-0" />
          <div class="text-sm text-error-700">
            {{ submitError }}
          </div>
        </div>
      </div>
      <div v-if="submitSuccess" class="rounded-md bg-success-50 p-4 mt-6">
        <div class="flex">
          <CheckCircleIcon class="w-5 h-5 text-success-400 mr-3 flex-shrink-0" />
          <div class="text-sm text-success-700">Request updated successfully!</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ExclamationTriangleIcon, CheckCircleIcon } from '@heroicons/vue/24/outline'
  import { useRequestsStore } from '@/stores/requests'
  import { useAuthStore } from '@/stores/auth'
  import { useSecurity } from '@/composables/useSecurity'
  import LoadingSpinner from '@/components/common/LoadingSpinner.vue'
  import StatusBanner from '@/components/common/StatusBanner.vue'
  import Button from '@/components/widgets/Button.vue'
  import RequestCreateUpdateForm from '@/components/requests/RequestCreateUpdateForm.vue'

  const route = useRoute()
  const router = useRouter()
  const requestsStore = useRequestsStore()
  const authStore = useAuthStore()
  const { checkPermission } = useSecurity()

  const request = ref(null)
  const loading = ref(true)
  const error = ref('')
  const isSubmitting = ref(false)
  const submitError = ref('')
  const submitSuccess = ref(false)

  const fetchRequest = async () => {
    const requestId = route.params.id as string
    loading.value = true
    error.value = ''
    try {
      const permission = await checkPermission('update', 'request', requestId)
      if (!permission.valid) {
        error.value = permission.message || 'You do not have permission to edit this request'
        return
      }
      const foundRequest = await requestsStore.getRequestById(requestId)
      if (!foundRequest) {
        error.value = 'Request not found'
        return
      }
      if (foundRequest.user_id !== authStore.user?.id) {
        error.value = 'You can only edit your own requests'
        return
      }
      request.value = foundRequest
    } catch (err: any) {
      error.value = err.message || 'Failed to load request'
    } finally {
      loading.value = false
    }
  }

  const handleFormSubmit = async (formData: any) => {
    if (!authStore.user || !request.value) {
      submitError.value = 'Not authenticated or request not found'
      return
    }
    isSubmitting.value = true
    submitError.value = ''
    submitSuccess.value = false
    try {
      const permission = await checkPermission('update', 'request', request.value.id)
      if (!permission.valid) {
        throw new Error(permission.message || 'You do not have permission to update this request')
      }
      const updateData = {
        ...formData,
      }
      const result = await requestsStore.updateRequest(request.value.id, updateData)
      if (result.error) {
        throw new Error(result.error)
      }
      submitSuccess.value = true
      setTimeout(() => {
        router.push(`/requests/${request.value.id}`)
      }, 1500)
    } catch (error: any) {
      submitError.value = error.message || 'Failed to update request'
      console.error('Error updating request:', error)
    } finally {
      isSubmitting.value = false
    }
  }

  onMounted(() => {
    fetchRequest()
  })
</script>
