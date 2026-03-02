/**
 * @archivo   ExcepcionGlobal.filtro.ts
 * @descripcion Convierte excepciones HTTP y no controladas al formato estándar de error de la API.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import { Response } from 'express';
import { CODIGOS_ERROR } from '../Constantes/Mensajes.constantes';

@Catch()
export class ExcepcionGlobalFiltro implements ExceptionFilter {
  /**
   * Intercepta excepciones y envía una respuesta uniforme al cliente.
   * @param excepcion - Error capturado por NestJS.
   * @param host - Contexto de ejecución HTTP.
   */
  catch(excepcion: unknown, host: ArgumentsHost): void {
    const contexto = host.switchToHttp();
    const respuesta = contexto.getResponse<Response>();

    const esHttp = excepcion instanceof HttpException;
    const estado = esHttp ? excepcion.getStatus() : HttpStatus.INTERNAL_SERVER_ERROR;
    const carga = esHttp ? excepcion.getResponse() : null;

    const mensaje = typeof carga === 'object' && carga && 'message' in carga
      ? Array.isArray(carga.message)
        ? String(carga.message.join(', '))
        : String(carga.message)
      : esHttp
        ? excepcion.message
        : 'Error interno del servidor';

    const codigoError = typeof carga === 'object' && carga && 'codigoError' in carga
      ? String(carga.codigoError)
      : this.obtenerCodigoPorEstado(estado);

    respuesta.status(estado).json({
      exito: false,
      datos: null,
      mensaje,
      codigoError,
      marcaTiempo: new Date().toISOString(),
    });
  }

  /**
   * Traduce códigos HTTP al catálogo de códigos de error del sistema.
   * @param estado - Estado HTTP de la respuesta.
   * @returns Código de error estándar en mayúsculas.
   */
  private obtenerCodigoPorEstado(estado: number): string {
    if (estado === HttpStatus.UNAUTHORIZED) {
      return CODIGOS_ERROR.TOKEN_INVALIDO;
    }

    if (estado === HttpStatus.FORBIDDEN) {
      return CODIGOS_ERROR.SIN_PERMISOS;
    }

    if (estado === HttpStatus.NOT_FOUND) {
      return CODIGOS_ERROR.RECURSO_NO_ENCONTRADO;
    }

    if (estado === HttpStatus.BAD_REQUEST) {
      return CODIGOS_ERROR.VALIDACION_FALLIDA;
    }

    return CODIGOS_ERROR.ERROR_INTERNO;
  }
}
