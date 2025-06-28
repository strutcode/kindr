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
              <Button variant="primary" :link="{ name: 'create' }" class="menu-button"
                >Create a Listing</Button
              >
            </li>
            <li>
              <Button variant="outline" :link="{ name: 'browse' }" class="menu-button"
                >Browse</Button
              >
            </li>
            <template v-if="auth.isAuthenticated">
              <li>
                <Button variant="outline" :link="{ name: 'notifications' }" class="menu-button">
                  <div class="flex items-center justify-between w-full">
                    <span>Notifications</span>
                    <span v-if="notificationsStore.unreadCount > 0" class="notification-badge">
                      {{
                        notificationsStore.unreadCount > 99 ? '∞' : notificationsStore.unreadCount
                      }}
                    </span>
                  </div>
                </Button>
              </li>
              <li>
                <Button variant="outline" :link="{ name: 'alerts' }" class="menu-button"
                  >Manage Alerts</Button
                >
              </li>
              <li>
                <Button variant="outline" :link="{ name: 'chats' }" class="menu-button">
                  <div class="flex items-center justify-between w-full">
                    <span>Messages</span>
                    <span v-if="chatStore.unreadCount > 0" class="notification-badge">
                      {{ chatStore.unreadCount > 99 ? '∞' : chatStore.unreadCount }}
                    </span>
                  </div>
                </Button>
              </li>
              <li>
                <Button variant="outline" :link="{ name: 'profile' }" class="menu-button"
                  >Profile</Button
                >
              </li>
              <li>
                <Button variant="outline" @click="auth.signOut()" class="menu-button"
                  >Logout</Button
                >
              </li>
            </template>
            <template v-else>
              <li>
                <Button variant="outline" :link="{ name: 'auth' }" class="menu-button"
                  >Login / Join</Button
                >
              </li>
            </template>
          </ul>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
  import { ref } from 'vue'
  import { useRouter } from 'vue-router'

  import { useAuthStore } from '@/stores/auth'
  import { useChatStore } from '@/stores/chat'
  import { useNotificationsStore } from '@/stores/notifications'

  import Button from './widgets/Button.vue'

  const auth = useAuthStore()
  const chatStore = useChatStore()
  const notificationsStore = useNotificationsStore()
  const router = useRouter()

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
      }, 300) // Match the animation duration
    } else {
      // Open immediately
      menuOpen.value = true
      isClosing.value = false
    }
  }

  router.afterEach(() => {
    menuOpen.value = false
    isClosing.value = false
  })
</script>

<style scoped>
  .overlay {
    @apply fixed inset-0 bg-black bg-opacity-50 z-50 p-4;
  }

  .menu {
    @apply bg-white rounded-lg p-6 w-full max-w-sm ml-auto;
    transform: translateX(100%);
  }

  .menu-button {
    @apply w-full justify-start text-left;
  }

  .notification-badge {
    @apply bg-red-500 text-white text-xs rounded-full px-2 py-1 min-w-[20px] text-center;
    @apply flex items-center justify-center leading-none;
  }

  .animate-fade-in {
    animation: fadeIn 0.3s ease-out forwards;
  }

  .animate-fade-out {
    animation: fadeOut 0.3s ease-out forwards;
  }

  .animate-slide-left {
    animation: slideLeft 0.3s ease-out forwards;
  }

  .animate-slide-right {
    animation: slideRight 0.3s ease-out forwards;
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  @keyframes fadeOut {
    from {
      opacity: 1;
    }
    to {
      opacity: 0;
    }
  }

  @keyframes slideLeft {
    from {
      transform: translateX(100%);
    }
    to {
      transform: translateX(0);
    }
  }

  @keyframes slideRight {
    from {
      transform: translateX(0);
    }
    to {
      transform: translateX(100%);
    }
  }
</style>
