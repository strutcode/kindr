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
      name: 'auth',
      component: () => import('@/views/AuthView.vue'),
      meta: { requiresGuest: true },
    },
    {
      path: '/auth/callback',
      name: 'auth_callback',
      component: () => import('@/views/AuthCallbackView.vue'),
    },
    {
      path: '/listings',
      name: 'browse',
      component: () => import('@/views/BrowseView.vue'),
    },
    {
      path: '/listings/create',
      name: 'create',
      component: () => import('@/views/ListingCreateView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/listings/:id',
      name: 'show',
      component: () => import('@/views/ListingShowView.vue'),
    },
    {
      path: '/listings/:id/edit',
      name: 'update',
      component: () => import('@/views/ListingUpdateView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/chats',
      name: 'chats',
      component: () => import('@/views/ChatsView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/chats/:id',
      name: 'chat',
      component: () => import('@/views/ChatsView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/profile',
      name: 'profile',
      component: () => import('@/views/ProfileView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/:pathMatch(.*)*',
      name: '404',
      component: () => import('@/views/NotFoundView.vue'),
    },
  ],
})

/** Checks each route change for required authentication */
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)

  if (requiresAuth && !authStore.isAuthenticated) {
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

    if (!authStore.isAuthenticated) {
      // Store the intended destination for redirect after login
      next({ name: 'auth', query: { redirect: to.fullPath } })
      return
    }
  }

  next()
})

export default router
