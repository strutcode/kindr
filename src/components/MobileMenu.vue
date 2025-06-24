<template>
  <div>
    <Button variant="outline" size="lg" icon-left="tabler:menu-2" @click="toggleMenu" />
    <Teleport to="body">
      <div
        v-if="menuOpen"
        class="fixed inset-0 bg-gray-800 bg-opacity-50 z-50 flex items-center justify-center"
        @click="toggleMenu"
      >
        <div class="menu">
          <ul class="space-y-2">
            <li>
              <Button variant="outline" @click="$router.push({ name: 'browse' })">Browse</Button>
            </li>
            <li>
              <Button variant="outline" @click="$router.push({ name: 'profile' })">Profile</Button>
            </li>
            <li>
              <Button variant="outline" @click="auth.signOut()">Logout</Button>
            </li>
          </ul>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
  import { ref } from 'vue'

  import { useAuthStore } from '@/stores/auth'

  import Button from './widgets/Button.vue'

  const auth = useAuthStore()

  const menuOpen = ref(false)
  const toggleMenu = () => {
    menuOpen.value = !menuOpen.value
  }
</script>

<style scoped>
  .menu {
    @apply absolute top-0 right-0 z-50;
    @apply w-2/3 h-full bg-white shadow-lg p-4;
  }

  .menu ul {
    @apply space-y-2;
  }

  .menu li {
    @apply w-full;
  }

  .menu li button {
    @apply w-full;
  }
</style>
