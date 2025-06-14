import Supercluster from 'supercluster'
import type { RequestWithDistance } from './spatialQueries'

/**
 * Point data for clustering
 */
export interface ClusterPoint {
  type: 'Feature'
  properties: {
    cluster?: boolean
    cluster_id?: number
    point_count?: number
    point_count_abbreviated?: string
    request: RequestWithDistance
  }
  geometry: {
    type: 'Point'
    coordinates: [number, number] // [lng, lat]
  }
}

/**
 * Cluster data returned by Supercluster
 */
export interface ClusterFeature {
  type: 'Feature'
  properties: {
    cluster: boolean
    cluster_id?: number
    point_count?: number
    point_count_abbreviated?: string
    request?: RequestWithDistance
  }
  geometry: {
    type: 'Point'
    coordinates: [number, number] // [lng, lat]
  }
}

/**
 * Cluster configuration options
 */
export interface ClusterOptions {
  /** Minimum zoom level for clustering */
  minZoom: number
  /** Maximum zoom level for clustering */
  maxZoom: number
  /** Cluster radius in pixels */
  radius: number
  /** Maximum number of points in a cluster */
  maxPointsPerCluster: number
  /** Minimum distance between markers in pixels */
  minDistance: number
}

/**
 * Map clustering service using Supercluster
 */
export class MapClusteringService {
  private supercluster: Supercluster
  private points: ClusterPoint[] = []
  private options: ClusterOptions

  constructor(options: Partial<ClusterOptions> = {}) {
    this.options = {
      minZoom: 0,
      maxZoom: 16,
      radius: 60,
      maxPointsPerCluster: 100,
      minDistance: 40,
      ...options
    }

    this.supercluster = new Supercluster({
      radius: this.options.radius,
      maxZoom: this.options.maxZoom,
      minZoom: this.options.minZoom,
      minPoints: 2, // Minimum points to form a cluster
      generateId: true,
    })
  }

  /**
   * Convert requests to cluster points
   */
  private requestsToPoints(requests: RequestWithDistance[]): ClusterPoint[] {
    return requests
      .filter(request => request.location?.latitude && request.location?.longitude)
      .map(request => ({
        type: 'Feature' as const,
        properties: {
          request,
        },
        geometry: {
          type: 'Point' as const,
          coordinates: [request.location.longitude, request.location.latitude]
        }
      }))
  }

  /**
   * Load requests into the clustering engine
   */
  loadRequests(requests: RequestWithDistance[]): void {
    console.log(`Loading ${requests.length} requests into clustering engine`)
    
    this.points = this.requestsToPoints(requests)
    this.supercluster.load(this.points)
    
    console.log(`Loaded ${this.points.length} valid points for clustering`)
  }

  /**
   * Get clusters for a specific zoom level and bounds
   */
  getClusters(
    bounds: [number, number, number, number], // [west, south, east, north]
    zoom: number
  ): ClusterFeature[] {
    if (this.points.length === 0) {
      return []
    }

    try {
      // Ensure zoom is within valid range
      const clampedZoom = Math.max(this.options.minZoom, Math.min(this.options.maxZoom, Math.floor(zoom)))
      
      console.log(`Getting clusters for zoom ${clampedZoom}, bounds:`, bounds)
      
      const clusters = this.supercluster.getClusters(bounds, clampedZoom)
      
      console.log(`Found ${clusters.length} clusters/points at zoom ${clampedZoom}`)
      
      return clusters as ClusterFeature[]
    } catch (error) {
      console.error('Error getting clusters:', error)
      return []
    }
  }

  /**
   * Get all points in a cluster
   */
  getClusterExpansionPoints(clusterId: number): RequestWithDistance[] {
    try {
      const leaves = this.supercluster.getLeaves(clusterId, Infinity)
      return leaves
        .map(leaf => leaf.properties.request)
        .filter(Boolean) as RequestWithDistance[]
    } catch (error) {
      console.error('Error getting cluster expansion points:', error)
      return []
    }
  }

  /**
   * Get the zoom level needed to expand a cluster
   */
  getClusterExpansionZoom(clusterId: number): number {
    try {
      return this.supercluster.getClusterExpansionZoom(clusterId)
    } catch (error) {
      console.error('Error getting cluster expansion zoom:', error)
      return this.options.maxZoom
    }
  }

  /**
   * Check if features should be clustered at current zoom
   */
  shouldCluster(zoom: number): boolean {
    return zoom <= this.options.maxZoom
  }

  /**
   * Get cluster statistics
   */
  getStats(): {
    totalPoints: number
    clustersAtZoom: Record<number, number>
    options: ClusterOptions
  } {
    const clustersAtZoom: Record<number, number> = {}
    
    // Calculate clusters at different zoom levels
    for (let zoom = this.options.minZoom; zoom <= this.options.maxZoom; zoom++) {
      try {
        const bounds: [number, number, number, number] = [-180, -85, 180, 85]
        const clusters = this.supercluster.getClusters(bounds, zoom)
        clustersAtZoom[zoom] = clusters.length
      } catch (error) {
        clustersAtZoom[zoom] = 0
      }
    }

    return {
      totalPoints: this.points.length,
      clustersAtZoom,
      options: this.options
    }
  }

  /**
   * Update clustering options
   */
  updateOptions(newOptions: Partial<ClusterOptions>): void {
    this.options = { ...this.options, ...newOptions }
    
    // Recreate supercluster with new options
    this.supercluster = new Supercluster({
      radius: this.options.radius,
      maxZoom: this.options.maxZoom,
      minZoom: this.options.minZoom,
      minPoints: 2,
      generateId: true,
    })

    // Reload points if we have them
    if (this.points.length > 0) {
      this.supercluster.load(this.points)
    }
  }

  /**
   * Clear all data
   */
  clear(): void {
    this.points = []
    this.supercluster.load([])
  }

  /**
   * Format cluster count for display
   */
  static formatClusterCount(count: number): string {
    if (count < 1000) {
      return count.toString()
    } else if (count < 10000) {
      return `${Math.floor(count / 100) / 10}k`
    } else {
      return `${Math.floor(count / 1000)}k`
    }
  }

  /**
   * Generate cluster marker color based on count
   */
  static getClusterColor(count: number): { background: string; text: string } {
    if (count < 10) {
      return { background: '#0ea5e9', text: '#ffffff' } // Primary blue
    } else if (count < 25) {
      return { background: '#22c55e', text: '#ffffff' } // Green
    } else if (count < 50) {
      return { background: '#f97316', text: '#ffffff' } // Orange
    } else {
      return { background: '#ef4444', text: '#ffffff' } // Red
    }
  }

  /**
   * Calculate cluster marker size based on count
   */
  static getClusterSize(count: number): number {
    if (count < 10) return 40
    if (count < 25) return 50
    if (count < 50) return 60
    return 70
  }
}