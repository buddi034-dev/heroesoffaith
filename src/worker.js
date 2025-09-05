/**
 * Cloudflare Worker for Heroes of Faith Missionaries API
 * Database-driven API serving missionary profiles, images, and data
 * Now uses D1 database instead of hardcoded arrays for scalability
 */

// CORS headers for cross-origin requests
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

// Error response helper
const errorResponse = (message, status = 400) => {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
};

// Success response helper
const successResponse = (data, status = 200) => {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
};

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Handle CORS preflight requests
    if (request.method === 'OPTIONS') {
      return new Response(null, { 
        status: 200, 
        headers: corsHeaders 
      });
    }

    try {
      // Route: /missionaries - Get all missionaries
      if (url.pathname === '/missionaries' || url.pathname === '/missionaries/') {
        const { searchParams } = url;
        
        // Build query with optional filters
        let query = `
          SELECT m.*, 
                 GROUP_CONCAT(mi.image_url) as all_images,
                 COUNT(bs.id) as biography_sections_count,
                 COUNT(te.id) as timeline_events_count
          FROM missionaries m
          LEFT JOIN missionary_images mi ON m.id = mi.missionary_id
          LEFT JOIN biography_sections bs ON m.id = bs.missionary_id
          LEFT JOIN timeline_events te ON m.id = te.missionary_id
        `;
        
        const conditions = [];
        const params = [];
        
        // Add filters
        if (searchParams.has('century')) {
          conditions.push('m.century = ?');
          params.push(searchParams.get('century'));
        }
        
        if (searchParams.has('search')) {
          conditions.push('(m.name LIKE ? OR m.summary LIKE ?)');
          const searchTerm = `%${searchParams.get('search')}%`;
          params.push(searchTerm, searchTerm);
        }
        
        if (conditions.length > 0) {
          query += ' WHERE ' + conditions.join(' AND ');
        }
        
        query += ' GROUP BY m.id ORDER BY m.birth_year';
        
        const { results } = await env.DB.prepare(query).bind(...params).all();
        
        // Process results to include image arrays
        const missionaries = results.map(m => ({
          ...m,
          images: m.all_images ? m.all_images.split(',') : [],
          all_images: undefined, // Remove the concatenated field
        }));
        
        return successResponse({
          message: 'Heroes of Faith Missionaries',
          count: missionaries.length,
          missionaries
        });
      }

      // Route: /missionaries/{id} - Get specific missionary with full details
      if (url.pathname.startsWith('/missionaries/') && url.pathname !== '/missionaries/') {
        const missionaryId = url.pathname.replace('/missionaries/', '');
        
        // Get missionary basic info
        const missionaryQuery = await env.DB.prepare(
          'SELECT * FROM missionaries WHERE id = ?'
        ).bind(missionaryId).first();
        
        if (!missionaryQuery) {
          return errorResponse('Missionary not found', 404);
        }
        
        // Get biography sections
        const biographyQuery = await env.DB.prepare(
          'SELECT title, content, section_order FROM biography_sections WHERE missionary_id = ? ORDER BY section_order'
        ).bind(missionaryId).all();
        
        // Get timeline events
        const timelineQuery = await env.DB.prepare(
          'SELECT year, title, description, event_type, significance, location FROM timeline_events WHERE missionary_id = ? ORDER BY year'
        ).bind(missionaryId).all();
        
        // Get images
        const imagesQuery = await env.DB.prepare(
          'SELECT image_url, image_type, caption, is_primary FROM missionary_images WHERE missionary_id = ? ORDER BY is_primary DESC'
        ).bind(missionaryId).all();
        
        const missionary = {
          ...missionaryQuery,
          biography: biographyQuery.results || [],
          timeline: timelineQuery.results || [],
          images: imagesQuery.results || [],
        };
        
        return successResponse(missionary);
      }

      // Route: /ai-headshots/{filename} - Redirect to R2 images
      if (url.pathname.startsWith('/ai-headshots/')) {
        const filename = url.pathname.replace('/ai-headshots/', '');
        const r2BaseUrl = 'https://pub-3f7f058fbc1f49f183815380bb719947.r2.dev';
        const imageUrl = `${r2BaseUrl}/${filename}`;
        return Response.redirect(imageUrl, 302);
      }

      // Route: /ai-headshots - List available AI images
      if (url.pathname === '/ai-headshots' || url.pathname === '/ai-headshots/') {
        // Query database for missionaries with AI images
        const { results } = await env.DB.prepare(`
          SELECT m.id, m.name, 
                 CASE 
                   WHEN mi.image_url LIKE '%ai%' THEN mi.image_url
                   ELSE NULL
                 END as ai_image_url
          FROM missionaries m
          LEFT JOIN missionary_images mi ON m.id = mi.missionary_id AND mi.image_url LIKE '%ai%'
          WHERE mi.image_url IS NOT NULL
          ORDER BY m.name
        `).all();
        
        // Fallback to hardcoded list if no AI images in DB yet
        const fallbackImages = [
          'alexander-duff-ai.jpg',
          'amy-carmichael-ai.jpg', 
          'ida-scudder-ai.jpg',
          'james-hudson-taylor-ai.jpg',
          'pandita-ramabai-ai.jpg',
          'william-carey-ai.jpg'
        ];
        
        const imageList = results.length > 0 
          ? results.map(r => r.ai_image_url.split('/').pop())
          : fallbackImages;
        
        return successResponse({
          message: 'AI Enhanced Missionary Images',
          available_images: imageList,
          base_url: 'https://pub-3f7f058fbc1f49f183815380bb719947.r2.dev',
          endpoints: imageList.map(img => `/ai-headshots/${img}`)
        });
      }

      // Route: /stats - Database statistics
      if (url.pathname === '/stats') {
        const missionariesCount = await env.DB.prepare('SELECT COUNT(*) as count FROM missionaries').first();
        const biographyCount = await env.DB.prepare('SELECT COUNT(*) as count FROM biography_sections').first();
        const timelineCount = await env.DB.prepare('SELECT COUNT(*) as count FROM timeline_events').first();
        const imagesCount = await env.DB.prepare('SELECT COUNT(*) as count FROM missionary_images').first();
        
        return successResponse({
          message: 'Heroes of Faith Database Statistics',
          statistics: {
            missionaries: missionariesCount.count,
            biography_sections: biographyCount.count,
            timeline_events: timelineCount.count,
            images: imagesCount.count,
            database_size_mb: '0.15'
          }
        });
      }

      // Default route - API documentation
      return successResponse({
        message: 'Heroes of Faith Missionaries API',
        version: '2.0.0',
        database: 'Cloudflare D1',
        endpoints: {
          '/missionaries': 'Get all missionaries (supports ?century=N, ?search=term)',
          '/missionaries/{id}': 'Get specific missionary with full details',
          '/ai-headshots/': 'List available AI-enhanced images',
          '/ai-headshots/{filename}': 'Get specific AI image (redirects to R2)',
          '/stats': 'Database statistics'
        },
        filters: {
          century: 'Filter by century (e.g., ?century=19)',
          search: 'Search by name or summary (e.g., ?search=India)'
        }
      });

    } catch (error) {
      console.error('Worker error:', error);
      return errorResponse('Internal server error: ' + error.message, 500);
    }
  },
};