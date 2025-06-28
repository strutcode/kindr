import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import type { Notification, NotificationState } from '@/types'
import { useAuthStore } from './auth'

export const useNotificationsStore = defineStore('notifications', () => {
  const authStore = useAuthStore()

  const state = ref<NotificationState>({
    notifications: [],
    unreadCount: 0,
    loading: false,
    error: null,
    hasMore: true,
    offset: 0,
  })

  // Realtime subscription
  let subscription: any = null

  // Computed getters
  const notifications = computed(() => state.value.notifications)
  const unreadCount = computed(() => state.value.unreadCount)
  const unreadNotifications = computed(() => state.value.notifications.filter(n => !n.read))
  const loading = computed(() => state.value.loading)
  const error = computed(() => state.value.error)
  const hasMore = computed(() => state.value.hasMore)

  // Clear error
  const clearError = () => {
    state.value.error = null
  }

  // Fetch notifications with pagination
  const fetchNotifications = async (refresh = false) => {
    if (!authStore.user) return

    try {
      state.value.loading = true
      state.value.error = null

      const offset = refresh ? 0 : state.value.offset
      const limit = 20

      const { data, error } = await supabase.rpc('get_user_notifications', {
        p_limit: limit,
        p_offset: offset,
        p_unread_only: false,
      })

      if (error) throw error

      const newNotifications: Notification[] =
        data?.map((item: any) => ({
          id: item.id,
          alert_id: item.alert_id,
          alert_name: item.alert_name,
          listing_id: item.listing_id,
          listing_title: item.listing_title,
          listing_category: item.listing_category,
          listing_location: {
            lat: item.listing_location.coordinates[1],
            lng: item.listing_location.coordinates[0],
          },
          user_id: authStore.user!.id,
          read: item.read,
          created_at: item.created_at,
        })) || []

      if (refresh) {
        state.value.notifications = newNotifications
        state.value.offset = 0
      } else {
        state.value.notifications.push(...newNotifications)
      }

      state.value.offset += newNotifications.length
      state.value.hasMore = newNotifications.length === limit
    } catch (err) {
      console.error('Error fetching notifications:', err)
      state.value.error = err instanceof Error ? err.message : 'Failed to fetch notifications'
    } finally {
      state.value.loading = false
    }
  }

  // Fetch unread count
  const fetchUnreadCount = async () => {
    if (!authStore.user) return

    try {
      const { data, error } = await supabase.rpc('get_unread_notification_count')

      if (error) throw error

      state.value.unreadCount = data || 0
    } catch (err) {
      console.error('Error fetching unread count:', err)
    }
  }

  // Mark notification as read
  const markAsRead = async (notificationId: string) => {
    if (!authStore.user) return

    try {
      const { error } = await supabase.rpc('mark_notification_as_read', {
        p_notification_id: notificationId,
      })

      if (error) throw error

      // Update local state
      const notification = state.value.notifications.find(n => n.id === notificationId)
      if (notification && !notification.read) {
        notification.read = true
        state.value.unreadCount = Math.max(0, state.value.unreadCount - 1)
      }
    } catch (err) {
      console.error('Error marking notification as read:', err)
      state.value.error = err instanceof Error ? err.message : 'Failed to mark notification as read'
    }
  }

  // Mark all notifications as read
  const markAllAsRead = async () => {
    if (!authStore.user) return

    try {
      const { error } = await supabase.rpc('mark_all_notifications_as_read')

      if (error) throw error

      // Update local state
      state.value.notifications.forEach(notification => {
        notification.read = true
      })
      state.value.unreadCount = 0
    } catch (err) {
      console.error('Error marking all notifications as read:', err)
      state.value.error =
        err instanceof Error ? err.message : 'Failed to mark all notifications as read'
    }
  }

  // Handle new notification from realtime
  const handleNotificationInsert = async (payload: any) => {
    if (!authStore.user || payload.new.user_id !== authStore.user.id) return

    try {
      // Fetch the complete notification data
      const { data, error } = await supabase.rpc('get_user_notifications', {
        p_limit: 1,
        p_offset: 0,
        p_unread_only: false,
      })

      if (error) throw error

      if (data && data.length > 0) {
        const newNotification: Notification = {
          id: data[0].id,
          alert_id: data[0].alert_id,
          alert_name: data[0].alert_name,
          listing_id: data[0].listing_id,
          listing_title: data[0].listing_title,
          listing_category: data[0].listing_category,
          listing_location: {
            lat: data[0].listing_location.coordinates[1],
            lng: data[0].listing_location.coordinates[0],
          },
          user_id: authStore.user.id,
          read: data[0].read,
          created_at: data[0].created_at,
        }

        // Add to the beginning of the list if it's not already there
        const exists = state.value.notifications.find(n => n.id === newNotification.id)
        if (!exists) {
          state.value.notifications.unshift(newNotification)
          if (!newNotification.read) {
            state.value.unreadCount += 1
          }
        }
      }
    } catch (err) {
      console.error('Error handling new notification:', err)
    }
  }

  // Load more notifications
  const loadMore = async () => {
    if (!state.value.hasMore || state.value.loading) return
    await fetchNotifications(false)
  }

  // Initialize store
  const initialize = () => {
    if (!authStore.user) return

    // Fetch initial data
    fetchNotifications(true)
    fetchUnreadCount()

    // Set up realtime subscription for new notifications
    if (!subscription) {
      subscription = supabase
        .channel('notifications')
        .on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table: 'notifications',
            filter: `user_id=eq.${authStore.user.id}`,
          },
          handleNotificationInsert,
        )
        .subscribe()
    }
  }

  // Cleanup
  const cleanup = () => {
    if (subscription) {
      supabase.removeChannel(subscription)
      subscription = null
    }

    state.value.notifications = []
    state.value.unreadCount = 0
    state.value.loading = false
    state.value.error = null
    state.value.hasMore = true
    state.value.offset = 0
  }

  return {
    // State
    notifications,
    unreadCount,
    unreadNotifications,
    loading,
    error,
    hasMore,

    // Actions
    clearError,
    fetchNotifications,
    fetchUnreadCount,
    markAsRead,
    markAllAsRead,
    loadMore,
    initialize,
    cleanup,
  }
})
