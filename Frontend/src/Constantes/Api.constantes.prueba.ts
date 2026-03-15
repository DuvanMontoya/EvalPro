/**
 * @archivo   Api.constantes.prueba.ts
 * @descripcion Verifica que la configuración pública del frontend funcione sin depender de variables internas en cliente.
 * @modulo    Constantes
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { afterEach, describe, expect, it, vi } from 'vitest';

describe('Api.constantes', () => {
  const entornoOriginal = { ...process.env };

  afterEach(() => {
    process.env = { ...entornoOriginal };
    vi.resetModules();
  });

  it('permite leer variables públicas aunque API_BASE_INTERNA no exista', async () => {
    process.env.NEXT_PUBLIC_API_URL = 'http://127.0.0.1:3101/api/v1';
    process.env.NEXT_PUBLIC_WEBSOCKET_URL = 'http://127.0.0.1:3101';
    process.env.NEXT_PUBLIC_VERSION_APP = '1.0.0';
    delete process.env.API_BASE_INTERNA;

    const { API } = await import('./Api.constantes');

    expect(API.BASE_PUBLICA).toBe('http://127.0.0.1:3101/api/v1');
    expect(API.WEBSOCKET).toBe('http://127.0.0.1:3101');
    expect(API.VERSION).toBe('1.0.0');
  });

  it('exige API_BASE_INTERNA solo cuando una ruta del servidor la necesita', async () => {
    process.env.NEXT_PUBLIC_API_URL = 'http://127.0.0.1:3101/api/v1';
    process.env.NEXT_PUBLIC_WEBSOCKET_URL = 'http://127.0.0.1:3101';
    process.env.NEXT_PUBLIC_VERSION_APP = '1.0.0';
    delete process.env.API_BASE_INTERNA;

    const { API } = await import('./Api.constantes');

    expect(() => API.BASE_INTERNA).toThrow(
      'La variable de entorno API_BASE_INTERNA es obligatoria para el frontend.',
    );
  });
});
