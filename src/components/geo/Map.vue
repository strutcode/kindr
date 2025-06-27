<template>
  <div class="map-container">
    <div ref="mapEl" class="map"></div>
    <div class="controls">
      <button @click="resetView" class="btn btn-secondary">Reset View</button>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted, onBeforeUnmount, useTemplateRef, watch } from 'vue'
  import { debounce } from 'lodash'
  import { Feature, Map, View } from 'ol'
  import TileLayer from 'ol/layer/Tile'
  import OSM from 'ol/source/OSM'
  import 'ol/ol.css'
  import { fromLonLat, toLonLat } from 'ol/proj'
  import type { Location, MapView } from '@/types'
  import VectorLayer from 'ol/layer/Vector'
  import { Point } from 'ol/geom'
  import { Icon, Style } from 'ol/style'
  import VectorSource from 'ol/source/Vector'

  const mapEl = useTemplateRef('mapEl')
  const map = ref<Map | null>(null)

  interface MapPin {
    index: number
    lat: number
    lng: number
    color: string
  }

  interface Props {
    center?: Location
    zoom?: number
    minZoom?: number
    maxZoom?: number
    pins?: MapPin[]
    disableControls?: boolean
    nonInteractive?: boolean
  }

  const props = withDefaults(defineProps<Props>(), {
    center: () => ({ lat: 34.0522, lng: -118.2437 }),
    zoom: 10,
    minZoom: 1,
    maxZoom: 19,
    pins: () => [],
    disableControls: false,
    nonInteractive: false,
  })

  const emit = defineEmits<{
    (e: 'update:center', center: Location): void
    (e: 'update:zoom', zoom: number): void
    (e: 'view-change', view: MapView): void
    (e: 'map-click', location: { lat: number; lng: number }): void
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
    }
  }, 250)

  const pinLayer = new VectorLayer({
    source: new VectorSource(),
    zIndex: 10,
  })

  const createMarkerSVG = (color: string, index: number): string => {
    const indexed = index != null
    let number = ''

    if (indexed) {
      number = `<text x="16" y="21" text-anchor="middle" font-size="16" fill="${color}" font-family="Arial" font-weight="bold">${index}</text>`
    }

    return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(`
      <svg width="32" height="40" viewBox="0 0 32 40" xmlns="http://www.w3.org/2000/svg">
      <path d="M16 0C7.163 0 0 7.163 0 16c0 16 16 24 16 24s16-8 16-24C32 7.163 24.837 0 16 0z" fill="${color}"/>
      <circle cx="16" cy="16" r="${indexed ? 12 : 6}" fill="white"/>
      ${number}
      </svg>
    `)}`
  }

  const updatePinLayer = () => {
    const source = pinLayer.getSource()

    if (!source) return

    const features = props.pins.map(pin => {
      const feature = new Feature({
        geometry: new Point(fromLonLat([pin.lng, pin.lat])),
        index: pin.index,
      })

      feature.setStyle(
        new Style({
          image: new Icon({
            src: createMarkerSVG(pin.color, pin.index),
            scale: 1,
            anchor: [0.5, 1],
          }),
        }),
      )

      return feature
    })

    source.clear()
    source.addFeatures(features)
  }
  watch(() => props.pins, updatePinLayer)

  watch(
    () => props.center,
    newCenter => {
      if (map.value) {
        const view = map.value.getView()
        view.animate({
          center: fromLonLat([newCenter.lng, newCenter.lat]),
          duration: 500,
        })
      }
    },
  )

  onMounted(() => {
    if (!mapEl.value) {
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

    updatePinLayer(view)

    view.on('change:center', () => onViewChange(view))
    view.on('change:resolution', () => onViewChange(view))
    map.value = new Map({
      target: mapEl.value,
      layers: [
        new TileLayer({
          source: new OSM(),
        }),
        pinLayer,
      ],
      view,
      controls: props.disableControls ? [] : undefined,
      interactions: props.nonInteractive ? [] : undefined,
    })

    map.value.on('singleclick', event => {
      const coordinate = event.coordinate
      const [lng, lat] = toLonLat(coordinate)
      emit('map-click', { lat, lng })
    })
  })

  onBeforeUnmount(() => {
    if (map.value?.setTarget) {
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
