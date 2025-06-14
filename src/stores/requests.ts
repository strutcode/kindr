import { defineStore } from 'pinia'
import { ref, computed, readonly } from 'vue'
import { supabase, handleSupabaseResponse, SupabaseError, retryOperation } from '@/lib/supabase'
import { SpatialQueryService, type MapBounds, type RequestWithDistance } from '@/services/spatialQueries'
import type { Request, RequestFilters } from '@/types'

export const useRequestsStore = defineStore('requests', () => {
  const requests = ref<Request[]>([])
  const userRequests = ref<Request[]>([])
  const spatialRequests = ref<RequestWithDistance[]>([])
  const loading = ref(false)
  const error = ref<string>('')
  const filters = ref<RequestFilters>({
    radius: 2,
  })

  const activeRequests = computed(() => 
    requests.value.filter(req => req.status === 'active')
  )

  const activeSpatialRequests = computed(() => 
    spatialRequests.value.filter(req => req.status === 'active')
  )

  const fetchRequests = async (filterOptions?: RequestFilters) => {
    loading.value = true
    error.value = ''
    
    try {
      console.log('Fetching requests with filters:', filterOptions)
      
      const requestsData = await retryOperation(async () => {
        let query = supabase
          .from('requests')
          .select(`
            *,
            user:users!requests_user_id_fkey(
              id, 
              full_name, 
              avatar_url,
              email
            )
          `)
          .eq('status', 'active')
          .order('created_at', { ascending: false })
          .limit(100) // Add reasonable limit

        if (filterOptions?.category) {
          query = query.eq('category', filterOptions.category)
        }

        if (filterOptions?.subcategory) {
          query = query.eq('subcategory', filterOptions.subcategory)
        }

        return await handleSupabaseResponse(
          () => query,
          'fetchRequests',
          10000 // 10 second timeout for large queries
        )
      }, 3, 1000)

      console.log(`Fetched ${requestsData?.length || 0} requests`)

      // Transform the data to match our Request type
      requests.value = (requestsData || []).map(item => ({
        ...item,
        user: item.user ? {
          id: item.user.id,
          full_name: item.user.full_name,
          avatar_url: item.user.avatar_url,
          email: item.user.email,
        } : undefined
      }))

    } catch (err) {
      console.error('Error fetching requests:', err)
      error.value = err instanceof SupabaseError ? err.message : 'Failed to load requests'
      requests.value = []
    } finally {
      loading.value = false
    }
  }

  const fetchRequestsInBounds = async (
    bounds: MapBounds,
    filterOptions?: { category?: string; subcategory?: string; limit?: number }
  ) => {
    loading.value = true
    error.value = ''
    
    try {
      console.log('Fetching requests in bounds:', bounds, filterOptions)
      
      const spatialRequestsData = await SpatialQueryService.getRequestsInBounds(bounds, {
        category: filterOptions?.category,
        subcategory: filterOptions?.subcategory,
        status: 'active',
        limit: filterOptions?.limit || 200
      })

      console.log(`Fetched ${spatialRequestsData.length} spatial requests`)
      spatialRequests.value = spatialRequestsData

      return spatialRequestsData
    } catch (err) {
      console.error('Error fetching requests in bounds:', err)
      error.value = err instanceof SupabaseError ? err.message : 'Failed to load requests in map bounds'
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
    filterOptions?: { category?: string; subcategory?: string; limit?: number }
  ) => {
    loading.value = true
    error.value = ''
    
    try {
      console.log('Fetching requests in radius:', { centerLat, centerLng, radiusMiles }, filterOptions)
      
      const radiusMeters = SpatialQueryService.milesToMeters(radiusMiles)
      const spatialRequestsData = await SpatialQueryService.getRequestsInRadius(
        centerLat,
        centerLng,
        radiusMeters,
        {
          category: filterOptions?.category,
          subcategory: filterOptions?.subcategory,
          status: 'active',
          limit: filterOptions?.limit || 200
        }
      )

      console.log(`Fetched ${spatialRequestsData.length} spatial requests in radius`)
      spatialRequests.value = spatialRequestsData

      return spatialRequestsData
    } catch (err) {
      console.error('Error fetching requests in radius:', err)
      error.value = err instanceof SupabaseError ? err.message : 'Failed to load requests in radius'
      spatialRequests.value = []
      return []
    } finally {
      loading.value = false
    }
  }

  const fetchUserRequests = async (userId: string) => {
    if (!userId) {
      error.value = 'User ID is required'
      return
    }

    loading.value = true
    error.value = ''
    
    try {
      console.log('Fetching user requests for:', userId)
      
      const userRequestsData = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase
            .from('requests')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: false })
            .limit(50), // Add reasonable limit
          'fetchUserRequests',
          8000
        )
      }, 3, 1000)

      console.log(`Fetched ${userRequestsData?.length || 0} user requests`)
      userRequests.value = userRequestsData || []
    } catch (err) {
      console.error('Error fetching user requests:', err)
      error.value = err instanceof SupabaseError ? err.message : 'Failed to load your requests'
      userRequests.value = []
    } finally {
      loading.value = false
    }
  }

  const createRequest = async (requestData: Omit<Request, 'id' | 'created_at' | 'updated_at'>) => {
    loading.value = true
    error.value = ''
    
    try {
      // Validate that user_id is provided
      if (!requestData.user_id) {
        throw new SupabaseError('User ID is required to create a request', 'VALIDATION_ERROR')
      }

      console.log('Creating request:', requestData.title)

      // Clean the request data
      const cleanedData = { ...requestData }
      if (cleanedData.duration_estimate === undefined) {
        delete cleanedData.duration_estimate
      }

      const createdRequest = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase
            .from('requests')
            .insert([cleanedData])
            .select(`
              *,
              user:users!requests_user_id_fkey(
                id, 
                full_name, 
                avatar_url,
                email
              )
            `)
            .single(),
          'createRequest',
          8000
        )
      }, 2, 1000)

      console.log('Request created successfully:', createdRequest.id)
      
      // Transform the data to match our Request type
      const transformedData = {
        ...createdRequest,
        user: createdRequest.user ? {
          id: createdRequest.user.id,
          full_name: createdRequest.user.full_name,
          avatar_url: createdRequest.user.avatar_url,
          email: createdRequest.user.email,
        } : undefined
      }
      
      // Add to local state
      requests.value.unshift(transformedData)
      if (requestData.user_id) {
        userRequests.value.unshift(transformedData)
      }
      
      return { data: transformedData, error: null }
    } catch (err) {
      console.error('Error creating request:', err)
      const errorMessage = err instanceof SupabaseError ? err.message : 'Failed to create request'
      error.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const updateRequest = async (id: string, updates: Partial<Request>) => {
    if (!id) {
      const errorMsg = 'Request ID is required'
      error.value = errorMsg
      return { data: null, error: errorMsg }
    }

    loading.value = true
    error.value = ''
    
    try {
      console.log('Updating request:', id)

      // Clean the updates
      const cleanedUpdates = { ...updates }
      if (cleanedUpdates.duration_estimate === undefined) {
        delete cleanedUpdates.duration_estimate
      }

      const updatedRequest = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase
            .from('requests')
            .update(cleanedUpdates)
            .eq('id', id)
            .select(`
              *,
              user:users!requests_user_id_fkey(
                id, 
                full_name, 
                avatar_url,
                email
              )
            `)
            .single(),
          'updateRequest',
          8000
        )
      }, 2, 1000)

      console.log('Request updated successfully:', id)
      
      // Transform the data to match our Request type
      const transformedData = {
        ...updatedRequest,
        user: updatedRequest.user ? {
          id: updatedRequest.user.id,
          full_name: updatedRequest.user.full_name,
          avatar_url: updatedRequest.user.avatar_url,
          email: updatedRequest.user.email,
        } : undefined
      }
      
      // Update local state
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
      const errorMessage = err instanceof SupabaseError ? err.message : 'Failed to update request'
      error.value = errorMessage
      return { data: null, error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const deleteRequest = async (id: string) => {
    if (!id) {
      const errorMsg = 'Request ID is required'
      error.value = errorMsg
      return { error: errorMsg }
    }

    loading.value = true
    error.value = ''
    
    try {
      console.log('Deleting request:', id)

      await retryOperation(async () => {
        await handleSupabaseResponse(
          () => supabase
            .from('requests')
            .delete()
            .eq('id', id),
          'deleteRequest',
          5000
        )
      }, 2, 1000)

      console.log('Request deleted successfully:', id)
      
      // Remove from local state
      requests.value = requests.value.filter(req => req.id !== id)
      userRequests.value = userRequests.value.filter(req => req.id !== id)
      spatialRequests.value = spatialRequests.value.filter(req => req.id !== id)
      
      return { error: null }
    } catch (err) {
      console.error('Error deleting request:', err)
      const errorMessage = err instanceof SupabaseError ? err.message : 'Failed to delete request'
      error.value = errorMessage
      return { error: errorMessage }
    } finally {
      loading.value = false
    }
  }

  const getRequestById = async (id: string): Promise<Request | null> => {
    if (!id) {
      console.warn('Request ID is required')
      return null
    }

    try {
      // First check if we already have it in our local state
      const localRequest = requests.value.find(req => req.id === id) ||
                          spatialRequests.value.find(req => req.id === id)
      if (localRequest) {
        console.log('Found request in local state:', id)
        return localRequest
      }

      console.log('Fetching request from database:', id)

      // If not found locally, fetch from database
      const requestData = await retryOperation(async () => {
        return await handleSupabaseResponse(
          () => supabase
            .from('requests')
            .select(`
              *,
              user:users!requests_user_id_fkey(
                id, 
                full_name, 
                avatar_url,
                email
              )
            `)
            .eq('id', id)
            .single(),
          'getRequestById',
          5000
        )
      }, 2, 500)

      console.log('Request fetched successfully:', id)

      // Transform the data to match our Request type
      return {
        ...requestData,
        user: requestData.user ? {
          id: requestData.user.id,
          full_name: requestData.user.full_name,
          avatar_url: requestData.user.avatar_url,
          email: requestData.user.email,
        } : undefined
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
    error.value = ''
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

  return {
    requests: readonly(requests),
    userRequests: readonly(userRequests),
    spatialRequests: readonly(spatialRequests),
    loading: readonly(loading),
    error: readonly(error),
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
  }
})