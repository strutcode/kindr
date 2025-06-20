import { createRouter, createWebHistory } from 'vue-router'
import { watchEffect } from 'vue'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'Home',
      component: () => import('@/views/HomeView.vue'),
    },
    {
      path: '/auth',
      name: 'Auth',
      component: () => import('@/views/AuthView.vue'),
      meta: { requiresGuest: true },
    },
    {
      path: '/auth/callback',
      name: 'AuthCallback',
      component: () => import('@/views/AuthCallbackView.vue'),
    },
    {
      path: '/requests',
      name: 'Browse Requests',
      component: () => import('@/views/MapView.vue'),
      // Remove requiresAuth - allow anonymous access
    },
    {
      path: '/requests/create',
      name: 'CreateRequest',
      component: () => import('@/views/CreateRequestView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/requests/:id',
      name: 'RequestDetails',
      component: () => import('@/views/RequestDetailsView.vue'),
      // Remove requiresAuth - allow anonymous access
    },
    {
      path: '/requests/:id/edit',
      name: 'EditRequest',
      component: () => import('@/views/EditRequestView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/profile',
      name: 'Profile',
      component: () => import('@/views/ProfileView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/map',
      name: 'Map',
      component: () => import('@/views/MapView.vue'),
      // Remove requiresAuth - allow anonymous access
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'NotFound',
      component: () => import('@/views/NotFoundView.vue'),
    },
  ],
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  // Wait for auth initialization
  if (authStore.loading) {
    await new Promise(resolve => {
      const unwatch = watchEffect(() => {
        if (!authStore.loading) {
          unwatch()
          resolve(void 0)
        }
      })
    })
  }

  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
  const requiresGuest = to.matched.some(record => record.meta.requiresGuest)

  if (requiresAuth && !authStore.isAuthenticated) {
    // Store the intended destination for redirect after login
    next({ name: 'Auth', query: { redirect: to.fullPath } })
    return
  }

  if (requiresGuest && authStore.isAuthenticated) {
    next({ name: 'Home' })
    return
  }

  next()
})

export default router
