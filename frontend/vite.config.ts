import {sveltekit} from '@sveltejs/kit/vite';
import tailwindcss from '@tailwindcss/vite';
import {defineConfig} from 'vitest/config';

export default defineConfig(() => ({
  plugins: [tailwindcss(), sveltekit()],
  server: {
    proxy: {
      '/api': {
        target: 'http://dev:3000',
        changeOrigin: true,
      },
    },
  },
  resolve: {
    conditions: ['browser'],
  },
  test: {
    include: ['test/**/*.{test,spec}.{js,ts,svelte}'],
    globals: true,
    environment: 'jsdom',
    root: '.',
    setupFiles: ['./vitest-setup.ts'],
  },
}));
