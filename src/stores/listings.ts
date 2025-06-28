import { ref } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import { Listing, ListingFilters, MapBounds } from '@/types'
import { useAuthStore } from './auth'

const formatListing = (entry: any): Listing => {
  return {
    ...entry,
    location: {
      lat: entry.location?.coordinates[1] ?? -47,
      lng: entry.location?.coordinates[0] ?? 168,
    },
    user: {
      id: entry.user?.id ?? '',
      full_name: entry.user?.full_name ?? 'Unknown User',
      avatar_url: entry.user?.avatar_url ?? null,
      email: entry.user?.email ?? '',
    },
  }
}

export const useListingsStore = defineStore('listings', () => {
  const listings = ref<Listing[]>([])
  const userListings = ref<Listing[]>([])

  const fetchListings = async () => {
    try {
      const res = await supabase
        .from('listings')
        .select(`*, user:users!listings_user_id_fkey(id, full_name, avatar_url)`)
        .eq('active', true) // Assuming you want only active listings
        .order('created_at', { ascending: false })

      if (res.error) {
        throw res.error
      }

      listings.value = res.data.map(formatListing)
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
        const listing = formatListing(data)

        listings.value.push(listing) // Add to listings array
        return listing
      }
    } catch (error) {
      console.error('Error fetching single listing:', error)
    }
    return null
  }

  const searchListings = async (query: string): Promise<Listing[]> => {
    try {
      const { data, error } = await supabase
        .from('listings')
        .select('*')
        .textSearch('title_description_tags', query)

      if (error) {
        throw error
      }

      listings.value = data.map(formatListing)

      return listings.value
    } catch (error) {
      console.error('Error searching listings:', error)
      return []
    }
  }

  const fetchUserListings = async (userId: string) => {
    try {
      const { data, error } = await supabase
        .from('listings')
        .select()
        .eq('user_id', userId)
        .order('created_at', { ascending: false })

      if (error) {
        throw error
      }

      userListings.value = data.map(formatListing)
    } catch (error) {
      console.error('Error fetching user listings:', error)
    }
  }

  const deleteListing = async (id: string) => {
    try {
      const { error } = await supabase.from('listings').delete().eq('id', id)

      if (error) {
        throw error
      }
    } catch (error) {
      console.error('Error deleting listing:', error)
    }
  }

  const fetchListingsInBounds = async (bounds: MapBounds, filters?: ListingFilters) => {
    try {
      const { north, south, east, west } = bounds
      const { search, category, subcategory, activeOnly } = filters ?? {}

      const { data, error } = await supabase.rpc('get_listings_in_bounds', {
        north,
        south,
        east,
        west,
        p_search: (search ?? '').trim() || null, // Only pass search if there is a value
        p_category: category || null,
        p_subcategory: (category && subcategory) || null,
        p_active: activeOnly,
        p_limit: 200,
      })

      if (error) {
        throw error
      }

      listings.value = data.map(formatListing)
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

      const { data, error } = await supabase
        .from('listings')
        .insert([input])
        .select(`*, user:users!listings_user_id_fkey(id, full_name, avatar_url)`)
        .single()

      if (error) {
        throw error
      }

      if (!data) {
        throw new Error('No data returned from insert')
      }

      listings.value.unshift(formatListing(data)) // Add new listing to the front
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
        .select(`*, user:users!listings_user_id_fkey(id, full_name, avatar_url)`)
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
    userListings,
    fetchListings,
    fetchSingleListing,
    fetchUserListings,
    fetchListingsInBounds,
    searchListings,
    createListing,
    updateListing,
    deleteListing,
  }
})
