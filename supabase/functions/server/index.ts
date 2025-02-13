import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { Server } from 'https://deno.land/x/socket_io@0.2.0/mod.ts'
import { corsHeaders } from '../_shared/cors.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_ANON_KEY') ?? ''
)

// Initialize Socket.IO server
const io = new Server({
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
})

// Handle socket connections
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id)

  socket.on('join_game', async (gameId) => {
    socket.join(gameId)
    // Add game join logic here
  })

  socket.on('make_move', async (data) => {
    // Add move logic here
    io.to(data.gameId).emit('move_made', data)
  })

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id)
  })
})

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const url = new URL(req.url)
  const path = url.pathname

  try {
    // WebSocket upgrade
    if (path === '/socket.io/' && req.headers.get('upgrade') === 'websocket') {
      const { socket, response } = Deno.upgradeWebSocket(req)
      io.onConnection(socket)
      return response
    }

    // API Routes
    if (path === '/api/games') {
      if (req.method === 'GET') {
        const { data, error } = await supabase
          .from('games')
          .select('*')
          .order('created_at', { ascending: false })

        if (error) throw error

        return new Response(JSON.stringify(data), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        })
      }

      if (req.method === 'POST') {
        const body = await req.json()
        const { data, error } = await supabase
          .from('games')
          .insert([body])
          .select()

        if (error) throw error

        return new Response(JSON.stringify(data[0]), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        })
      }
    }

    // Default response for unhandled routes
    return new Response(JSON.stringify({ error: 'Not Found' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 404
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500
    })
  }
})
