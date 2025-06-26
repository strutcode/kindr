<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Hero Section -->
    <section class="hero">
      <!-- Background Image -->
      <div class="absolute inset-0">
        <img
          src="https://images.pexels.com/photos/6994869/pexels-photo-6994869.jpeg?auto=compress&cs=tinysrgb&w=1920&h=1080&fit=crop"
          alt="Diverse group of people helping each other in a community"
          class="w-full h-full object-cover object-center"
        />
        <!-- Dark gradient overlay for text legibility -->
        <div class="absolute inset-0 bg-gradient-to-r from-black/65 via-black/50 to-black/30"></div>
        <!-- Additional overlay for better contrast -->
        <div class="absolute inset-0 bg-tertiary-900/30"></div>
      </div>

      <!-- Content -->
      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-32">
        <div class="max-w-4xl">
          <!-- Main heading with enhanced contrast -->
          <h1 class="text-4xl md:text-6xl lg:text-7xl font-bold mb-6 leading-tight drop-shadow-lg">
            Build <span class="text-primary-200">Kindr</span> Communities
          </h1>

          <!-- Subtitle with improved readability -->
          <p
            class="text-xl md:text-2xl lg:text-3xl mb-8 text-white/95 max-w-3xl leading-relaxed drop-shadow-md"
          >
            Connect with your local neighborhood to offer help, share resources, and build stronger
            communities together.
          </p>

          <!-- Call-to-action buttons with enhanced visibility -->
          <div class="flex flex-col sm:flex-row gap-4 justify-start">
            <router-link :to="{ name: 'browse' }">
              <Button
                size="lg"
                class="shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-200"
                >Browse Listings</Button
              >
            </router-link>

            <router-link
              v-if="authStore.isAuthenticated"
              to="/listings/create"
              class="btn btn-outline-white btn-lg shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-200 backdrop-blur-sm"
            >
              <span class="flex items-center">
                <PlusIcon class="w-5 h-5 mr-2" />
                Post Your Own
              </span>
            </router-link>

            <router-link
              v-else
              to="/auth"
              class="btn btn-outline-white btn-lg shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-200 backdrop-blur-sm"
            >
              <span class="flex items-center">
                <UserPlusIcon class="w-5 h-5 mr-2" />
                Join Community
              </span>
            </router-link>
          </div>

          <!-- Trust indicators -->
          <div class="mt-12 flex flex-wrap items-center gap-8 text-white/80">
            <div class="flex items-center space-x-2">
              <div
                class="w-8 h-8 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm"
              >
                <UserGroupIcon class="w-5 h-5" />
              </div>
              <span class="text-sm font-medium">Trusted Community</span>
            </div>
            <div class="flex items-center space-x-2">
              <div
                class="w-8 h-8 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm"
              >
                <ShieldCheckIcon class="w-5 h-5" />
              </div>
              <span class="text-sm font-medium">Verified Members</span>
            </div>
            <div class="flex items-center space-x-2">
              <div
                class="w-8 h-8 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm"
              >
                <HeartIcon class="w-5 h-5" />
              </div>
              <span class="text-sm font-medium">Local Support</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Scroll indicator -->
      <div class="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
        <div class="w-6 h-10 border-2 border-white/50 rounded-full flex justify-center">
          <div class="w-1 h-3 bg-white/70 rounded-full mt-2 animate-pulse"></div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section class="py-20 bg-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">How Kindr Works</h2>
          <p class="text-xl text-gray-600 max-w-2xl mx-auto">
            Simple steps to connect with your community and make a difference
          </p>
        </div>

        <div class="grid md:grid-cols-3 gap-8">
          <div class="text-center group">
            <div
              class="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:bg-primary-200 transition-colors duration-300"
            >
              <UserGroupIcon class="w-8 h-8 text-primary-600" />
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Connect with Others, Anywhere</h3>
            <p class="text-gray-600">
              Explore what others in your community have to offer. Share in communal knowledge,
              effort and assets.
            </p>
          </div>

          <div class="text-center group">
            <div
              class="w-16 h-16 bg-secondary-100 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:bg-secondary-200 transition-colors duration-300"
            >
              <HandRaisedIcon class="w-8 h-8 text-secondary-600" />
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Share what You Have</h3>
            <p class="text-gray-600">
              Find others in your neighborhood who need help, share your skills or give things you
              don't need to those who do.
            </p>
          </div>

          <div class="text-center group">
            <div
              class="w-16 h-16 bg-accent-100 rounded-full flex items-center justify-center mx-auto mb-6 group-hover:bg-accent-200 transition-colors duration-300"
            >
              <HeartIcon class="w-8 h-8 text-accent-600" />
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Build Reputation</h3>
            <p class="text-gray-600">
              Participate in your community and earn trust. The more you help, the more your you
              will get in return.
            </p>
          </div>
        </div>
      </div>
    </section>

    <!-- Categories Section -->
    <section class="py-20 bg-gray-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">Ways to Help</h2>
          <p class="text-xl text-gray-600 max-w-2xl mx-auto">
            Discover the different ways you can contribute to your community
          </p>
        </div>

        <div class="grid md:grid-cols-3 gap-8">
          <div class="bg-white rounded-lg p-8 hover:shadow-lg transition-shadow duration-300 group">
            <div
              class="w-12 h-12 bg-primary-100 rounded-lg flex items-center justify-center mb-6 group-hover:bg-primary-200 transition-colors duration-300"
            >
              <GiftIcon class="w-6 h-6 text-primary-600" />
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Free Stuff</h3>
            <p class="text-gray-600 mb-6">
              Share items you no longer need with neighbors who can use them. From household goods
              to electronics.
            </p>
            <ul class="text-sm text-gray-500 space-y-1">
              <li>• Household items</li>
              <li>• Food & groceries</li>
              <li>• Electronics</li>
              <li>• Books & media</li>
            </ul>
          </div>

          <div class="bg-white rounded-lg p-8 hover:shadow-lg transition-shadow duration-300 group">
            <div
              class="w-12 h-12 bg-secondary-100 rounded-lg flex items-center justify-center mb-6 group-hover:bg-secondary-200 transition-colors duration-300"
            >
              <HandHelpingIcon class="w-6 h-6 text-secondary-600" />
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Help Needed</h3>
            <p class="text-gray-600 mb-6">
              Request assistance with tasks and errands from community members willing to lend a
              hand.
            </p>
            <ul class="text-sm text-gray-500 space-y-1">
              <li>• Transportation</li>
              <li>• Moving & delivery</li>
              <li>• Pet care</li>
              <li>• Shopping & errands</li>
            </ul>
          </div>

          <div class="bg-white rounded-lg p-8 hover:shadow-lg transition-shadow duration-300 group">
            <div
              class="w-12 h-12 bg-accent-100 rounded-lg flex items-center justify-center mb-6 group-hover:bg-accent-200 transition-colors duration-300"
            >
              <AcademicCapIcon class="w-6 h-6 text-accent-600" />
            </div>
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Skills Offered</h3>
            <p class="text-gray-600 mb-6">
              Share your expertise and skills with neighbors who can benefit from your knowledge and
              experience.
            </p>
            <ul class="text-sm text-gray-500 space-y-1">
              <li>• Tutoring & teaching</li>
              <li>• Handyman services</li>
              <li>• Tech support</li>
              <li>• Music lessons</li>
            </ul>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section
      v-if="!authStore.isAuthenticated"
      class="py-20 bg-primary-600 relative overflow-hidden"
    >
      <!-- Background pattern -->
      <div class="absolute inset-0 opacity-10">
        <div
          class="absolute inset-0"
          style="
            background-image: url('data:image/svg+xml,%3Csvg width='60' height='60' viewBox='006060' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.1'%3E%3Ccircle cx='30' cy='30' r='2'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E');
          "
        ></div>
      </div>

      <div class="relative max-w-4xl mx-auto text-center px-4 sm:px-6 lg:px-8">
        <h2 class="text-3xl md:text-4xl font-bold text-white mb-6">Get Started Now</h2>
        <p class="text-xl text-primary-100 mb-8 max-w-2xl mx-auto">
          Join thousands of neighbors already helping each other in their communities.
        </p>
        <router-link
          to="/auth"
          class="btn btn-white btn-lg shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-200"
        >
          <span class="flex items-center">
            Sign Up Today
            <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 5l7 7-7 7"
              ></path>
            </svg>
          </span>
        </router-link>
      </div>
    </section>

    <!-- Authenticated User Dashboard Preview -->
    <section v-else class="py-20 bg-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-12">
          <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">Get Started Now</h2>
          <p class="text-xl text-gray-600 max-w-2xl mx-auto">Ready to help your community today?</p>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          <router-link
            to="/requests/create"
            class="bg-gradient-to-br from-primary-50 to-primary-100 rounded-lg p-6 hover:shadow-lg transition-all duration-300 group border border-primary-200"
          >
            <div class="flex items-center mb-4">
              <div
                class="w-10 h-10 bg-primary-600 rounded-lg flex items-center justify-center mr-4"
              >
                <PlusIcon class="w-6 h-6 text-white" />
              </div>
              <h3 class="text-lg font-semibold text-gray-900">Create Request</h3>
            </div>
            <p class="text-gray-600">
              Post a new request for help, offer items, or share your skills.
            </p>
          </router-link>

          <router-link
            to="/requests"
            class="bg-gradient-to-br from-secondary-50 to-secondary-100 rounded-lg p-6 hover:shadow-lg transition-all duration-300 group border border-secondary-200"
          >
            <div class="flex items-center mb-4">
              <div
                class="w-10 h-10 bg-secondary-600 rounded-lg flex items-center justify-center mr-4"
              >
                <HandRaisedIcon class="w-6 h-6 text-white" />
              </div>
              <h3 class="text-lg font-semibold text-gray-900">Browse Requests</h3>
            </div>
            <p class="text-gray-600">Find ways to help others in your community.</p>
          </router-link>

          <router-link
            to="/profile"
            class="bg-gradient-to-br from-accent-50 to-accent-100 rounded-lg p-6 hover:shadow-lg transition-all duration-300 group border border-accent-200"
          >
            <div class="flex items-center mb-4">
              <div class="w-10 h-10 bg-accent-600 rounded-lg flex items-center justify-center mr-4">
                <UserIcon class="w-6 h-6 text-white" />
              </div>
              <h3 class="text-lg font-semibold text-gray-900">Your Profile</h3>
            </div>
            <p class="text-gray-600">Manage your profile and view your reputation.</p>
          </router-link>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
  import {
    UserGroupIcon,
    HandRaisedIcon,
    HeartIcon,
    GiftIcon,
    AcademicCapIcon,
    PlusIcon,
    ShieldCheckIcon,
    UserPlusIcon,
    UserIcon,
  } from '@heroicons/vue/24/outline'
  import { useAuthStore } from '@/stores/auth'
  import { useUiStore } from '@/stores/ui'
  import Button from '@/components/widgets/Button.vue'
  import { onMounted, onBeforeUnmount } from 'vue'

  // Create a simple hand helping icon component since it's not in Heroicons
  const HandHelpingIcon = UserGroupIcon // Using UserGroupIcon as placeholder

  const authStore = useAuthStore()
  const uiStore = useUiStore()

  const checkHeaderScroll = () => {
    uiStore.header.fade = window.scrollY < 74
  }

  onMounted(() => {
    // Give the header a nice transparent effect on the hero section
    uiStore.header.fade = true
    window.addEventListener('scroll', checkHeaderScroll)
  })

  onBeforeUnmount(() => {
    uiStore.header.fade = false
    window.removeEventListener('scroll', checkHeaderScroll)
  })
</script>

<style scoped>
  .hero {
    @apply relative text-white;
    top: -74px;
  }

  /* Enhanced button hover effects */
  .btn:hover {
    transform: translateY(-1px);
  }
</style>
