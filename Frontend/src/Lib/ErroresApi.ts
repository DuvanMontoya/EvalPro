/**
 * @archivo   ErroresApi.ts
 * @descripcion Normaliza errores HTTP/red en una estructura uniforme para toda la interfaz.
 * @modulo    Lib
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import axios, { AxiosError } from 'axios';
import { MENSAJES_ERROR_GENERALES } from '@/Constantes/Api.constantes';
import { RespuestaApi } from '@/Tipos';

const MENSAJES_POR_HTTP: Record<number, string> = {
  401: 'La sesión expiró. Inicia sesión nuevamente.',
  403: MENSAJES_ERROR_GENERALES.SIN_PERMISOS,
  404: 'No se encontró el recurso solicitado.',
  409: 'No se pudo completar la operación por conflicto de estado.',
  422: 'La operación no cumple las validaciones requeridas.',
  500: MENSAJES_ERROR_GENERALES.ERROR_SERVIDOR,
};

interface CuerpoErrorApi {
  mensaje?: string;
  codigoError?: string;
}

export interface ErrorApiNormalizado extends Error {
  estadoHttp?: number;
  codigoError?: string;
  esErrorRed?: boolean;
}

/**
 * Crea una instancia de error uniforme para consumo de componentes y hooks.
 * @param mensaje - Mensaje final a mostrar en UI.
 * @param estadoHttp - Código HTTP asociado, cuando aplica.
 * @param codigoError - Código de negocio retornado por backend.
 * @param esErrorRed - Marca errores de conectividad sin respuesta.
 * @param causa - Error original capturado.
 */
export function crearErrorApiNormalizado(
  mensaje: string,
  estadoHttp?: number,
  codigoError?: string,
  esErrorRed = false,
  causa?: unknown,
): ErrorApiNormalizado {
  const error = new Error(mensaje, { cause: causa }) as ErrorApiNormalizado;
  error.name = 'ErrorApiNormalizado';
  error.estadoHttp = estadoHttp;
  error.codigoError = codigoError;
  error.esErrorRed = esErrorRed;
  return error;
}

function extraerCuerpoError(data: unknown): CuerpoErrorApi {
  if (!data || typeof data !== 'object') {
    return {};
  }

  const candidato = data as Partial<RespuestaApi<unknown>> & CuerpoErrorApi;
  return {
    mensaje: typeof candidato.mensaje === 'string' ? candidato.mensaje : undefined,
    codigoError: typeof candidato.codigoError === 'string' ? candidato.codigoError : undefined,
  };
}

function extraerMensajeAxios(errorAxios: AxiosError<unknown>, mensajeAlterno: string): string {
  const estado = errorAxios.response?.status;
  const cuerpo = extraerCuerpoError(errorAxios.response?.data);
  if (cuerpo.mensaje) {
    return cuerpo.mensaje;
  }

  if (estado && MENSAJES_POR_HTTP[estado]) {
    return MENSAJES_POR_HTTP[estado];
  }

  if (!errorAxios.response) {
    return MENSAJES_ERROR_GENERALES.ERROR_RED;
  }

  return mensajeAlterno;
}

/**
 * Convierte cualquier error desconocido a un error API controlado.
 * @param error - Error original.
 * @param mensajeAlterno - Mensaje de respaldo cuando no existe detalle.
 */
export function normalizarErrorApi(
  error: unknown,
  mensajeAlterno = 'No fue posible completar la operación.',
): ErrorApiNormalizado {
  if (esErrorApiNormalizado(error)) {
    return error;
  }

  if (axios.isAxiosError(error)) {
    const errorAxios = error as AxiosError<unknown>;
    const estado = errorAxios.response?.status;
    const cuerpo = extraerCuerpoError(errorAxios.response?.data);
    const mensaje = extraerMensajeAxios(errorAxios, mensajeAlterno);
    return crearErrorApiNormalizado(mensaje, estado, cuerpo.codigoError, !errorAxios.response, error);
  }

  if (error instanceof Error) {
    return crearErrorApiNormalizado(error.message || mensajeAlterno, undefined, undefined, false, error);
  }

  return crearErrorApiNormalizado(mensajeAlterno);
}

/**
 * Determina si un error ya está normalizado con metadatos HTTP.
 * @param error - Valor a evaluar.
 */
export function esErrorApiNormalizado(error: unknown): error is ErrorApiNormalizado {
  return error instanceof Error && error.name === 'ErrorApiNormalizado';
}

/**
 * Devuelve un mensaje legible para notificación al usuario.
 * @param error - Error capturado.
 * @param mensajeAlterno - Texto de respaldo.
 */
export function obtenerMensajeError(
  error: unknown,
  mensajeAlterno = 'No fue posible completar la operación.',
): string {
  return normalizarErrorApi(error, mensajeAlterno).message;
}
