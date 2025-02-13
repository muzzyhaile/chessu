<h1 align="center">
  <img src="./assets/chessu.png" alt="chessu" height="128" />
</h1>

<p align="center">Yet another Chess web app.</p>

<p align="center">
  <img src="./assets/demo.jpg" alt="chessu" width="640" />
</p>

- play against other users in real-time
- spectate and chat in ongoing games with other users
- _optional_ user accounts for tracking stats and game history
- ~~play solo against Stockfish~~ (wip)
- mobile-friendly
- ... and more ([view roadmap](https://github.com/users/dotnize/projects/2))

Built with Next.js 14, Tailwind CSS + daisyUI, react-chessboard, chess.js, Express.js, socket.io and PostgreSQL (via Supabase).

## Development

> Node.js 20 or newer is recommended.

This project is structured as a monorepo using **pnpm** workspaces, separated into three packages:

- `client` - Next.js application for the front-end
- `server` - Node/Express.js application for the back-end
- `types` - Shared type definitions required by the client and server

### Getting started

1. Install [pnpm](https://pnpm.io/installation).
2. Install the necessary dependencies by running `pnpm install` in the root directory of the project.
3. Set up your Supabase project:
   - Create a new project at [Supabase](https://supabase.com)
   - Go to Project Settings -> Database to get your connection info
   - In the `server` directory, create a `.env` file with your Supabase database credentials:
     ```env
     PGHOST=db.[your-project-ref].supabase.co
     PGPORT=5432
     PGDATABASE=postgres
     PGUSER=postgres
     PGPASSWORD=[your-database-password]
     ```
4. Run the development servers with `pnpm dev`.
   - To run the frontend and backend servers separately, use `pnpm dev:client` and `pnpm dev:server`, respectively.
5. You can now access the frontend at http://localhost:3000 and the backend at http://localhost:3001.

## Deployment

### Backend Deployment (Supabase Edge Functions)

1. Install Supabase CLI and login:
   ```sh
   pnpm add -g supabase
   supabase login
   ```

2. Initialize Supabase in your project:
   ```sh
   supabase init
   ```

3. Deploy the server as an Edge Function:
   ```sh
   supabase functions deploy
   ```

4. Get your Edge Function URL from the Supabase Dashboard under Edge Functions.

### Frontend Deployment (Netlify)

1. Push your code to GitHub.

2. Connect your repository to Netlify:
   - Create a new site from Git
   - Choose your repository
   - Set build settings:
     * Base directory: `client`
     * Build command: `pnpm build`
     * Publish directory: `.next`

3. Set environment variables in Netlify:
   ```
   NEXT_PUBLIC_API_URL=https://[your-project-ref].supabase.co/functions/v1
   NEXT_PUBLIC_SOCKET_URL=wss://[your-project-ref].supabase.co/functions/v1
   NODE_VERSION=20
   ```

4. Deploy! Netlify will automatically build and deploy your site.

## Running chessu with Docker

To build the project with Docker, you can use the provided `Dockerfile`.
```sh
docker build -t chessu .
```

This command will build the Docker image with the name `chessu`. You can then run the image with the following command:
```sh
docker run -p 3000:3000 -p 3001:3001 chessu
```

The entrypoint for the Docker image is set to run pnpm.
The Dockerfile's `CMD` instruction is set to run the project in production mode. 
If you want to run the project in development mode, you can override the `CMD` instruction by running the following command:
```sh
docker run -p 3000:3000 -p 3001:3001 chessu dev # runs both client and server in development mode
docker run -p 3000:3000 -p 3001:3001 chessu dev:client # runs only the client in development mode
docker run -p 3000:3000 -p 3001:3001 chessu dev:server # runs only the server in development mode
```

## Contributing

Please read our [Contributing Guidelines](./CONTRIBUTING.md) before starting a pull request.

## License

[MIT](./LICENSE)
