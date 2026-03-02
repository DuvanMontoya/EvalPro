/**
 * @archivo   vitest.config.ts
 * @descripcion Configura Vitest para pruebas unitarias del frontend con aliases y entorno jsdom.
 * @modulo    Pruebas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { defineConfig } from 'vitest/config';
import path from 'node:path';

export default defineConfig({
  test: {
    include: ['src/**/*.prueba.ts', 'src/**/*.prueba.tsx'],
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/Pruebas/ConfiguracionVitest.ts'],
    clearMocks: true,
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
