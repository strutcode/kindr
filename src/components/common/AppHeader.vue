<template>
  <header class="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center h-16">
        <!-- Logo and Navigation -->
        <div class="flex items-center space-x-8">
          <router-link
            to="/"
            class="flex items-center space-x-2 text-primary-600 hover:text-primary-700 transition-colors"
          >
            <!-- Fixed logo sizing -->
            <img class="h-8 w-auto" src="@/assets/logo.svg" alt="Kindr" />
          </router-link>

          <!-- Navigation - Always visible for public browsing -->
          <nav class="hidden md:flex space-x-6">
            <router-link
              to="/requests"
              class="text-gray-600 hover:text-gray-900 font-medium transition-colors"
              active-class="text-primary-600"
            >
              Browse Requests
            </router-link>
            <router-link
              to="/map"
              class="text-gray-600 hover:text-gray-900 font-medium transition-colors"
              active-class="text-primary-600"
            >
              Map View
            </router-link>
          </nav>
        </div>

        <!-- User Menu -->
        <div class="flex items-center space-x-4">
          <!-- Filters Button: Only show on map view -->
          <button
            v-if="$route.path.startsWith('/map')"
            @click="requestsStore.toggleFiltersPopover"
            class="btn btn-outline flex items-center"
            style="margin-right: 0.5rem"
          >
            <svg
              class="w-5 h-5 mr-1"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707l-6.414 6.414A1 1 0 0013 13.414V19a1 1 0 01-1.447.894l-2-1A1 1 0 009 18v-4.586a1 1 0 00-.293-.707L2.293 6.707A1 1 0 012 6V4z"
              />
            </svg>
            Filters
          </button>

          <template v-if="authStore.isAuthenticated">
            <router-link to="/requests/create" class="btn btn-primary">
              <PlusIcon class="w-4 h-4 mr-2" />
              Create Request
            </router-link>

            <div class="relative" ref="userMenuRef">
              <button
                @click="showUserMenu = !showUserMenu"
                class="flex items-center space-x-2 text-gray-600 hover:text-gray-900 transition-colors"
              >
                <div class="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                  <UserIcon class="w-5 h-5" />
                </div>
                <ChevronDownIcon class="w-4 h-4" />
              </button>

              <div
                v-if="showUserMenu"
                class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg border border-gray-200 py-1 z-50"
              >
                <router-link
                  to="/profile"
                  class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
                  @click="showUserMenu = false"
                >
                  Profile
                </router-link>
                <button
                  @click="handleSignOut"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
                >
                  Sign Out
                </button>
              </div>
            </div>
          </template>

          <template v-else>
            <!-- Anonymous user actions -->
            <router-link to="/auth" class="btn btn-outline"> Sign In </router-link>
            <router-link to="/auth" class="btn btn-primary"> Join Community </router-link>
          </template>
        </div>

        <!-- Mobile menu button -->
        <button
          @click="showMobileMenu = !showMobileMenu"
          class="md:hidden p-2 text-gray-600 hover:text-gray-900"
        >
          <Bars3Icon v-if="!showMobileMenu" class="w-6 h-6" />
          <XMarkIcon v-else class="w-6 h-6" />
        </button>
      </div>
    </div>

    <!-- Mobile Navigation Menu -->
    <div v-if="showMobileMenu" class="md:hidden border-t border-gray-200 bg-white">
      <div class="px-4 py-2 space-y-1">
        <router-link
          to="/requests"
          class="block px-3 py-2 text-gray-600 hover:text-gray-900 font-medium transition-colors rounded-md hover:bg-gray-50"
          active-class="text-primary-600 bg-primary-50"
          @click="showMobileMenu = false"
        >
          Browse Requests
        </router-link>
        <router-link
          to="/map"
          class="block px-3 py-2 text-gray-600 hover:text-gray-900 font-medium transition-colors rounded-md hover:bg-gray-50"
          active-class="text-primary-600 bg-primary-50"
          @click="showMobileMenu = false"
        >
          Map View
        </router-link>

        <div v-if="!authStore.isAuthenticated" class="pt-2 border-t border-gray-200 mt-2">
          <router-link
            to="/auth"
            class="block px-3 py-2 text-primary-600 hover:text-primary-700 font-medium transition-colors rounded-md hover:bg-primary-50"
            @click="showMobileMenu = false"
          >
            Sign In / Join
          </router-link>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
  import { ref, onMounted, onUnmounted } from 'vue'
  import { useAuthStore } from '@/stores/auth'
  import { useRouter } from 'vue-router'
  import {
    PlusIcon,
    UserIcon,
    ChevronDownIcon,
    Bars3Icon,
    XMarkIcon,
  } from '@heroicons/vue/24/outline'
  import { useRequestsStore } from '@/stores/requests'

  const authStore = useAuthStore()
  const router = useRouter()
  const showUserMenu = ref(false)
  const showMobileMenu = ref(false)
  const userMenuRef = ref<HTMLElement>()
  const requestsStore = useRequestsStore()

  const handleSignOut = async () => {
    await authStore.signOut()
    showUserMenu.value = false
    router.push('/')
  }

  const handleClickOutside = (event: Event) => {
    if (userMenuRef.value && !userMenuRef.value.contains(event.target as Node)) {
      showUserMenu.value = false
    }
  }

  onMounted(() => {
    document.addEventListener('click', handleClickOutside)
  })

  onUnmounted(() => {
    document.removeEventListener('click', handleClickOutside)
  })
</script>
