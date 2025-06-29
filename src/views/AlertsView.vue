<template>
  <div class="alerts-view">
    <div class="alerts-container">
      <!-- Header -->
      <div class="alerts-header">
        <div class="header-content">
          <h1 class="page-title">Alert Management</h1>
          <p class="page-description">
            Create location-based alerts to get notified when new listings are posted in your area.
          </p>
        </div>
        <Button :link="{ name: 'alerts-create' }" icon-left="tabler:plus" class="create-button">
          Create Alert
        </Button>
      </div>

      <!-- Alerts List -->
      <div class="alerts-section">
        <div class="section-header">
          <h2 class="section-title">Your Alerts</h2>
          <div class="section-actions">
            <span class="alert-count">
              {{ alertsStore.alerts.length }} alert{{ alertsStore.alerts.length !== 1 ? 's' : '' }}
            </span>
          </div>
        </div>

        <!-- Loading State -->
        <div v-if="alertsStore.loading && alertsStore.alerts.length === 0" class="loading-state">
          <Icon icon="svg-spinners:3-dots-bounce" class="loading-spinner" />
          <p>Loading your alerts...</p>
        </div>

        <!-- Empty State -->
        <div
          v-else-if="!alertsStore.loading && alertsStore.alerts.length === 0"
          class="empty-state"
        >
          <div class="empty-icon">
            <Icon icon="tabler:bell-off" class="w-16 h-16 text-gray-300" />
          </div>
          <h3 class="empty-title">No alerts yet</h3>
          <p class="empty-description">
            Create your first alert to get notified when new listings are posted in your area.
          </p>
        </div>

        <!-- Alerts Grid -->
        <div v-else class="alerts-grid">
          <AlertCard
            v-for="alert in alertsStore.alerts"
            :key="alert.id"
            :alert="alert"
            @edit="handleEdit"
            @delete="handleDelete"
            @toggle="handleToggle"
          />
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="alertToDelete" class="modal-overlay" @click="cancelDelete">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title">Delete Alert</h3>
          <Button variant="ghost" icon-left="tabler:x" @click="cancelDelete" class="modal-close" />
        </div>
        <div class="modal-body">
          <p>
            Are you sure you want to delete the alert "<strong>{{ alertToDelete.name }}</strong
            >"?
          </p>
          <p class="text-sm text-gray-600 mt-2">
            You will no longer receive notifications for this area. This action cannot be undone.
          </p>
        </div>
        <div class="modal-actions">
          <Button variant="outline" @click="cancelDelete"> Cancel </Button>
          <Button
            variant="primary"
            @click="confirmDelete"
            :loading="alertsStore.loading"
            class="bg-red-600 hover:bg-red-700"
          >
            Delete Alert
          </Button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import { Icon } from '@iconify/vue'
  import type { Alert } from '@/types'
  import { useAlertsStore } from '@/stores/alerts'
  import AlertCard from '@/components/alerts/AlertCard.vue'
  import Button from '@/components/widgets/Button.vue'
  import { useRoute } from 'vue-router'

  const alertsStore = useAlertsStore()
  const route = useRoute()

  const showCreateForm = ref(!!route.params.create)
  const editingAlert = ref<Alert | null>(null)
  const alertToDelete = ref<Alert | null>(null)

  const handleEdit = (alert: Alert) => {
    editingAlert.value = alert
    showCreateForm.value = false
  }

  const handleDelete = (alert: Alert) => {
    alertToDelete.value = alert
  }

  const handleToggle = async (alert: Alert) => {
    try {
      await alertsStore.toggleAlert(alert.id)
    } catch (error) {
      // Error is handled by the store
    }
  }

  const cancelDelete = () => {
    alertToDelete.value = null
  }

  const confirmDelete = async () => {
    if (!alertToDelete.value) return

    try {
      await alertsStore.deleteAlert(alertToDelete.value.id)
      alertToDelete.value = null
    } catch (error) {
      // Error is handled by the store
    }
  }

  onMounted(() => {
    alertsStore.initialize()
  })
</script>

<style scoped>
  .alerts-view {
    @apply min-h-screen bg-gray-50 py-8;
  }

  .alerts-container {
    @apply max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8;
  }

  .alerts-header {
    @apply flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4;
  }

  .header-content {
    @apply flex-1;
  }

  .page-title {
    @apply text-3xl font-bold text-gray-900 mb-2;
  }

  .page-description {
    @apply text-gray-600 max-w-2xl;
  }

  .create-button {
    @apply sm:flex-shrink-0;
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

  .alert-count {
    @apply text-sm text-gray-600;
  }

  .loading-state {
    @apply flex flex-col items-center justify-center py-12 text-gray-500;
  }

  .loading-spinner {
    @apply w-8 h-8 mb-4;
  }

  .empty-state {
    @apply text-center py-12;
  }

  .empty-icon {
    @apply flex justify-center mb-4;
  }

  .empty-title {
    @apply text-xl font-semibold text-gray-900 mb-2;
  }

  .empty-description {
    @apply text-gray-600 max-w-md mx-auto;
  }

  .alerts-grid {
    @apply grid gap-4 md:grid-cols-2 lg:grid-cols-3;
  }

  .modal-overlay {
    @apply fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4;
  }

  .modal-content {
    @apply bg-white rounded-lg shadow-xl max-w-md w-full;
  }

  .modal-header {
    @apply flex items-center justify-between p-6 border-b border-gray-200;
  }

  .modal-title {
    @apply text-lg font-semibold text-gray-900;
  }

  .modal-close {
    @apply text-gray-400 hover:text-gray-600;
  }

  .modal-body {
    @apply p-6;
  }

  .modal-actions {
    @apply flex gap-3 p-6 border-t border-gray-200;
  }
</style>
