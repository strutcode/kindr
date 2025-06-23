import type { CategoryOption } from '@/types'

export const CATEGORIES: CategoryOption[] = [
  {
    value: 'free-stuff',
    label: 'Free Stuff',
    color: '#22c55e',
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
    color: '#0ea5e9',
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
    color: '#f97316',
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
  { value: '15-min', label: '15 minutes' },
  { value: '30-min', label: '15 minutes' },
  { value: '1-hour', label: '1 hour' },
  { value: '2-hours', label: '2 hours' },
  { value: '4-hours', label: '4 hours' },
  { value: '1-day', label: '1 day' },
  { value: 'multiple-days', label: 'Multiple days' },
]

export const RADIUS_OPTIONS = [
  { value: 0.5, label: '0.5 miles' },
  { value: 1, label: '1 mile' },
  { value: 2, label: '2 miles' },
  { value: 5, label: '5 miles' },
  { value: 10, label: '10 miles' },
]

export const EXPIRY_OPTIONS = [
  { label: '1 hour', value: 3600 },
  { label: '2 hours', value: 7200 },
  { label: '4 hours', value: 14400 },
  { label: '8 hours', value: 28800 },
  { label: '12 hours', value: 43200 },
  { label: '1 day', value: 86400 },
  { label: '2 days', value: 172800 },
  { label: '3 days', value: 259200 },
  { label: '5 days', value: 432000 },
  { label: '7 days', value: 604800 },
  { label: '2 weeks', value: 1209600 },
  { label: '3 weeks', value: 1814400 },
  { label: '4 weeks', value: 2419200 },
]
