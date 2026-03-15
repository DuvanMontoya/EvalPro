/**
 * @archivo   ConfiguracionVitest.ts
 * @descripcion Prepara el entorno de pruebas con utilidades de DOM y limpieza entre casos.
 * @modulo    Pruebas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

process.env.NEXT_PUBLIC_API_URL ??= 'http://pruebas.local/api/v1';
process.env.NEXT_PUBLIC_WEBSOCKET_URL ??= 'http://pruebas.local';
process.env.NEXT_PUBLIC_VERSION_APP ??= '0.0.0-pruebas';
process.env.API_BASE_INTERNA ??= 'http://backend-pruebas.local/api/v1';

afterEach(() => {
  cleanup();
});
