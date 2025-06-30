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
  import { fromLonLat, toLonLat, transformExtent } from 'ol/proj'
  import type { Listing, Location, MapBounds, MapView } from '@/types'
  import VectorLayer from 'ol/layer/Vector'
  import { Point } from 'ol/geom'
  import { Icon, Style } from 'ol/style'
  import VectorSource from 'ol/source/Vector'

  const mapEl = useTemplateRef('mapEl')
  const map = ref<Map | null>(null)
  const hoveredFeature = ref<Feature | null>(null)

  interface MapPin {
    index: number
    lat: number
    lng: number
    color: string
    listing: Listing
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
    (e: 'bounds-change', view: MapBounds): void
    (e: 'map-click', location: { lat: number; lng: number }): void
    (e: 'pin-click', pin: MapPin): void
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

    if (!point) return
    if (zoom == null) return

    const lonLat = toLonLat(point)
    const center = { lat: lonLat[1], lng: lonLat[0] }

    emit('update:center', center)
    emit('update:zoom', zoom)
    emit('view-change', { center, zoom })
    onBoundsChange(view)
  }, 250)

  const onBoundsChange = (view: View) => {
    const extent = view.calculateExtent()
    const [minX, minY, maxX, maxY] = transformExtent(extent, 'EPSG:3857', 'EPSG:4326')

    const bounds = {
      west: minX,
      south: minY,
      east: maxX,
      north: maxY,
    }

    emit('bounds-change', bounds)
  }

  const pinLayer = new VectorLayer({
    source: new VectorSource(),
    zIndex: 10,
  })

  const createMarkerSVG = (color: string, index: number, isHovered = false): string => {
    const indexed = index != null
    let number = ''

    if (indexed) {
      number = `<text x="16" y="21" text-anchor="middle" font-size="16" fill="${color}" font-family="Arial" font-weight="bold">${index}</text>`
    }

    // Enhanced shadow for hover state
    const shadowOpacity = isHovered ? 0.4 : 0.2
    const shadowBlur = isHovered ? 8 : 4
    const yOffset = isHovered ? -2 : 0

    return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(`
      <svg width="32" height="44" viewBox="-2 -2 34 46" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
            <feDropShadow dx="0" dy="${
              2 + (isHovered ? 2 : 0)
            }" stdDeviation="${shadowBlur}" flood-opacity="${shadowOpacity}"/>
          </filter>
        </defs>
        <g transform="translate(0, ${yOffset})" style="transition: transform 0.2s ease-out;">
          <path d="M16 0C7.163 0 0 7.163 0 16c0 16 16 24 16 24s16-8 16-24C32 7.163 24.837 0 16 0z" 
                fill="${color}" filter="url(#shadow)"/>
          <circle cx="16" cy="16" r="${indexed ? 12 : 6}" fill="white"/>
          ${number}
        </g>
      </svg>
    `)}`
  }

  const createHoverStyle = (color: string, index: number): Style => {
    return new Style({
      image: new Icon({
        src: createMarkerSVG(color, index, true),
        scale: 1.1,
        anchor: [0.5, 1],
      }),
    })
  }

  const createNormalStyle = (color: string, index: number): Style => {
    return new Style({
      image: new Icon({
        src: createMarkerSVG(color, index, false),
        scale: 1,
        anchor: [0.5, 1],
      }),
    })
  }

  const updatePinLayer = () => {
    const source = pinLayer.getSource()

    if (!source) return

    const features = props.pins.map(pin => {
      const feature = new Feature({
        geometry: new Point(fromLonLat([pin.lng, pin.lat])),
        index: pin.index,
        pinData: pin,
      })

      // Store both normal and hover styles
      const normalStyle = createNormalStyle(pin.color, pin.index)
      const hoverStyle = createHoverStyle(pin.color, pin.index)

      feature.setStyle(normalStyle)
      feature.set('normalStyle', normalStyle)
      feature.set('hoverStyle', hoverStyle)

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

    updatePinLayer()

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

    onBoundsChange(view)

    // Add hover effects
    map.value.on('pointermove', event => {
      const featureLike = map.value?.forEachFeatureAtPixel(event.pixel, feature => feature)

      if (featureLike && featureLike.get && featureLike.get('pinData')) {
        // Cast to Feature since we know it's from our vector layer
        const feature = featureLike as Feature

        // Mouse is over a pin
        if (hoveredFeature.value !== feature) {
          // Reset previous hovered feature
          if (hoveredFeature.value) {
            const normalStyle = hoveredFeature.value.get('normalStyle')
            if (normalStyle) {
              hoveredFeature.value.setStyle(normalStyle)
            }
          }

          // Set new hovered feature
          hoveredFeature.value = feature
          const hoverStyle = feature.get('hoverStyle')
          if (hoverStyle) {
            feature.setStyle(hoverStyle)
          }

          // Change cursor to pointer
          if (map.value?.getTarget()) {
            const target = map.value.getTarget() as HTMLElement
            target.style.cursor = 'pointer'
          }
        }
      } else {
        // Mouse is not over a pin
        if (hoveredFeature.value) {
          const normalStyle = hoveredFeature.value.get('normalStyle')
          if (normalStyle) {
            hoveredFeature.value.setStyle(normalStyle)
          }
          hoveredFeature.value = null

          // Reset cursor
          if (map.value?.getTarget()) {
            const target = map.value.getTarget() as HTMLElement
            target.style.cursor = 'default'
          }
        }
      }
    })

    map.value.on('singleclick', event => {
      const coordinate = event.coordinate
      const [lng, lat] = toLonLat(coordinate)

      // Check if a pin was clicked
      const pixelFeature = map.value?.forEachFeatureAtPixel(event.pixel, feature => feature)

      if (pixelFeature && pixelFeature.get && pixelFeature.get('pinData')) {
        // A pin was clicked, emit pin-click event
        const pinData = pixelFeature.get('pinData') as MapPin
        emit('pin-click', pinData)
      } else {
        // No pin was clicked, emit regular map-click event
        emit('map-click', { lat, lng })
      }
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

  /* Add smooth transitions for pin animations */
  :deep(.ol-layer canvas) {
    transition: transform 0.2s ease-out;
  }
</style>
