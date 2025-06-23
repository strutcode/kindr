import { ref } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import { Listing } from '@/types'
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

  const createListing = async (form: Partial<Listing>) => {
    const authStore = useAuthStore()

    try {
      const input = { user_id: authStore.user?.id, ...form }

      const { data, error } = await supabase.from('listings').insert([input]).select().single()

      if (error) {
        throw error
      }

      if (data && data.length > 0) {
        listings.value.unshift(data[0]) // Add new listing to the front
      }
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
    createListing,
    updateListing,
  }
})
