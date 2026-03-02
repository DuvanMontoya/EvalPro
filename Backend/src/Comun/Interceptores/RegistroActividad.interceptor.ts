/**
 * @archivo   RegistroActividad.interceptor.ts
 * @descripcion Registra metadatos básicos de cada solicitud para trazabilidad operativa.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { CallHandler, ExecutionContext, Injectable, Logger, NestInterceptor } from '@nestjs/common';
import { Observable, tap } from 'rxjs';

@Injectable()
export class RegistroActividadInterceptor implements NestInterceptor {
  private readonly logger = new Logger(RegistroActividadInterceptor.name);

  /**
   * Registra método, ruta y tiempo total de procesamiento de cada petición.
   * @param contexto - Contexto HTTP de la solicitud.
   * @param siguiente - Flujo de ejecución siguiente.
   * @returns Observable con respuesta original.
   */
  intercept(contexto: ExecutionContext, siguiente: CallHandler): Observable<unknown> {
    const inicio = Date.now();
    const solicitud = contexto.switchToHttp().getRequest<{ method: string; originalUrl: string }>();

    return siguiente.handle().pipe(
      tap(() => {
        const duracionMilisegundos = Date.now() - inicio;
        this.logger.log(`${solicitud.method} ${solicitud.originalUrl} ${duracionMilisegundos}ms`);
      }),
    );
  }
}
