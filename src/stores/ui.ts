import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUiStore = defineStore('ui', () => {
  const header = ref({
    fade: false,
  })

  return {
    header,
  }
})
