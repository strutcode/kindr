<template>
  <div class="space-y-2">
    <div class="flex items-center justify-between text-sm">
      <span class="text-gray-600">Reputation</span>
      <span class="text-gray-500">
        {{ reputation.total }} interactions
      </span>
    </div>
    
    <div class="w-full bg-gray-200 rounded-full h-3 overflow-hidden">
      <div class="h-full flex">
        <!-- Positive section -->
        <div 
          v-if="reputation.positivePercentage > 0"
          class="bg-secondary-500 transition-all duration-300"
          :style="{ width: `${reputation.positivePercentage}%` }"
        />
        
        <!-- Negative section -->
        <div 
          v-if="reputation.negativePercentage > 0"
          class="bg-error-500 transition-all duration-300"
          :style="{ width: `${reputation.negativePercentage}%` }"
        />
        
        <!-- Unknown section -->
        <div 
          v-if="reputation.unknownPercentage > 0"
          class="bg-gray-400 transition-all duration-300"
          :style="{ width: `${reputation.unknownPercentage}%` }"
        />
      </div>
    </div>

    <div class="flex items-center justify-between text-xs text-gray-500">
      <div class="flex items-center space-x-4">
        <div class="flex items-center space-x-1">
          <div class="w-2 h-2 bg-secondary-500 rounded-full" />
          <span>{{ reputation.positive }} positive</span>
        </div>
        <div class="flex items-center space-x-1">
          <div class="w-2 h-2 bg-error-500 rounded-full" />
          <span>{{ reputation.negative }} negative</span>
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

defineProps<Props>()
</script>