<template>
  <div id="app">
    <NavBar />
    <main :class="routeClasses">
      <router-view />
    </main>
  </div>
</template>

<script setup lang="ts">
  import { computed } from 'vue'
  import { useRoute } from 'vue-router'

  import NavBar from '@/components/NavBar.vue'

  const route = useRoute()

  const routeClasses = computed(() => {
    return {
      'overflow-hidden': route.meta.fixedLayout,
    }
  })
</script>

<style scoped>
  #app {
    @apply flex flex-col min-h-screen bg-gray-100;
  }

  main {
    @apply relative flex-1;
  }
</style>
