<template>
  <div class="notifications-view">
    <div class="notifications-container">
      <!-- Header -->
      <div class="notifications-header">
        <div class="header-content">
          <h1 class="page-title">Notifications</h1>
          <p class="page-description">See when new listings match your alert areas.</p>
        </div>
        <div class="header-actions">
          <Button
            v-if="notificationsStore.unreadCount > 0"
            variant="outline"
            @click="markAllAsRead"
            :loading="notificationsStore.loading"
            icon-left="tabler:check"
          >
            Mark All Read
          </Button>
          <Button variant="outline" :link="{ name: 'alerts' }" icon-left="tabler:settings">
            Manage Alerts
          </Button>
        </div>
      </div>

      <!-- Stats -->
      <div class="stats-section">
        <div class="stat-card">
          <div class="stat-icon unread">
            <Icon icon="tabler:bell" class="w-6 h-6" />
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ notificationsStore.unreadCount }}</div>
            <div class="stat-label">Unread</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon total">
            <Icon icon="tabler:list" class="w-6 h-6" />
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ notificationsStore.notifications.length }}</div>
            <div class="stat-label">Total</div>
          </div>
        </div>
      </div>

      <!-- Error Message -->
      <div v-if="notificationsStore.error" class="error-banner">
        <Icon icon="tabler:alert-triangle" class="error-icon" />
        <span>{{ notificationsStore.error }}</span>
        <Button
          variant="ghost"
          size="sm"
          icon-left="tabler:x"
          @click="notificationsStore.clearError"
          class="error-close"
        />
      </div>

      <!-- Notifications List -->
      <div class="notifications-section">
        <!-- Loading State -->
        <div
          v-if="notificationsStore.loading && notificationsStore.notifications.length === 0"
          class="loading-state"
        >
          <Icon icon="svg-spinners:3-dots-bounce" class="loading-spinner" />
          <p>Loading your notifications...</p>
        </div>

        <!-- Empty State -->
        <div
          v-else-if="!notificationsStore.loading && notificationsStore.notifications.length === 0"
          class="empty-state"
        >
          <div class="empty-icon">
            <Icon icon="tabler:bell-off" class="w-16 h-16 text-gray-300" />
          </div>
          <h3 class="empty-title">No notifications yet</h3>
          <p class="empty-description">
            You'll see notifications here when new listings match your alert areas.
          </p>
          <Button :link="{ name: 'alerts-create' }" icon-left="tabler:plus" class="mt-4">
            Create an Alert
          </Button>
        </div>

        <!-- Notifications -->
        <div v-else class="notifications-list">
          <div class="list-header">
            <h2 class="list-title">Recent Notifications</h2>
            <div class="list-filters">
              <Button
                variant="ghost"
                size="sm"
                :class="{ 'text-blue-600 bg-blue-50': showUnreadOnly }"
                @click="toggleUnreadFilter"
              >
                {{ showUnreadOnly ? 'Show All' : 'Unread Only' }}
              </Button>
            </div>
          </div>

          <div class="notifications-container-inner">
            <NotificationItem
              v-for="notification in filteredNotifications"
              :key="notification.id"
              :notification="notification"
              @click="handleNotificationClick"
            />
          </div>

          <!-- Load More -->
          <div v-if="notificationsStore.hasMore" class="load-more-section">
            <Button
              variant="outline"
              @click="loadMore"
              :loading="notificationsStore.loading"
              class="load-more-button"
            >
              Load More
            </Button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { useRouter } from 'vue-router'
  import { Icon } from '@iconify/vue'
  import type { Notification } from '@/types'
  import { useNotificationsStore } from '@/stores/notifications'
  import NotificationItem from '@/components/notifications/NotificationItem.vue'
  import Button from '@/components/widgets/Button.vue'

  const router = useRouter()
  const notificationsStore = useNotificationsStore()

  const showUnreadOnly = ref(false)

  const filteredNotifications = computed(() => {
    if (showUnreadOnly.value) {
      return notificationsStore.unreadNotifications
    }
    return notificationsStore.notifications
  })

  const toggleUnreadFilter = () => {
    showUnreadOnly.value = !showUnreadOnly.value
  }

  const markAllAsRead = async () => {
    try {
      await notificationsStore.markAllAsRead()
    } catch (error) {
      // Error is handled by the store
    }
  }

  const handleNotificationClick = async (notification: Notification) => {
    // Mark as read if unread
    if (!notification.read) {
      await notificationsStore.markAsRead(notification.id)
    }

    // Navigate to the listing
    router.push({ name: 'show', params: { id: notification.listing_id } })
  }

  const loadMore = async () => {
    try {
      await notificationsStore.loadMore()
    } catch (error) {
      // Error is handled by the store
    }
  }

  onMounted(() => {
    notificationsStore.initialize()
  })
</script>

<style scoped>
  .notifications-view {
    @apply min-h-screen bg-gray-50 py-8;
  }

  .notifications-container {
    @apply max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8;
  }

  .notifications-header {
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

  .header-actions {
    @apply flex items-center gap-3;
  }

  .stats-section {
    @apply grid grid-cols-2 gap-4 sm:gap-6;
  }

  .stat-card {
    @apply bg-white rounded-lg border border-gray-200 p-6 flex items-center;
  }

  .stat-icon {
    @apply w-12 h-12 rounded-lg flex items-center justify-center mr-4;
  }

  .stat-icon.unread {
    @apply bg-blue-100 text-blue-600;
  }

  .stat-icon.total {
    @apply bg-gray-100 text-gray-600;
  }

  .stat-content {
    @apply flex-1;
  }

  .stat-number {
    @apply text-2xl font-bold text-gray-900;
  }

  .stat-label {
    @apply text-sm text-gray-600;
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

  .notifications-section {
    @apply space-y-6;
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

  .notifications-list {
    @apply bg-white rounded-lg border border-gray-200 overflow-hidden;
  }

  .list-header {
    @apply flex items-center justify-between p-6 border-b border-gray-200;
  }

  .list-title {
    @apply text-xl font-semibold text-gray-900;
  }

  .list-filters {
    @apply flex items-center gap-2;
  }

  .notifications-container-inner {
    @apply divide-y divide-gray-100;
  }

  .load-more-section {
    @apply p-6 border-t border-gray-200 text-center;
  }

  .load-more-button {
    @apply w-full sm:w-auto;
  }
</style>
