/**
 * @archivo   RegistroActividad.interceptor.ts
 * @descripcion Registra trazabilidad operativa y auditoría persistente por solicitud HTTP.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { CallHandler, ExecutionContext, Injectable, Logger, NestInterceptor } from '@nestjs/common';
import { Request } from 'express';
import { Observable, tap } from 'rxjs';
import { AuditoriaService } from '../../Auditoria/Auditoria.service';
import { UsuarioAutenticado } from '../Tipos/UsuarioAutenticado.tipo';

type SolicitudAuditable = Request & {
  user?: UsuarioAutenticado;
};

@Injectable()
export class RegistroActividadInterceptor implements NestInterceptor {
  private readonly logger = new Logger(RegistroActividadInterceptor.name);

  constructor(private readonly auditoriaService: AuditoriaService) {}

  /**
   * Registra método, ruta, duración y resultado. Para operaciones mutables persiste auditoría inmutable.
   */
  intercept(contexto: ExecutionContext, siguiente: CallHandler): Observable<unknown> {
    if (contexto.getType<'http' | 'ws' | 'rpc'>() !== 'http') {
      return siguiente.handle();
    }

    const inicio = Date.now();
    const solicitud = contexto.switchToHttp().getRequest<SolicitudAuditable>();
    const metodo = solicitud.method.toUpperCase();
    const ruta = solicitud.originalUrl ?? '';
    const esOperacionMutable = metodo !== 'GET' && metodo !== 'OPTIONS' && metodo !== 'HEAD';

    return siguiente.handle().pipe(
      tap({
        next: (respuesta) => {
          const duracionMilisegundos = Date.now() - inicio;
          this.logger.log(`${metodo} ${ruta} ${duracionMilisegundos}ms`);

          if (!esOperacionMutable) {
            return;
          }

          const actor = solicitud.user;
          void this.auditoriaService.registrar({
            idInstitucion: actor?.idInstitucion ?? null,
            idActor: actor?.id ?? null,
            rolActor: actor?.rol ?? null,
            accion: `HTTP_${metodo}`,
            recurso: ruta,
            idRecurso: this.extraerIdRecursoDesdeRuta(ruta),
            snapshotAntes: null,
            snapshotDespues: this.normalizarSnapshot(respuesta),
            ip: this.obtenerIp(solicitud),
            userAgent: solicitud.headers['user-agent'] ?? null,
            resultado: 'EXITO',
          }).catch(() => undefined);
        },
        error: (error) => {
          const duracionMilisegundos = Date.now() - inicio;
          this.logger.warn(`${metodo} ${ruta} ${duracionMilisegundos}ms FALLA`);

          if (!esOperacionMutable) {
            return;
          }

          const actor = solicitud.user;
          void this.auditoriaService.registrar({
            idInstitucion: actor?.idInstitucion ?? null,
            idActor: actor?.id ?? null,
            rolActor: actor?.rol ?? null,
            accion: `HTTP_${metodo}`,
            recurso: ruta,
            idRecurso: this.extraerIdRecursoDesdeRuta(ruta),
            snapshotAntes: null,
            snapshotDespues: null,
            ip: this.obtenerIp(solicitud),
            userAgent: solicitud.headers['user-agent'] ?? null,
            resultado: 'FALLO',
            razonFallo: error instanceof Error ? error.message : 'Error desconocido',
          }).catch(() => undefined);
        },
      }),
    );
  }

  private extraerIdRecursoDesdeRuta(ruta: string): string | null {
    const segmentos = ruta.split('/').filter((segmento) => segmento.length > 0);
    if (segmentos.length === 0) {
      return null;
    }

    const ultimoSegmento = segmentos[segmentos.length - 1];
    return /^[0-9a-fA-F-]{8,}$/.test(ultimoSegmento) ? ultimoSegmento : null;
  }

  private normalizarSnapshot(respuesta: unknown): Record<string, unknown> | null {
    if (typeof respuesta === 'undefined') {
      return null;
    }
    if (typeof respuesta === 'object' && respuesta !== null) {
      return respuesta as Record<string, unknown>;
    }
    return { valor: respuesta as string | number | boolean | null };
  }

  private obtenerIp(solicitud: SolicitudAuditable): string | null {
    const ipEncabezado = solicitud.headers['x-forwarded-for'];
    if (typeof ipEncabezado === 'string' && ipEncabezado.trim().length > 0) {
      return ipEncabezado.split(',')[0].trim();
    }
    return solicitud.ip ?? null;
  }
}
