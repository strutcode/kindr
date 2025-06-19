// Valid Supabase Edge Function for cleaning up expired requests
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': '*',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: corsHeaders })
  }

  // Import Supabase client from esm.sh
  const { createClient } = await import('https://esm.sh/@supabase/supabase-js@2')
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

  if (!supabaseUrl || !supabaseServiceKey) {
    return new Response(JSON.stringify({ error: 'Missing environment variables' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', ...corsHeaders },
    })
  }

  const supabase = createClient(supabaseUrl, supabaseServiceKey)

  // Mark requests as inactive if expired
  // (now() at edge is UTC, so compare with created_at + expiry_seconds)
  const { error, count } = await supabase
    .from('requests')
    .update({ is_active: false })
    .match({ is_active: true })
    .lt(
      'expiry_seconds',
      // seconds since created_at
      Math.floor(Date.now() / 1000 - new Date().getTimezoneOffset() * 60),
    )

  if (error) {
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', ...corsHeaders },
    })
  }

  return new Response(JSON.stringify({ success: true, updated: count ?? null }), {
    headers: { 'Content-Type': 'application/json', ...corsHeaders },
  })
})
