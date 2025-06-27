import { ref } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import { Listing, ListingFilters, MapBounds } from '@/types'
import { useAuthStore } from './auth'

export const useListingsStore = defineStore('listings', () => {
  const listings = ref<Listing[]>([])

  const fetchListings = async () => {
    try {
      const res = await supabase
        .from('listings')
        .select('*')
        .eq('active', true) // Assuming you want only active listings
        .order('created_at', { ascending: false })

      if (res.error) {
        throw res.error
      }

      listings.value = res.data.map(entry => ({
        ...entry,
        location: {
          lat: entry.location?.coordinates[1] || 0,
          lng: entry.location?.coordinates[0] || 0,
        },
      }))
    } catch (error) {
      console.error('Error fetching listings:', error)
    }
  }

  const fetchSingleListing = async (id: string) => {
    try {
      const { data, error } = await supabase
        .from('listings')
        .select(`*, user:users!listings_user_id_fkey(id, full_name, avatar_url)`)
        .eq('id', id)
        .single()

      if (error) {
        throw error
      }

      if (data) {
        const listing = {
          ...data,
          location: {
            lat: data.location?.coordinates[1] || 0,
            lng: data.location?.coordinates[0] || 0,
          },
          user: {
            id: data.user?.id || '',
            full_name: data.user?.full_name || '',
            avatar_url: data.user?.avatar_url || '',
            email: data.user?.email || '',
          },
        }

        listings.value.push(listing) // Add to listings array
        return listing
      }
    } catch (error) {
      console.error('Error fetching single listing:', error)
    }
    return null
  }

  const fetchListingsInBounds = async (bounds: MapBounds, filters: ListingFilters) => {
    try {
      const { north, south, east, west } = bounds
      const { category, subcategory, activeOnly } = filters

      const { data, error } = await supabase.rpc('get_requests_in_bounds', {
        north,
        south,
        east,
        west,
        p_category: category ?? null,
        p_subcategory: subcategory ?? null,
        p_active: activeOnly ?? null,
        p_limit: 200,
      })

      if (error) {
        throw error
      }

      listings.value = data.map((entry: any) => ({
        ...entry,
        location: {
          lat: entry.location?.coordinates[1] || 0,
          lng: entry.location?.coordinates[0] || 0,
        },
      }))
    } catch (error) {
      console.error('Error fetching listings in bounds:', error)
    }
  }

  const createListing = async (form: Partial<Listing>) => {
    debugger
    const authStore = useAuthStore()

    try {
      const input: any = { user_id: authStore.user?.id, ...form }

      if (input.location) {
        // Supabase expects a postgis type for location
        input.location = `POINT(${input.location.lng} ${input.location.lat})`
      }

      const { data, error } = await supabase.from('listings').insert([input]).select().single()

      if (error) {
        throw error
      }

      if (data && data.length > 0) {
        listings.value.unshift(data[0]) // Add new listing to the front
      }

      return data as Listing
    } catch (error) {
      console.error('Error creating listing:', error)
    }
  }

  const updateListing = async (id: string, updates: Partial<Listing>) => {
    try {
      const { data, error } = await supabase
        .from('listings')
        .update(updates)
        .eq('id', id)
        .select()
        .single()

      if (error) {
        throw error
      }

      if (data) {
        const index = listings.value.findIndex(listing => listing.id === id)
        if (index !== -1) {
          listings.value[index] = { ...listings.value[index], ...data }
        }
      }
    } catch (error) {
      console.error('Error updating listing:', error)
    }
  }

  return {
    listings,
    fetchListings,
    fetchSingleListing,
    createListing,
    updateListing,
  }
})
