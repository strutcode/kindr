<template>
  <aside class="mapview-requests-sidebar">
    <div class="p-4 border-b flex items-center justify-between">
      <h2 class="text-lg font-semibold">Visible Requests</h2>
      <span v-if="loading" class="text-xs text-gray-400 ml-2">Loading...</span>
    </div>
    <div class="overflow-y-auto h-[calc(100vh-64px)] pr-2">
      <template v-if="clusters && clusters.length">
        <div v-for="(cluster, idx) in clusters" :key="cluster.id" class="mb-6">
          <div class="flex items-center mb-2">
            <span
              class="inline-flex items-center justify-center w-7 h-7 rounded-full bg-primary-600 text-white font-bold mr-2"
              >{{ idx + 1 }}</span
            >
            <span class="font-medium text-gray-700"
              >{{ cluster.requests.length }} request<span v-if="cluster.requests.length > 1"
                >s</span
              >
              in this area</span
            >
          </div>
          <div>
            <template v-for="(request, rIdx) in cluster.requests.slice(0, 3)" :key="request.id">
              <div
                class="request-card-sidebar mb-2 cursor-pointer flex items-start"
                :class="{ 'bg-primary-50': request.id === selectedRequestId }"
                @click="$emit('request-click', request)"
              >
                <!-- Hide number for requests in a group -->
                <span v-if="false" class="request-number">{{ idx + 1 }}</span>
                <div class="flex-1 ml-2">
                  <div class="font-medium text-gray-900">{{ request.title }}</div>
                  <div class="text-xs text-gray-500 truncate">{{ request.description }}</div>
                </div>
              </div>
            </template>
            <button
              v-if="cluster.requests.length > 3"
              class="btn btn-xs btn-outline mt-1"
              @click="$emit('show-more-cluster', cluster.id)"
            >
              Show More ({{ cluster.requests.length - 3 }} more)
            </button>
          </div>
        </div>
      </template>
      <template v-else>
        <div
          v-for="(request, idx) in visibleRequests"
          :key="request.id"
          class="request-card-sidebar mb-2 cursor-pointer flex items-start"
          :class="{ 'bg-primary-50': request.id === selectedRequestId }"
          @click="$emit('request-click', request)"
        >
          <span class="request-number">{{ idx + 1 }}</span>
          <div class="flex-1 ml-2">
            <div class="font-medium text-gray-900">{{ request.title }}</div>
            <div class="text-xs text-gray-500 truncate">{{ request.description }}</div>
          </div>
        </div>
      </template>
      <div v-if="!loading && visibleRequests.length === 0" class="text-center text-gray-400 mt-8">
        No requests found in this area.
      </div>
    </div>
  </aside>
</template>

<script setup lang="ts">
  import { ref, computed, watch, onMounted } from 'vue'
  const props = defineProps({
    requests: { type: Array, required: true },
    clusters: { type: Array, default: () => [] },
    loading: { type: Boolean, default: false },
    selectedRequestId: { type: String, default: '' },
  })
  const emit = defineEmits(['request-click', 'show-more-cluster'])

  // Infinite scroll: only render visible requests
  const pageSize = 20
  const page = ref(1)
  const visibleRequests = computed(() => props.requests.slice(0, page.value * pageSize))

  const handleScroll = (e: Event) => {
    const el = e.target as HTMLElement
    if (el.scrollTop + el.clientHeight >= el.scrollHeight - 40) {
      if (visibleRequests.value.length < props.requests.length) {
        page.value++
      }
    }
  }

  onMounted(() => {
    const sidebar = document.querySelector('.mapview-requests-sidebar .overflow-y-auto')
    if (sidebar) {
      sidebar.addEventListener('scroll', handleScroll)
    }
  })
</script>

<style scoped>
  .mapview-requests-sidebar {
    width: 380px;
    max-width: 100vw;
    height: 100%;
    background: white;
    box-shadow: 2px 0 8px rgba(0, 0, 0, 0.08);
    z-index: 10;
    overflow-y: auto;
    position: relative;
  }
  .request-card-sidebar {
    border-radius: 0.5rem;
    padding: 0.75rem 0.75rem 0.75rem 0.5rem;
    transition: background 0.15s;
  }
  .request-card-sidebar:hover {
    background: #f3f4f6;
  }
  .request-number {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 2rem;
    height: 2rem;
    border-radius: 9999px;
    background: #2563eb;
    color: white;
    font-weight: bold;
    font-size: 1rem;
    flex-shrink: 0;
  }
</style>
