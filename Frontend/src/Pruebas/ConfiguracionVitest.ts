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

afterEach(() => {
  cleanup();
});
