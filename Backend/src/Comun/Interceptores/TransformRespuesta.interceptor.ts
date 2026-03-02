/**
 * @archivo   TransformRespuesta.interceptor.ts
 * @descripcion Envuelve respuestas exitosas en el contrato estándar de salida de la API.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { MENSAJES } from '../Constantes/Mensajes.constantes';

interface RespuestaEstandar<T> {
  exito: boolean;
  datos: T | null;
  mensaje: string;
  marcaTiempo: string;
}

@Injectable()
export class TransformRespuestaInterceptor<T>
  implements NestInterceptor<T, RespuestaEstandar<T>>
{
  /**
   * Convierte la respuesta del controlador al formato unificado del proyecto.
   * @param _contexto - Contexto de ejecución actual.
   * @param siguiente - Flujo de respuesta siguiente.
   * @returns Observable con respuesta transformada.
   */
  intercept(_contexto: ExecutionContext, siguiente: CallHandler<T>): Observable<RespuestaEstandar<T>> {
    return siguiente.handle().pipe(
      map((datos: T) => ({
        exito: true,
        datos,
        mensaje: MENSAJES.OPERACION_EXITOSA,
        marcaTiempo: new Date().toISOString(),
      })),
    );
  }
}
