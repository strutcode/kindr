import { CATEGORIES, DURATION_OPTIONS } from '@/constants/categories'
import { formatDistanceToNow } from 'date-fns'

export function useListingFormatting() {
  const getCategoryLabel = (category: string) => {
    return CATEGORIES.find(cat => cat.value === category)?.label || category
  }

  const getSubcategoryLabel = (category: string, subcategory: string) => {
    const cat = CATEGORIES.find(cat => cat.value === category)
    return cat?.subcategories.find(sub => sub.value === subcategory)?.label || subcategory
  }

  const getDurationLabel = (duration: string) => {
    return DURATION_OPTIONS.find(opt => opt.value === duration)?.label || duration
  }

  const formatRelativeTime = (dateString: string | Date) => {
    return formatDistanceToNow(new Date(dateString), { addSuffix: true })
  }

  return {
    getCategoryLabel,
    getSubcategoryLabel,
    getDurationLabel,
    formatRelativeTime,
  }
}
