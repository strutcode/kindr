import { defineStore } from 'pinia'
import { ref, computed, readonly } from 'vue'
import { supabase } from '@/lib/supabase'
import {
  SpatialQueryService,
  type MapBounds,
  type RequestWithDistance,
} from '@/services/spatialQueries'
import type { Request, RequestFilters } from '@/types'
import { createLogger } from '@/lib/logger'

const { debug, warn, error } = createLogger('Requests')

export const useRequestsStore = defineStore('requests', () => {
  const requests = ref<Request[]>([])
  const userRequests = ref<Request[]>([])
  const spatialRequests = ref<RequestWithDistance[]>([])
  const loading = ref(false)
  const errorMessage = ref<string>('')
  const filters = ref<RequestFilters>({
    radius: 2,
  })
  const showFiltersPopover = ref(false)

  const activeRequests = computed(() => requests.value.filter(req => req.status === 'active'))

  const activeSpatialRequests = computed(() =>
    spatialRequests.value.filter(req => req.status === 'active'),
  )

  const fetchRequests = async (filterOptions?: RequestFilters) => {
    loading.value = true
    errorMessage.value = ''

    try {
      debug('Fetching requests with filters:', filterOptions)

      let query = supabase
        .from('requests')
        .select(
          `
          *,
          user:users!requests_user_id_fkey(
            id, 
            full_name, 
            avatar_url,
            email
          )
        `,
        )
        .eq('status', 'active')
        .order('created_at', { ascending: false })
        .limit(100) // Add reasonable limit

      if (filterOptions?.category) {
        query = query.eq('category', filterOptions.category)
      }

      if (filterOptions?.subcategory) {
        query = query.eq('subcategory', filterOptions.subcategory)
      }

      const { data, error: fetchError } = await query
      if (fetchError) throw new Error(fetchError.message)

      debug(`Fetched ${data?.length || 0} requests`)

      // Transform the data to match our Request type
      requests.value = (data || []).map(item => ({
        ...item,
        user: item.user
          ? {
              id: item.user.id,
              full_name: item.user.full_name,
              avatar_url: item.user.avatar_url,
              email: item.user.email,
            }
          : undefined,
      }))
    } catch (err) {
      console.error('Error fetching requests:', err)
      errorMessage.value = err instanceof Error ? err.message : 'Failed to load requests'
      requests.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchRequestsInBounds = async (
    bounds: MapBounds,
    filterOptions?: { category?: string; subcategory?: string; limit?: number },
  ) => {
    loading.value = true
    errorMessage.value = ''

    try {
      debug('Fetching requests in bounds:', bounds, filterOptions)

      const spatialRequestsData = await SpatialQueryService.getRequestsInBounds(bounds, {
        category: filterOptions?.category,
        subcategory: filterOptions?.subcategory,
        status: 'active',
        limit: filterOptions?.limit || 200,
      })

      debug(`Fetched ${spatialRequestsData.length} spatial requests`)
      spatialRequests.value = spatialRequestsData

      return spatialRequestsData
    } catch (err) {
      console.error('Error fetching requests in bounds:', err)
      errorMessage.value =
        err instanceof Error ? err.message : 'Failed to load requests in map bounds'
      spatialRequests.value = []
      return []
    } finally {
      loading.value = false
    }
  }

  const fetchRequestsInRadius = async (
    centerLat: number,
    centerLng: number,
    radiusMiles: number,
    filterOptions?: { category?: string; subcategory?: string; limit?: number },
  ) => {
    loading.value = true
    errorMessage.value = ''

    try {
      debug('Fetching requests in radius:', { centerLat, centerLng, radiusMiles }, filterOptions)

      const radiusMeters = SpatialQueryService.milesToMeters(radiusMiles)
      const spatialRequestsData = await SpatialQueryService.getRequestsInRadius(
        centerLat,
        centerLng,
        radiusMeters,
        {
          category: filterOptions?.category,
          subcategory: filterOptions?.subcategory,
          status: 'active',
          limit: filterOptions?.limit || 200,
        },
      )

      debug(`Fetched ${spatialRequestsData.length} spatial requests in radius`)
      spatialRequests.value = spatialRequestsData

      return spatialRequestsData
    } catch (err) {
      console.error('Error fetching requests in radius:', err)
      errorMessage.value = err instanceof Error ? err.message : 'Failed to load requests in radius'
      spatialRequests.value = []
      return []
    } finally {
      loading.value = false
    }
  }

  const fetchUserRequests = async (userId: string) => {
    if (!userId) {
      errorMessage.value = 'User ID is required'
      return
    }

    loading.value = true
    errorMessage.value = ''

    try {
      debug('Fetching user requests for:', userId)

      const { data, error: fetchError } = await supabase
        .from('requests')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(50) // Add reasonable limit

      if (fetchError) throw new Error(fetchError.message)

      debug(`Fetched ${data?.length || 0} user requests`)
      userRequests.value = data || []
    } catch (err) {
      console.error('Error fetching user requests:', err)
      errorMessage.value = err instanceof Error ? err.message : 'Failed to load your requests'
      userRequests.value = []
    } finally {
      loading.value = false
    }
  }

  const createRequest = async (requestData: Omit<Request, 'id' | 'created_at' | 'updated_at'>) => {
    loading.value = true
    errorMessage.value = ''

    try {
      if (!requestData.user_id) {
        throw new Error('User ID is required to create a request')
      }

      debug('Creating request:', requestData.title)

      const cleanedData = { ...requestData }
      if (cleanedData.duration_estimate === undefined) {
        delete cleanedData.duration_estimate
      }

      const { data, error: createError } = await supabase
        .from('requests')
        .insert([cleanedData])
        .select(
          `
          *,
          user:users!requests_user_id_fkey(
            id, 
            full_name, 
            avatar_url,
            email
          )
        `,
        )
        .single()

      if (createError) throw new Error(createError.message)

      debug('Request created successfully:', data.id)

      const transformedData = {
        ...data,
        user: data.user
          ? {
              id: data.user.id,
              full_name: data.user.full_name,
              avatar_url: data.user.avatar_url,
              email: data.user.email,
            }
          : undefined,
      }

      requests.value.unshift(transformedData)
      if (requestData.user_id) {
        userRequests.value.unshift(transformedData)
      }

      return { data: transformedData, error: null }
    } catch (err) {
      console.error('Error creating request:', err)
      const errorMessage = err instanceof Error ? err.message : 'Failed to create request'
      errorMessage.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const updateRequest = async (id: string, updates: Partial<Request>) => {
    if (!id) {
      const errorMsg = 'Request ID is required'
      errorMessage.value = errorMsg
      return { data: null, error: errorMsg }
    }

    loading.value = true
    errorMessage.value = ''

    try {
      debug('Updating request:', id)

      const cleanedUpdates = { ...updates }
      if (cleanedUpdates.duration_estimate === undefined) {
        delete cleanedUpdates.duration_estimate
      }

      const { data, error: updateError } = await supabase
        .from('requests')
        .update(cleanedUpdates)
        .eq('id', id)
        .select(
          `
          *,
          user:users!requests_user_id_fkey(
            id, 
            full_name, 
            avatar_url,
            email
          )
        `,
        )
        .single()

      if (updateError) throw new Error(updateError.message)

      debug('Request updated successfully:', id)

      const transformedData = {
        ...data,
        user: data.user
          ? {
              id: data.user.id,
              full_name: data.user.full_name,
              avatar_url: data.user.avatar_url,
              email: data.user.email,
            }
          : undefined,
      }

      const index = requests.value.findIndex(req => req.id === id)
      if (index !== -1) {
        requests.value[index] = transformedData
      }

      const userIndex = userRequests.value.findIndex(req => req.id === id)
      if (userIndex !== -1) {
        userRequests.value[userIndex] = transformedData
      }

      return { data: transformedData, error: null }
    } catch (err) {
      console.error('Error updating request:', err)
      const errorMessage = err instanceof Error ? err.message : 'Failed to update request'
      errorMessage.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const deleteRequest = async (id: string) => {
    if (!id) {
      const errorMsg = 'Request ID is required'
      errorMessage.value = errorMsg
      return { error: errorMsg }
    }

    loading.value = true
    errorMessage.value = ''

    try {
      debug('Deleting request:', id)

      const { error: deleteError } = await supabase.from('requests').delete().eq('id', id)

      if (deleteError) throw new Error(deleteError.message)

      debug('Request deleted successfully:', id)

      // Remove from local state
      requests.value = requests.value.filter(req => req.id !== id)
      userRequests.value = userRequests.value.filter(req => req.id !== id)
      spatialRequests.value = spatialRequests.value.filter(req => req.id !== id)

      return { error: null }
    } catch (err) {
      console.error('Error deleting request:', err)
      const errorMessage = err instanceof Error ? err.message : 'Failed to delete request'
      errorMessage.value = errorMessage
      return { error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const getRequestById = async (id: string): Promise<Request | null> => {
    if (!id) {
      warn('Request ID is required')
      return null
    }

    try {
      // First check if we already have it in our local state
      const localRequest =
        requests.value.find(req => req.id === id) ||
        spatialRequests.value.find(req => req.id === id)
      if (localRequest) {
        debug('Found request in local state:', id)
        return localRequest
      }

      debug('Fetching request from database:', id)

      // If not found locally, fetch from database
      const { data: requestData } = await supabase
        .from('requests')
        .select(
          `
              *,
              user:users!requests_user_id_fkey(
                id, 
                full_name, 
                avatar_url,
                email
              )
            `,
        )
        .eq('id', id)
        .single()

      debug('Request fetched successfully:', id)

      // Transform the data to match our Request type
      return {
        ...requestData,
        user: requestData.user
          ? {
              id: requestData.user.id,
              full_name: requestData.user.full_name,
              avatar_url: requestData.user.avatar_url,
              email: requestData.user.email,
            }
          : undefined,
      }
    } catch (err) {
      console.error('Error fetching request by ID:', err)
      if (err instanceof SupabaseError && err.code === 'NOT_FOUND') {
        return null
      }
      // Don't throw here, just return null for not found
      return null
    }
  }

  const updateFilters = (newFilters: Partial<RequestFilters>) => {
    filters.value = { ...filters.value, ...newFilters }
  }

  // Method to clear loading state manually if needed
  const clearLoading = () => {
    loading.value = false
  }

  // Method to clear errors
  const clearError = () => {
    errorMessage.value = ''
  }

  // Method to refresh requests
  const refreshRequests = async () => {
    await fetchRequests(filters.value)
  }

  // Method to validate request geometries (admin function)
  const validateGeometries = async () => {
    try {
      return await SpatialQueryService.validateRequestGeometries()
    } catch (err) {
      console.error('Error validating geometries:', err)
      throw err
    }
  }

  // Define missing functions and types
  const retryOperation = async <T>(
    operation: () => Promise<T>,
    retries: number,
    delay: number,
  ): Promise<T> => {
    let attempt = 0
    while (attempt < retries) {
      try {
        return await operation()
      } catch (error) {
        if (attempt === retries - 1) throw error
        await new Promise(resolve => setTimeout(resolve, delay))
        attempt++
      }
    }
    throw new Error('Operation failed after maximum retries')
  }

  const handleSupabaseResponse = async <T>(
    operation: () => Promise<T>,
    context: string,
    timeout: number,
  ): Promise<T> => {
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), timeout)
    try {
      return await operation()
    } finally {
      clearTimeout(timeoutId)
    }
  }

  class SupabaseError extends Error {
    constructor(public code: string, message: string) {
      super(message)
    }
  }

  const toggleFiltersPopover = () => {
    showFiltersPopover.value = !showFiltersPopover.value
  }
  const openFiltersPopover = () => {
    showFiltersPopover.value = true
  }
  const closeFiltersPopover = () => {
    showFiltersPopover.value = false
  }

  return {
    requests: readonly(requests),
    userRequests: readonly(userRequests),
    spatialRequests: readonly(spatialRequests),
    loading: readonly(loading),
    error: readonly(errorMessage),
    filters: readonly(filters),
    activeRequests,
    activeSpatialRequests,
    fetchRequests,
    fetchRequestsInBounds,
    fetchRequestsInRadius,
    fetchUserRequests,
    createRequest,
    updateRequest,
    deleteRequest,
    getRequestById,
    updateFilters,
    clearLoading,
    clearError,
    refreshRequests,
    validateGeometries,
    showFiltersPopover,
    toggleFiltersPopover,
    openFiltersPopover,
    closeFiltersPopover,
  }
})
