<template>
  <div id="app">
    <NavBar />
    <main>
      <router-view />
    </main>
  </div>
</template>

<script setup lang="ts">
  import NavBar from '@/components/NavBar.vue'
</script>

<style scoped>
  #app {
    @apply flex flex-col min-h-screen bg-gray-100;
  }

  main {
    @apply relative flex-1;
  }
</style>
