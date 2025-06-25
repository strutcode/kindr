<template>
  <div>
    <Button variant="outline" size="lg" icon-left="tabler:menu-2" @click="toggleMenu" />
    <Teleport to="body">
      <div
        v-if="menuOpen"
        :class="['overlay', isClosing ? 'animate-fade-out' : 'animate-fade-in']"
        @click="toggleMenu"
      >
        <div
          :class="['menu', isClosing ? 'animate-slide-right' : 'animate-slide-left']"
          @click.stop
        >
          <Button
            variant="outline"
            size="lg"
            icon-left="tabler:x"
            class="float-right mb-4"
            @click="toggleMenu"
          />
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
  const isClosing = ref(false)

  const toggleMenu = () => {
    if (menuOpen.value) {
      // Start closing animation
      isClosing.value = true
      // Remove from DOM after animation completes
      setTimeout(() => {
        menuOpen.value = false
        isClosing.value = false
      }, 235) // Match the animation duration
    } else {
      // Open immediately
      menuOpen.value = true
      isClosing.value = false
    }
  }
</script>

<style scoped>
  .overlay {
    @apply fixed inset-0 bg-gray-800 bg-opacity-50 z-50 flex items-center justify-center;
  }

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
