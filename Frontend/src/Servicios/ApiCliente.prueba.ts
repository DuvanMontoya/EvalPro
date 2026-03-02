/**
 * @archivo   ApiCliente.prueba.ts
 * @descripcion Verifica refresco automático de token y cierre limpio de sesión en el cliente HTTP.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import MockAdapter from 'axios-mock-adapter';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { apiCliente, establecerTokenAcceso, extraerDatos, obtenerTokenAcceso } from '@/Servicios/ApiCliente';

const MARCA_TIEMPO = '2026-03-02T00:00:00.000Z';

describe('ApiCliente', () => {
  let simuladorAxios: MockAdapter;

  beforeEach(() => {
    simuladorAxios = new MockAdapter(apiCliente);
    establecerTokenAcceso(null);
    vi.restoreAllMocks();
  });

  afterEach(() => {
    simuladorAxios.restore();
    establecerTokenAcceso(null);
  });

  it('reintenta la solicitud tras refrescar token al recibir 401', async () => {
    establecerTokenAcceso('token-viejo');

    simuladorAxios
      .onGet('/recurso-protegido')
      .replyOnce(401, { exito: false, datos: null, mensaje: 'Token expirado', marcaTiempo: MARCA_TIEMPO })
      .onGet('/recurso-protegido')
      .reply((configuracion) => {
        expect(configuracion.headers?.Authorization).toBe('Bearer token-nuevo');
        return [200, { exito: true, datos: { valor: 10 }, mensaje: 'OK', marcaTiempo: MARCA_TIEMPO }];
      });

    vi.stubGlobal(
      'fetch',
      vi.fn(async (url: string) => {
        if (url === '/api/auth/refrescar') {
          return {
            ok: true,
            json: async () => ({ tokenAcceso: 'token-nuevo' }),
          } as Response;
        }

        return { ok: true, json: async () => ({}) } as Response;
      }),
    );

    const respuesta = await apiCliente.get('/recurso-protegido');
    const datos = extraerDatos<{ valor: number }>(respuesta);

    expect(datos.valor).toBe(10);
    expect(obtenerTokenAcceso()).toBe('token-nuevo');
  });

  it('limpia sesión cuando falla el refresh de token', async () => {
    establecerTokenAcceso('token-vencido');

    simuladorAxios
      .onGet('/recurso-falla')
      .reply(401, { exito: false, datos: null, mensaje: 'Token expirado', marcaTiempo: MARCA_TIEMPO });

    vi.stubGlobal(
      'fetch',
      vi.fn(async (url: string) => {
        if (url === '/api/auth/refrescar') {
          return { ok: false } as Response;
        }

        return { ok: true, json: async () => ({}) } as Response;
      }),
    );

    await expect(apiCliente.get('/recurso-falla')).rejects.toThrow('La sesión expiró. Inicia sesión nuevamente.');
    expect(obtenerTokenAcceso()).toBeNull();
  });
});
