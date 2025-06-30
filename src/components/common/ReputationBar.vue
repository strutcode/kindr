<template>
  <div class="space-y-2 w-full">
    <div class="flex items-center justify-between text-sm">
      <span class="text-gray-600">Reputation</span>
    </div>

    <div class="w-full flex space-x-1">
      <div
        v-for="segment in segments"
        :key="segment.index"
        class="flex-1 h-3 rounded-full transition-all duration-300"
        :class="segment.colorClass"
      />
    </div>

    <div class="flex items-center justify-between text-xs text-gray-500">
      <div class="flex items-center space-x-4">
        <div class="flex items-center space-x-1">
          <div class="w-2 h-2 bg-primary-500 rounded-full" />
          <span>positive</span>
        </div>
        <div class="flex items-center space-x-1">
          <div class="w-2 h-2 bg-error-500 rounded-full" />
          <span>negative</span>
        </div>
        <div v-if="reputation.status === 'unknown'" class="flex items-center space-x-1">
          <div class="w-2 h-2 bg-gray-400 rounded-full" />
          <span>Unknown</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed } from 'vue'

  interface Props {
    reputation: {
      status: 'known' | 'unknown'
      positive: number
      negative: number
      total: number
      positivePercentage: number
      negativePercentage: number
      unknownPercentage: number
    }
  }

  const props = defineProps<Props>()

  const segments = computed(() => {
    const segmentArray = []
    const positive = Math.round(props.reputation.positivePercentage / 10)
    const negative = Math.round(props.reputation.negativePercentage / 10)
    const unknown = 10 - positive - negative

    for (let i = 0; i < positive; i++) {
      segmentArray.push({
        index: i,
        colorClass: 'bg-primary-500',
      })
    }
    for (let i = 0; i < negative; i++) {
      segmentArray.push({
        index: i,
        colorClass: 'bg-error-500',
      })
    }
    for (let i = 0; i < unknown; i++) {
      segmentArray.push({
        index: i,
        colorClass: 'bg-gray-400',
      })
    }

    return segmentArray
  })
</script>
