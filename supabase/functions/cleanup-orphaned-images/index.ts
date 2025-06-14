const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "*",
};

interface CleanupRequest {
  userId: string;
  validImagePaths: string[];
}

Deno.serve(async (req: Request) => {
  try {
    if (req.method === "OPTIONS") {
      return new Response(null, {
        status: 200,
        headers: corsHeaders,
      });
    }

    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }),
        {
          status: 405,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    }

    // Parse request body
    const { userId, validImagePaths }: CleanupRequest = await req.json();

    if (!userId) {
      return new Response(
        JSON.stringify({ error: "userId is required" }),
        {
          status: 400,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    }

    // Import Supabase client
    const { createClient } = await import('https://esm.sh/@supabase/supabase-js@2');
    
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // List all images for the user
    const { data: files, error: listError } = await supabase.storage
      .from('request-images')
      .list(userId);

    if (listError) {
      console.error('Failed to list user images:', listError);
      return new Response(
        JSON.stringify({ error: 'Failed to list user images' }),
        {
          status: 500,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    }

    // Find orphaned files
    const orphanedPaths = files
      ?.filter(file => !validImagePaths.includes(`${userId}/${file.name}`))
      .map(file => `${userId}/${file.name}`) || [];

    let deletedCount = 0;

    // Delete orphaned files
    if (orphanedPaths.length > 0) {
      const { error: deleteError } = await supabase.storage
        .from('request-images')
        .remove(orphanedPaths);

      if (deleteError) {
        console.error('Failed to delete orphaned images:', deleteError);
        return new Response(
          JSON.stringify({ error: 'Failed to delete orphaned images' }),
          {
            status: 500,
            headers: {
              'Content-Type': 'application/json',
              ...corsHeaders,
            },
          }
        );
      }

      deletedCount = orphanedPaths.length;
    }

    return new Response(
      JSON.stringify({
        success: true,
        deletedCount,
        orphanedPaths,
        message: `Cleaned up ${deletedCount} orphaned images`
      }),
      {
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    );

  } catch (error) {
    console.error('Cleanup function error:', error);
    
    return new Response(
      JSON.stringify({
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error occurred'
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    );
  }
});