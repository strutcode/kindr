<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header Section -->
    <section class="bg-white border-b border-gray-200">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div class="text-center">
          <h1 class="text-4xl font-bold text-gray-900 mb-4">Help & Support</h1>
          <p class="text-xl text-gray-600 max-w-2xl mx-auto">
            Everything you need to know about using Kindr to connect with your community
          </p>
        </div>
      </div>
    </section>

    <!-- Quick Links -->
    <section class="py-8 bg-primary-50">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid md:grid-cols-4 gap-4">
          <button
            @click="scrollToSection('getting-started')"
            class="bg-white rounded-lg p-4 text-center hover:shadow-md transition-shadow duration-200"
          >
            <div
              class="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center mx-auto mb-2"
            >
              <PlayIcon class="w-4 h-4 text-primary-600" />
            </div>
            <span class="text-sm font-medium text-gray-900">Getting Started</span>
          </button>
          <button
            @click="scrollToSection('posting')"
            class="bg-white rounded-lg p-4 text-center hover:shadow-md transition-shadow duration-200"
          >
            <div
              class="w-8 h-8 bg-secondary-100 rounded-full flex items-center justify-center mx-auto mb-2"
            >
              <PlusIcon class="w-4 h-4 text-secondary-600" />
            </div>
            <span class="text-sm font-medium text-gray-900">Creating Posts</span>
          </button>
          <button
            @click="scrollToSection('reputation')"
            class="bg-white rounded-lg p-4 text-center hover:shadow-md transition-shadow duration-200"
          >
            <div
              class="w-8 h-8 bg-accent-100 rounded-full flex items-center justify-center mx-auto mb-2"
            >
              <StarIcon class="w-4 h-4 text-accent-600" />
            </div>
            <span class="text-sm font-medium text-gray-900">Reputation</span>
          </button>
          <button
            @click="scrollToSection('safety')"
            class="bg-white rounded-lg p-4 text-center hover:shadow-md transition-shadow duration-200"
          >
            <div
              class="w-8 h-8 bg-tertiary-100 rounded-full flex items-center justify-center mx-auto mb-2"
            >
              <ShieldCheckIcon class="w-4 h-4 text-tertiary-600" />
            </div>
            <span class="text-sm font-medium text-gray-900">Safety</span>
          </button>
        </div>
      </div>
    </section>

    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Getting Started Section -->
      <section id="getting-started" class="mb-16">
        <h2 class="text-3xl font-bold text-gray-900 mb-6">Getting Started</h2>

        <div class="bg-white rounded-lg p-6 shadow-sm border border-gray-200 mb-8">
          <h3 class="text-xl font-semibold text-gray-900 mb-4">Welcome to Kindr!</h3>
          <p class="text-gray-600 mb-4">
            Kindr helps you connect with your local community to offer help, share resources, and
            build stronger neighborhoods together.
          </p>
          <div class="grid md:grid-cols-3 gap-6 mt-6">
            <div class="text-center">
              <div
                class="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center mx-auto mb-3"
              >
                <UserGroupIcon class="w-6 h-6 text-primary-600" />
              </div>
              <h4 class="font-semibold text-gray-900 mb-2">1. Join Your Community</h4>
              <p class="text-sm text-gray-600">
                Sign up and verify your location to start connecting with neighbors.
              </p>
            </div>
            <div class="text-center">
              <div
                class="w-12 h-12 bg-secondary-100 rounded-full flex items-center justify-center mx-auto mb-3"
              >
                <EyeIcon class="w-6 h-6 text-secondary-600" />
              </div>
              <h4 class="font-semibold text-gray-900 mb-2">2. Browse & Explore</h4>
              <p class="text-sm text-gray-600">
                Look at what others are offering or requesting in your area.
              </p>
            </div>
            <div class="text-center">
              <div
                class="w-12 h-12 bg-accent-100 rounded-full flex items-center justify-center mx-auto mb-3"
              >
                <HandRaisedIcon class="w-6 h-6 text-accent-600" />
              </div>
              <h4 class="font-semibold text-gray-900 mb-2">3. Start Helping</h4>
              <p class="text-sm text-gray-600">
                Respond to requests or create your own posts to help others.
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- Creating Posts Section -->
      <section id="posting" class="mb-16">
        <h2 class="text-3xl font-bold text-gray-900 mb-6">Creating Posts</h2>

        <div class="space-y-6">
          <div class="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Types of Posts</h3>
            <div class="grid md:grid-cols-3 gap-6">
              <div>
                <div class="flex items-center mb-3">
                  <GiftIcon class="w-5 h-5 text-primary-600 mr-2" />
                  <h4 class="font-semibold text-gray-900">Free Stuff</h4>
                </div>
                <p class="text-sm text-gray-600 mb-2">Share items you no longer need:</p>
                <ul class="text-xs text-gray-500 space-y-1">
                  <li>• Household items and furniture</li>
                  <li>• Food and groceries</li>
                  <li>• Electronics and gadgets</li>
                  <li>• Books, media, and games</li>
                </ul>
              </div>
              <div>
                <div class="flex items-center mb-3">
                  <HandRaisedIcon class="w-5 h-5 text-secondary-600 mr-2" />
                  <h4 class="font-semibold text-gray-900">Help Needed</h4>
                </div>
                <p class="text-sm text-gray-600 mb-2">Request assistance with tasks:</p>
                <ul class="text-xs text-gray-500 space-y-1">
                  <li>• Transportation and rides</li>
                  <li>• Moving and delivery help</li>
                  <li>• Pet care and walking</li>
                  <li>• Shopping and errands</li>
                </ul>
              </div>
              <div>
                <div class="flex items-center mb-3">
                  <AcademicCapIcon class="w-5 h-5 text-accent-600 mr-2" />
                  <h4 class="font-semibold text-gray-900">Skills Offered</h4>
                </div>
                <p class="text-sm text-gray-600 mb-2">Share your expertise:</p>
                <ul class="text-xs text-gray-500 space-y-1">
                  <li>• Tutoring and teaching</li>
                  <li>• Handyman services</li>
                  <li>• Tech support</li>
                  <li>• Music and art lessons</li>
                </ul>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Writing Good Posts</h3>
            <div class="space-y-4">
              <div class="flex items-start">
                <CheckCircleIcon class="w-5 h-5 text-green-500 mr-3 mt-0.5 flex-shrink-0" />
                <div>
                  <h4 class="font-medium text-gray-900">Be Specific</h4>
                  <p class="text-sm text-gray-600">
                    Include details about what you're offering or need, including size, condition,
                    or time requirements.
                  </p>
                </div>
              </div>
              <div class="flex items-start">
                <CheckCircleIcon class="w-5 h-5 text-green-500 mr-3 mt-0.5 flex-shrink-0" />
                <div>
                  <h4 class="font-medium text-gray-900">Add Photos</h4>
                  <p class="text-sm text-gray-600">
                    Pictures help others understand exactly what you're offering or the help you
                    need.
                  </p>
                </div>
              </div>
              <div class="flex items-start">
                <CheckCircleIcon class="w-5 h-5 text-green-500 mr-3 mt-0.5 flex-shrink-0" />
                <div>
                  <h4 class="font-medium text-gray-900">Set Clear Expectations</h4>
                  <p class="text-sm text-gray-600">
                    Mention timing, location preferences, and any special requirements upfront.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Reputation System Section -->
      <section id="reputation" class="mb-16">
        <h2 class="text-3xl font-bold text-gray-900 mb-6">Reputation System</h2>

        <div class="bg-white rounded-lg p-6 shadow-sm border border-gray-200 mb-6">
          <h3 class="text-xl font-semibold text-gray-900 mb-4">How It Works</h3>
          <p class="text-gray-600 mb-4">
            Kindr uses a reputation system to encourage participation and build trust within the
            community. You earn points by helping others and spend points when receiving help or
            free items.
          </p>

          <div class="grid md:grid-cols-2 gap-6 mt-6">
            <div>
              <h4 class="font-semibold text-green-600 mb-3 flex items-center">
                <ArrowUpIcon class="w-4 h-4 mr-2" />
                Earn Points
              </h4>
              <ul class="space-y-2 text-sm text-gray-600">
                <li class="flex items-center">
                  <div class="w-2 h-2 bg-green-400 rounded-full mr-3"></div>
                  Providing help or services (+10-50 points)
                </li>
                <li class="flex items-center">
                  <div class="w-2 h-2 bg-green-400 rounded-full mr-3"></div>
                  Giving away free items (+5-20 points)
                </li>
                <li class="flex items-center">
                  <div class="w-2 h-2 bg-green-400 rounded-full mr-3"></div>
                  Completing profile and verification (+25 points)
                </li>
                <li class="flex items-center">
                  <div class="w-2 h-2 bg-green-400 rounded-full mr-3"></div>
                  Positive reviews from community members
                </li>
              </ul>
            </div>
            <div>
              <h4 class="font-semibold text-red-600 mb-3 flex items-center">
                <ArrowDownIcon class="w-4 h-4 mr-2" />
                Spend Points
              </h4>
              <ul class="space-y-2 text-sm text-gray-600">
                <li class="flex items-center">
                  <div class="w-2 h-2 bg-red-400 rounded-full mr-3"></div>
                  Receiving help or services (-5-25 points)
                </li>
                <li class="flex items-center">
                  <div class="w-2 h-2 bg-red-400 rounded-full mr-3"></div>
                  Taking free items (-2-10 points)
                </li>
                <li class="flex items-center">
                  <div class="w-2 h-2 bg-red-400 rounded-full mr-3"></div>
                  Creating urgent or high-priority requests
                </li>
              </ul>
            </div>
          </div>
        </div>

        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div class="flex items-start">
            <InformationCircleIcon class="w-5 h-5 text-blue-500 mr-3 mt-0.5 flex-shrink-0" />
            <div>
              <h4 class="font-medium text-blue-900 mb-1">New User Bonus</h4>
              <p class="text-sm text-blue-800">
                New users start with 100 reputation points to help them get started in the
                community!
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- Safety Guidelines Section -->
      <section id="safety" class="mb-16">
        <h2 class="text-3xl font-bold text-gray-900 mb-6">Safety Guidelines</h2>

        <div class="space-y-6">
          <div class="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
            <h3 class="text-xl font-semibold text-gray-900 mb-4">Meeting Safely</h3>
            <div class="grid md:grid-cols-2 gap-6">
              <div>
                <h4 class="font-semibold text-gray-900 mb-3">✅ Do</h4>
                <ul class="space-y-2 text-sm text-gray-600">
                  <li>• Meet in well-lit, public places when possible</li>
                  <li>• Let someone know where you're going</li>
                  <li>• Trust your instincts if something feels off</li>
                  <li>• Check the person's reputation and reviews</li>
                  <li>• Communicate through the app's messaging system</li>
                </ul>
              </div>
              <div>
                <h4 class="font-semibold text-gray-900 mb-3">❌ Don't</h4>
                <ul class="space-y-2 text-sm text-gray-600">
                  <li>• Share personal information like your address immediately</li>
                  <li>• Meet strangers alone in isolated locations</li>
                  <li>• Ignore red flags or concerning behavior</li>
                  <li>• Provide financial information or make payments outside the app</li>
                  <li>• Feel pressured to help if you're uncomfortable</li>
                </ul>
              </div>
            </div>
          </div>

          <div class="bg-red-50 border border-red-200 rounded-lg p-4">
            <div class="flex items-start">
              <ExclamationTriangleIcon class="w-5 h-5 text-red-500 mr-3 mt-0.5 flex-shrink-0" />
              <div>
                <h4 class="font-medium text-red-900 mb-1">Report Suspicious Activity</h4>
                <p class="text-sm text-red-800">
                  If you encounter inappropriate behavior, scams, or feel unsafe, please report it
                  immediately through the app or contact our support team.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- FAQ Section -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold text-gray-900 mb-6">Frequently Asked Questions</h2>

        <div class="space-y-4">
          <div
            v-for="(faq, index) in faqs"
            :key="index"
            class="bg-white rounded-lg shadow-sm border border-gray-200"
          >
            <button
              @click="toggleFaq(index)"
              class="w-full px-6 py-4 text-left flex items-center justify-between hover:bg-gray-50 transition-colors duration-200"
            >
              <h3 class="font-semibold text-gray-900">{{ faq.question }}</h3>
              <ChevronDownIcon
                :class="[
                  'w-5 h-5 text-gray-500 transition-transform duration-200',
                  { 'rotate-180': openFaqs.includes(index) },
                ]"
              />
            </button>
            <div
              v-show="openFaqs.includes(index)"
              class="px-6 pb-4 text-gray-600"
              v-html="faq.answer"
            ></div>
          </div>
        </div>
      </section>

      <!-- Contact Section -->
      <section class="bg-white rounded-lg p-6 shadow-sm border border-gray-200">
        <h2 class="text-2xl font-bold text-gray-900 mb-4">Still Need Help?</h2>
        <p class="text-gray-600 mb-6">
          Can't find what you're looking for? We're here to help! Reach out to our support team.
        </p>
        <div class="flex flex-col sm:flex-row gap-4">
          <Button class="flex items-center justify-center">
            <ChatBubbleLeftRightIcon class="w-4 h-4 mr-2" />
            Start Live Chat
          </Button>
          <Button variant="outline" class="flex items-center justify-center">
            <EnvelopeIcon class="w-4 h-4 mr-2" />
            Send Email
          </Button>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref } from 'vue'
  import {
    PlayIcon,
    PlusIcon,
    StarIcon,
    ShieldCheckIcon,
    UserGroupIcon,
    EyeIcon,
    HandRaisedIcon,
    GiftIcon,
    AcademicCapIcon,
    CheckCircleIcon,
    ArrowUpIcon,
    ArrowDownIcon,
    InformationCircleIcon,
    ExclamationTriangleIcon,
    ChevronDownIcon,
    ChatBubbleLeftRightIcon,
    EnvelopeIcon,
  } from '@heroicons/vue/24/outline'
  import Button from '@/components/widgets/Button.vue'

  const openFaqs = ref<number[]>([])

  const faqs = [
    {
      question: 'How do I get started on Kindr?',
      answer:
        "Simply create an account, verify your location, and start browsing what's available in your community. You'll start with 100 reputation points to help you get involved right away!",
    },
    {
      question: 'Is Kindr free to use?',
      answer:
        'Yes! Kindr is completely free to use. Our goal is to build stronger communities by making it easy for neighbors to help each other.',
    },
    {
      question: 'How does the reputation system work?',
      answer:
        'You earn points by helping others and providing items, and spend points when you receive help or take free items. This encourages a balanced community where everyone contributes.',
    },
    {
      question: "What if I can't fulfill a request I committed to?",
      answer:
        "Life happens! Just communicate as early as possible through the app's messaging system. Honest communication helps maintain trust in the community.",
    },
    {
      question: "Can I see who's asking for help before I commit?",
      answer:
        "Yes, you can view profiles and reputation scores of community members. This helps you make informed decisions about who you'd like to help.",
    },
    {
      question: "What should I do if someone doesn't show up?",
      answer:
        "First, try reaching out through the app's messaging system. If there's no response, you can report the incident which may affect their reputation score.",
    },
    {
      question: 'Are there any restrictions on what I can post?',
      answer:
        "We don't allow illegal items, dangerous materials, or anything that could harm the community. Review our community guidelines for the full list of restrictions.",
    },
    {
      question: 'How far does Kindr reach in my area?',
      answer:
        "You can set your radius from as small as a few blocks to several miles, depending on how far you're willing to travel to help or receive help.",
    },
  ]

  const toggleFaq = (index: number) => {
    if (openFaqs.value.includes(index)) {
      openFaqs.value = openFaqs.value.filter(i => i !== index)
    } else {
      openFaqs.value.push(index)
    }
  }

  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId)
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' })
    }
  }
</script>

<style scoped>
  /* Add any additional styling if needed */
  .rotate-180 {
    transform: rotate(180deg);
  }
</style>
