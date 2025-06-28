export interface Location {
  lat: number
  lng: number
}

export interface User {
  id: string
  email: string
  full_name?: string
  avatar_url?: string
  phone?: string
  location?: Location
  notification_radius: number
  created_at: string
  updated_at: string
}

export interface Listing {
  id: string
  user_id: string
  title: string
  description: string
  category: RequestCategory
  subcategory: string
  duration_estimate?: DurationEstimate // Made optional since it's only required for help-needed
  skills_required: string[]
  compensation?: string
  images?: string[]
  location: Location
  active: boolean
  created_at: string
  updated_at: string
  expires_at?: string
  user?: {
    id: string
    full_name?: string
    avatar_url?: string
    email?: string
  }
}

export interface ListingFilters {
  search?: string
  category?: '' | RequestCategory
  subcategory?: string
  skills?: string[]
  activeOnly?: boolean // New filter to show only active listings
}

export interface Reputation {
  id: string
  user_id: string
  positive_points: number
  negative_points: number
  total_interactions: number
  created_at: string
  updated_at: string
}

export interface Review {
  id: string
  request_id: string
  reviewer_id: string
  reviewee_id: string
  punctuality: 'no-show' | 'late' | 'on-time'
  helpfulness: 'helpful' | 'unhelpful'
  accuracy: 'as-described' | 'not-as-described'
  additional_feedback?: string
  created_at: string
}

export type RequestCategory = 'free-stuff' | 'help-needed' | 'skills-offered'

export type RequestStatus = 'active' | 'in-progress' | 'completed' | 'cancelled'

export type DurationEstimate = '15min' | '1hour' | '1day' | 'multiple-days'

export interface CategoryOption {
  value: RequestCategory
  label: string
  color: string
  subcategories: SubcategoryOption[]
}

export interface SubcategoryOption {
  value: string
  label: string
}

export interface LocationFilter {
  latitude: number
  longitude: number
  radius: number // in miles
}

export interface AuthState {
  user: User | null
  session: any | null
  loading: boolean
}

export interface RequestFilters {
  category?: RequestCategory
  subcategory?: string
  radius: number
  location?: {
    latitude: number
    longitude: number
  }
  skills?: string[]
}

// Standardized location data interface
export interface LocationData {
  latitude: number
  longitude: number
  city: string
  country: string
  countryCode: string
  timeZone: string
  accuracy?: 'high' | 'medium' | 'low'
  source: 'gps' | 'ip' | 'fallback'
}

// Spatial query types
export interface MapBounds {
  north: number
  south: number
  east: number
  west: number
}

export interface SpatialQueryOptions {
  category?: string
  subcategory?: string
  status?: string
  limit?: number
}

export interface RequestWithDistance extends Request {
  distance_meters?: number
}

export interface MapView {
  center: Location
  zoom: number
}

// Chat-related types
export interface Chat {
  id: string
  listing_id: string
  requester_id: string
  listing_owner_id: string
  last_message_at: string
  requester_unread_count: number
  owner_unread_count: number
  created_at: string
  updated_at: string
  listing?: {
    id: string
    title: string
    category: RequestCategory
  }
  other_user?: {
    id: string
    full_name?: string
    avatar_url?: string
  }
  last_message?: ChatMessage
}

export interface ChatMessage {
  id: string
  chat_id: string
  sender_id: string
  sender_name: string
  sender_avatar_url?: string
  message_type: 'text' | 'image'
  content?: string
  image_url?: string
  created_at: string
}

export interface ChatState {
  chats: Chat[]
  currentChatId: string | null
  messages: Record<string, ChatMessage[]>
  loading: boolean
  hasMore: Record<string, boolean>
  unreadCount: number
}
