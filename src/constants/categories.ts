import type { CategoryOption } from '@/types'

export const CATEGORIES: CategoryOption[] = [
  {
    value: 'free-stuff',
    label: 'Free Stuff',
    subcategories: [
      { value: 'hygiene', label: 'Hygiene Products' },
      { value: 'food', label: 'Food & Groceries' },
      { value: 'clothing', label: 'Clothing' },
      { value: 'household', label: 'Household Items' },
      { value: 'electronics', label: 'Electronics' },
      { value: 'books', label: 'Books & Media' },
      { value: 'other', label: 'Other' },
    ],
  },
  {
    value: 'help-needed',
    label: 'Help Needed',
    subcategories: [
      { value: 'transportation', label: 'Transportation' },
      { value: 'moving', label: 'Moving & Delivery' },
      { value: 'shopping', label: 'Shopping & Errands' },
      { value: 'pet-care', label: 'Pet Care' },
      { value: 'childcare', label: 'Childcare' },
      { value: 'elderly-care', label: 'Elderly Care' },
      { value: 'cleaning', label: 'Cleaning' },
      { value: 'other', label: 'Other' },
    ],
  },
  {
    value: 'skills-offered',
    label: 'Skills Offered',
    subcategories: [
      { value: 'tutoring', label: 'Tutoring & Teaching' },
      { value: 'handyman', label: 'Handyman Services' },
      { value: 'tech-support', label: 'Tech Support' },
      { value: 'cooking', label: 'Cooking & Baking' },
      { value: 'gardening', label: 'Gardening' },
      { value: 'music', label: 'Music Lessons' },
      { value: 'fitness', label: 'Fitness & Wellness' },
      { value: 'other', label: 'Other' },
    ],
  },
]

export const DURATION_OPTIONS = [
  { value: '15min', label: '15 minutes' },
  { value: '1hour', label: '1 hour' },
  { value: '1day', label: '1 day' },
  { value: 'multiple-days', label: 'Multiple days' },
]

export const RADIUS_OPTIONS = [
  { value: 0.5, label: '0.5 miles' },
  { value: 1, label: '1 mile' },
  { value: 2, label: '2 miles' },
  { value: 5, label: '5 miles' },
  { value: 10, label: '10 miles' },
]