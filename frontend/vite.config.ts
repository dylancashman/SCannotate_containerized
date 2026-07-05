import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  // Served behind a reverse proxy at /app/scannotate/ (see infra/ARCHITECTURE.md) --
  // './' makes built asset URLs relative to the page's own URL instead of
  // root-absolute, so they resolve correctly no matter what subpath this is
  // mounted at. Without this, index.html references /assets/foo.js, which the
  // browser requests from the site root and misses the app entirely.
  base: './',
  plugins: [react()],
})
