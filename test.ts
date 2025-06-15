import { createClient } from '@supabase/supabase-js'
import { createLogger } from './src/lib/logger'

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

const { debug } = createLogger('Test')

debug(await supabase.auth.getSession())
