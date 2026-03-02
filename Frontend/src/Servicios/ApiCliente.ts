/**
 * @archivo   ApiCliente.ts
 * @descripcion Configura Axios con token en memoria y refresco automático de sesión ante errores 401.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from 'axios';
import { API } from '@/Constantes/Api.constantes';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { RespuestaApi } from '@/Tipos';
import {
  crearErrorApiNormalizado,
  normalizarErrorApi,
} from '@/Lib/ErroresApi';

let tokenAccesoMemoria: string | null = null;
let promesaRefresco: Promise<string | null> | null = null;

interface ConfiguracionConReintento extends InternalAxiosRequestConfig {
  _reintento?: boolean;
}

/**
 * Guarda en memoria el token de acceso para las peticiones del cliente.
 * @param token - JWT de acceso o null para limpiar sesión.
 */
export function establecerTokenAcceso(token: string | null): void {
  tokenAccesoMemoria = token;
}

/**
 * Obtiene el token de acceso almacenado actualmente en memoria.
 * @returns JWT de acceso o null.
 */
export function obtenerTokenAcceso(): string | null {
  return tokenAccesoMemoria;
}

/**
 * Extrae y valida `datos` desde la respuesta estándar del backend.
 * @param respuesta - Respuesta Axios envuelta por el interceptor backend.
 * @returns Datos tipados cuando la respuesta es válida.
 */
export function extraerDatos<T>(respuesta: AxiosResponse<RespuestaApi<T>>): T {
  if (!respuesta.data.exito || respuesta.data.datos === null) {
    throw crearErrorApiNormalizado(
      respuesta.data.mensaje || 'No fue posible completar la operación.',
      respuesta.status,
      respuesta.data.codigoError,
    );
  }

  return respuesta.data.datos;
}

async function intentarRefrescarToken(): Promise<string | null> {
  if (promesaRefresco) {
    return promesaRefresco;
  }

  promesaRefresco = (async () => {
    const respuesta = await fetch('/api/auth/refrescar', {
      method: 'POST',
      credentials: 'include',
    });

    if (!respuesta.ok) {
      return null;
    }

    const datos = (await respuesta.json()) as { tokenAcceso: string };
    establecerTokenAcceso(datos.tokenAcceso);
    return datos.tokenAcceso;
  })();

  try {
    return await promesaRefresco;
  } finally {
    promesaRefresco = null;
  }
}

async function manejarSesionExpirada(): Promise<void> {
  establecerTokenAcceso(null);
  await fetch('/api/auth/sesion', { method: 'DELETE', credentials: 'include' }).catch(() => undefined);

  if (process.env.NODE_ENV === 'test') {
    return;
  }

  if (typeof window !== 'undefined') {
    try {
      window.location.replace(RUTAS.INICIO_SESION);
    } catch {
      window.location.href = RUTAS.INICIO_SESION;
    }
  }
}

export const apiCliente = axios.create({
  baseURL: API.BASE_PUBLICA,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
  },
});

apiCliente.interceptors.request.use((configuracion) => {
  const token = obtenerTokenAcceso();
  if (token) {
    configuracion.headers.Authorization = `Bearer ${token}`;
  }

  return configuracion;
});

apiCliente.interceptors.response.use(
  (respuesta) => respuesta,
  async (error: AxiosError<RespuestaApi<unknown>>) => {
    const configuracionOriginal = error.config as ConfiguracionConReintento | undefined;

    const estado = error.response?.status;
    const esRefresco = configuracionOriginal?.url?.includes(API.AUTENTICACION.REFRESCAR_TOKENS);

    if (estado === 401 && configuracionOriginal && !configuracionOriginal._reintento && !esRefresco) {
      configuracionOriginal._reintento = true;
      const tokenNuevo = await intentarRefrescarToken();
      if (tokenNuevo) {
        configuracionOriginal.headers.Authorization = `Bearer ${tokenNuevo}`;
        return apiCliente(configuracionOriginal);
      }

      await manejarSesionExpirada();
      return Promise.reject(
        crearErrorApiNormalizado('La sesión expiró. Inicia sesión nuevamente.', 401, 'TOKEN_EXPIRADO'),
      );
    }

    return Promise.reject(normalizarErrorApi(error));
  },
);
