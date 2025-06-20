import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    port: 3000, // Default port for development
  },
  plugins: [vue()],
  build: {
    sourcemap: true, // Enable source maps for easier debugging
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
})
