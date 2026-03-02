/**
 * @archivo   Cors.config.ts
 * @descripcion Construye la configuración CORS a partir de orígenes definidos en variables de entorno.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { CorsOptions } from '@nestjs/common/interfaces/external/cors-options.interface';
import { ConfigService } from '@nestjs/config';

/**
 * Genera opciones CORS para permitir orígenes habilitados por configuración.
 * @param servicioConfiguracion - Servicio de configuración de NestJS
 * @returns Opciones compatibles con NestJS para CORS.
 */
export function construirConfiguracionCors(servicioConfiguracion: ConfigService): CorsOptions {
  const origenes = (servicioConfiguracion.get<string>('CORS_ORIGENES_PERMITIDOS', '') ?? '')
    .split(',')
    .map((origen: string) => origen.trim())
    .filter((origen: string) => origen.length > 0);

  return {
    origin: origenes,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  };
}
