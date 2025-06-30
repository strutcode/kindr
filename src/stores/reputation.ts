import { defineStore } from 'pinia'
import { ref, computed, readonly } from 'vue'
import { supabase } from '@/lib/supabase'
import type { Reputation, Review } from '@/types'

export const useReputationStore = defineStore('reputation', () => {
  const reputations = ref<Record<string, Reputation>>({})
  const loading = ref(false)

  const getReputationDisplay = (userId: string) => {
    const rep = reputations.value[userId]
    if (!rep) {
      return {
        status: 'unknown' as const,
        positive: 0,
        negative: 0,
        total: 0,
        positivePercentage: 0,
        negativePercentage: 0,
        unknownPercentage: 100,
      }
    }

    const total = rep.positive_points + rep.negative_points

    const positivePercentage = (rep.positive_points / Math.max(total, 10)) * 100
    const negativePercentage = (rep.negative_points / Math.max(total, 10)) * 100
    const unknownPercentage = 100 - (positivePercentage + negativePercentage)

    return {
      status: 'known' as const,
      positive: rep.positive_points,
      negative: rep.negative_points,
      total,
      positivePercentage,
      negativePercentage,
      unknownPercentage,
    }
  }

  const fetchReputation = async (userId: string) => {
    if (reputations.value[userId]) return

    loading.value = true
    try {
      const { data, error } = await supabase
        .from('reputation')
        .select('*')
        .eq('user_id', userId)
        .maybeSingle()

      if (error) {
        throw error
      }

      if (data) {
        reputations.value[userId] = data
      } else {
        // Create initial reputation record
        const { data: newRep, error: createError } = await supabase
          .from('reputation')
          .insert([
            {
              user_id: userId,
              positive_points: 0,
              negative_points: 0,
              total_interactions: 0,
            },
          ])
          .select()
          .single()

        if (createError) throw createError
        reputations.value[userId] = newRep
      }
    } catch (error) {
      console.error('Error fetching reputation:', error)
    } finally {
      loading.value = false
    }
  }

  const submitReview = async (reviewData: Omit<Review, 'id' | 'created_at'>) => {
    loading.value = true
    try {
      // Submit review
      const { data: review, error: reviewError } = await supabase
        .from('reviews')
        .insert([reviewData])
        .select()
        .single()

      if (reviewError) throw reviewError

      // Calculate points based on review
      let positivePoints = 0
      let negativePoints = 0

      // Punctuality scoring
      if (reviewData.punctuality === 'on-time') positivePoints += 5
      else if (reviewData.punctuality === 'late') negativePoints += 3
      else if (reviewData.punctuality === 'no-show') negativePoints += 10

      // Helpfulness scoring
      if (reviewData.helpfulness === 'helpful') positivePoints += 5
      else if (reviewData.helpfulness === 'unhelpful') negativePoints += 3

      // Accuracy scoring
      if (reviewData.accuracy === 'as-described') positivePoints += 5
      else if (reviewData.accuracy === 'not-as-described') negativePoints += 5

      // Update reputation
      const { error: repError } = await supabase.rpc('update_reputation', {
        user_id: reviewData.reviewee_id,
        positive_delta: positivePoints,
        negative_delta: negativePoints,
      })

      if (repError) throw repError

      // Refresh reputation data
      delete reputations.value[reviewData.reviewee_id]
      await fetchReputation(reviewData.reviewee_id)

      return { data: review, error: null }
    } catch (error: any) {
      return { data: null, error: error.message }
    } finally {
      loading.value = false
    }
  }

  return {
    reputations: readonly(reputations),
    loading: readonly(loading),
    getReputationDisplay,
    fetchReputation,
    submitReview,
  }
})
