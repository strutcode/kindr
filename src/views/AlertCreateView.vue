<template>
  <div>
    <div class="form-section">
      <div class="form-header">
        <Button variant="ghost" :link="{ name: 'alerts' }" class="hover:bg-gray-100 mr-3">
          <Icon icon="tabler:chevron-left" class="w-6 h-6 text-gray-500" />
        </Button>
        <h2 class="form-title grow">Create New Alert</h2>
      </div>
      <AlertForm :loading="alertsStore.loading" :useMiles="true" @submit="handleSubmit" />
    </div>

    <!-- Error Message -->
    <div v-if="alertsStore.error" class="error-banner">
      <Icon icon="tabler:alert-triangle" class="error-icon" />
      <span>{{ alertsStore.error }}</span>
      <Button
        variant="ghost"
        size="sm"
        icon-left="tabler:x"
        @click="alertsStore.clearError"
        class="error-close"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
  import { onMounted } from 'vue'
  import { Icon } from '@iconify/vue'
  import { useAlertsStore } from '@/stores/alerts'
  import AlertForm from '@/components/alerts/AlertForm.vue'
  import Button from '@/components/widgets/Button.vue'

  const alertsStore = useAlertsStore()

  const handleSubmit = async (data: any) => {
    try {
      await alertsStore.createAlert(data)
    } catch (error) {
      // Error is handled by the store
    }
  }

  onMounted(() => {
    // Reset any previous error when the component mounts
    alertsStore.clearError()
  })
</script>

<style scoped>
  .form-section {
    @apply bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden;
  }

  .form-header {
    @apply flex items-center justify-between p-6 border-b border-gray-200;
  }

  .form-title {
    @apply text-xl font-semibold text-gray-900;
  }

  .close-button {
    @apply text-gray-400 hover:text-gray-600;
  }

  .error-banner {
    @apply flex items-center gap-3 p-4 bg-red-50 border border-red-200 rounded-lg;
    @apply text-red-700;
  }

  .error-icon {
    @apply w-5 h-5 text-red-500 flex-shrink-0;
  }

  .error-close {
    @apply ml-auto text-red-600 hover:text-red-800;
  }

  .alerts-section {
    @apply space-y-6;
  }

  .section-header {
    @apply flex items-center justify-between;
  }

  .section-title {
    @apply text-2xl font-semibold text-gray-900;
  }

  .section-actions {
    @apply flex items-center gap-4;
  }
</style>
