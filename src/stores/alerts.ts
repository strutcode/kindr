import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import type { Alert, AlertState } from '@/types'
import { useAuthStore } from './auth'

export const useAlertsStore = defineStore('alerts', () => {
  const authStore = useAuthStore()

  const state = ref<AlertState>({
    alerts: [],
    loading: false,
    error: null,
  })

  // Computed getters
  const alerts = computed(() => state.value.alerts)
  const loading = computed(() => state.value.loading)
  const error = computed(() => state.value.error)
  const activeAlerts = computed(() => state.value.alerts.filter(alert => alert.active))

  // Clear error
  const clearError = () => {
    state.value.error = null
  }

  // Fetch all user alerts
  const fetchAlerts = async () => {
    if (!authStore.user) return

    try {
      state.value.loading = true
      state.value.error = null

      const { data, error } = await supabase
        .from('alerts')
        .select('*')
        .eq('user_id', authStore.user.id)
        .order('created_at', { ascending: false })

      if (error) throw error

      state.value.alerts =
        data?.map(alert => ({
          ...alert,
          location: {
            lat: alert.location.coordinates[1],
            lng: alert.location.coordinates[0],
          },
        })) || []
    } catch (err) {
      console.error('Error fetching alerts:', err)
      state.value.error = err instanceof Error ? err.message : 'Failed to fetch alerts'
    } finally {
      state.value.loading = false
    }
  }

  // Create new alert
  const createAlert = async (alertData: {
    name: string
    location: { lat: number; lng: number }
    radius_meters: number
    category?: string
  }) => {
    if (!authStore.user) throw new Error('Not authenticated')

    try {
      state.value.loading = true
      state.value.error = null

      const { data, error } = await supabase
        .from('alerts')
        .insert({
          user_id: authStore.user.id,
          name: alertData.name,
          location: `POINT(${alertData.location.lng} ${alertData.location.lat})`,
          radius_meters: alertData.radius_meters,
          category: alertData.category || null,
        })
        .select()
        .single()

      if (error) throw error

      const newAlert: Alert = {
        ...data,
        location: {
          lat: data.location.coordinates[1],
          lng: data.location.coordinates[0],
        },
      }

      state.value.alerts.unshift(newAlert)
      return newAlert
    } catch (err) {
      console.error('Error creating alert:', err)
      state.value.error = err instanceof Error ? err.message : 'Failed to create alert'
      throw err
    } finally {
      state.value.loading = false
    }
  }

  // Update alert
  const updateAlert = async (alertId: string, updates: Partial<Alert>) => {
    if (!authStore.user) throw new Error('Not authenticated')

    try {
      state.value.loading = true
      state.value.error = null

      const updateData: any = { ...updates }

      // Convert location if provided
      if (updates.location) {
        updateData.location = `POINT(${updates.location.lng} ${updates.location.lat})`
      }

      // Remove id and other read-only fields
      delete updateData.id
      delete updateData.user_id
      delete updateData.created_at
      updateData.updated_at = new Date().toISOString()

      const { data, error } = await supabase
        .from('alerts')
        .update(updateData)
        .eq('id', alertId)
        .eq('user_id', authStore.user.id)
        .select()
        .single()

      if (error) throw error

      const updatedAlert: Alert = {
        ...data,
        location: {
          lat: data.location.coordinates[1],
          lng: data.location.coordinates[0],
        },
      }

      const index = state.value.alerts.findIndex(alert => alert.id === alertId)
      if (index >= 0) {
        state.value.alerts[index] = updatedAlert
      }

      return updatedAlert
    } catch (err) {
      console.error('Error updating alert:', err)
      state.value.error = err instanceof Error ? err.message : 'Failed to update alert'
      throw err
    } finally {
      state.value.loading = false
    }
  }

  // Delete alert
  const deleteAlert = async (alertId: string) => {
    if (!authStore.user) throw new Error('Not authenticated')

    try {
      state.value.loading = true
      state.value.error = null

      const { error } = await supabase
        .from('alerts')
        .delete()
        .eq('id', alertId)
        .eq('user_id', authStore.user.id)

      if (error) throw error

      state.value.alerts = state.value.alerts.filter(alert => alert.id !== alertId)
    } catch (err) {
      console.error('Error deleting alert:', err)
      state.value.error = err instanceof Error ? err.message : 'Failed to delete alert'
      throw err
    } finally {
      state.value.loading = false
    }
  }

  // Toggle alert active status
  const toggleAlert = async (alertId: string) => {
    const alert = state.value.alerts.find(a => a.id === alertId)
    if (!alert) return

    await updateAlert(alertId, { active: !alert.active })
  }

  // Initialize store
  const initialize = () => {
    if (authStore.user) {
      fetchAlerts()
    }
  }

  // Cleanup
  const cleanup = () => {
    state.value.alerts = []
    state.value.loading = false
    state.value.error = null
  }

  return {
    // State
    alerts,
    loading,
    error,
    activeAlerts,

    // Actions
    clearError,
    fetchAlerts,
    createAlert,
    updateAlert,
    deleteAlert,
    toggleAlert,
    initialize,
    cleanup,
  }
})
