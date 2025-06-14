const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "*",
};

interface UserValidationRequest {
  userId: string;
  action: 'create' | 'update' | 'delete' | 'read';
  resourceId?: string;
  resourceType: 'request' | 'review' | 'reputation';
}

interface UserValidationResponse {
  valid: boolean;
  userId: string;
  message?: string;
  permissions: {
    canCreate: boolean;
    canRead: boolean;
    canUpdate: boolean;
    canDelete: boolean;
  };
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

    // Get the authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ 
          error: "Missing authorization header",
          valid: false,
          permissions: {
            canCreate: false,
            canRead: false,
            canUpdate: false,
            canDelete: false,
          }
        }),
        {
          status: 401,
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

    // Verify the JWT token and get user
    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ 
          error: "Invalid authentication token",
          valid: false,
          permissions: {
            canCreate: false,
            canRead: false,
            canUpdate: false,
            canDelete: false,
          }
        }),
        {
          status: 401,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    }

    // Parse request body
    const { userId, action, resourceId, resourceType }: UserValidationRequest = await req.json();

    // Validate that the authenticated user matches the requested userId
    const isValidUser = user.id === userId;

    if (!isValidUser) {
      return new Response(
        JSON.stringify({ 
          error: "User ID mismatch",
          valid: false,
          userId: user.id,
          permissions: {
            canCreate: false,
            canRead: false,
            canUpdate: false,
            canDelete: false,
          }
        }),
        {
          status: 403,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      );
    }

    // Check resource-specific permissions
    let canUpdate = false;
    let canDelete = false;
    let canRead = true; // Generally allow reading
    let canCreate = true; // Generally allow creating

    if (resourceId && (action === 'update' || action === 'delete')) {
      // Check if user owns the resource
      let ownershipQuery;
      
      switch (resourceType) {
        case 'request':
          ownershipQuery = supabase
            .from('requests')
            .select('user_id')
            .eq('id', resourceId)
            .single();
          break;
        case 'review':
          ownershipQuery = supabase
            .from('reviews')
            .select('reviewer_id')
            .eq('id', resourceId)
            .single();
          break;
        case 'reputation':
          ownershipQuery = supabase
            .from('reputation')
            .select('user_id')
            .eq('id', resourceId)
            .single();
          break;
        default:
          throw new Error('Invalid resource type');
      }

      const { data: resourceData, error: resourceError } = await ownershipQuery;

      if (resourceError) {
        return new Response(
          JSON.stringify({ 
            error: "Resource not found",
            valid: false,
            userId: user.id,
            permissions: {
              canCreate,
              canRead: false,
              canUpdate: false,
              canDelete: false,
            }
          }),
          {
            status: 404,
            headers: {
              'Content-Type': 'application/json',
              ...corsHeaders,
            },
          }
        );
      }

      // Check ownership
      const ownerField = resourceType === 'review' ? 'reviewer_id' : 'user_id';
      const isOwner = resourceData[ownerField] === user.id;
      
      canUpdate = isOwner;
      canDelete = isOwner;
    }

    const response: UserValidationResponse = {
      valid: true,
      userId: user.id,
      message: "User validation successful",
      permissions: {
        canCreate,
        canRead,
        canUpdate,
        canDelete,
      }
    };

    return new Response(
      JSON.stringify(response),
      {
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    );

  } catch (error) {
    console.error('User validation error:', error);
    
    return new Response(
      JSON.stringify({
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error occurred',
        valid: false,
        permissions: {
          canCreate: false,
          canRead: false,
          canUpdate: false,
          canDelete: false,
        }
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