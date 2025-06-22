<template>
  <div class="map-container">
    <div ref="map" class="map"></div>
    <div class="controls">
      <button @click="resetView" class="btn btn-secondary">Reset View</button>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted, onBeforeUnmount, useTemplateRef } from 'vue'
  import { debounce } from 'lodash'
  import { Map, View } from 'ol'
  import TileLayer from 'ol/layer/Tile'
  import OSM from 'ol/source/OSM'
  import 'ol/ol.css'
  import { fromLonLat, toLonLat } from 'ol/proj'
  import type { Location, MapView } from '@/types'

  const el = useTemplateRef('map')
  const map = ref<Map | null>(null)

  interface Props {
    center?: Location
    zoom?: number
    minZoom?: number
    maxZoom?: number
  }

  const props = withDefaults(defineProps<Props>(), {
    center: { lat: 34.0522, lng: -118.2437 },
    zoom: 10,
    minZoom: 1,
    maxZoom: 19,
  })

  const emit = defineEmits<{
    (e: 'update:center', center: Location): void
    (e: 'update:zoom', zoom: number): void
    (e: 'view-change', view: MapView): void
  }>()

  const resetView = () => {
    if (map.value) {
      map.value.setView(
        new View({
          center: [props.center.lng, props.center.lat],
          zoom: props.zoom,
        }),
      )
    }
  }

  const onViewChange = debounce((view: View) => {
    const point = view.getCenter()
    const zoom = view.getZoom()

    if (point && zoom !== undefined) {
      const center = toLonLat(point)

      emit('update:center', { lat: center[1], lng: center[0] })
      emit('update:zoom', zoom)
      emit('view-change', { center: { lat: center[1], lng: center[0] }, zoom })
      console.log('Map view changed:', { lat: center[1], lng: center[0] }, zoom)
    }
  }, 250)

  onMounted(() => {
    if (!el.value) {
      console.error('Map element is not available')
      return
    }

    console.log('Initializing map with center:', [props.center.lng, props.center.lat], props.zoom)
    const view = new View({
      center: fromLonLat([props.center.lng, props.center.lat]),
      zoom: props.zoom,
      minZoom: props.minZoom,
      maxZoom: props.maxZoom,
      projection: 'EPSG:3857',
    })

    view.on('change:center', () => onViewChange(view))
    view.on('change:resolution', () => onViewChange(view))
    map.value = new Map({
      target: el.value,
      layers: [
        new TileLayer({
          source: new OSM(),
        }),
      ],
      view,
    })
  })

  onBeforeUnmount(() => {
    if (map.value) {
      map.value.setTarget(undefined)
      map.value = null
    }
  })
</script>

<style scoped>
  .map {
    @apply absolute w-full h-full bg-gray-200;
  }
</style>
