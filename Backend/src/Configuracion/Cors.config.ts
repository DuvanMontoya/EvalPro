/**
 * @archivo   Cors.config.ts
 * @descripcion Construye la configuración CORS a partir de orígenes definidos en variables de entorno.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { CorsOptions } from '@nestjs/common/interfaces/external/cors-options.interface';
import { ConfigService } from '@nestjs/config';
import { descomponerOrigenesPermitidos } from './Entorno.config';

/**
 * Genera opciones CORS para permitir orígenes habilitados por configuración.
 * @param servicioConfiguracion - Servicio de configuración de NestJS
 * @returns Opciones compatibles con NestJS para CORS.
 */
export function construirConfiguracionCors(servicioConfiguracion: ConfigService): CorsOptions {
  const origenes = descomponerOrigenesPermitidos(
    servicioConfiguracion.getOrThrow<string>('CORS_ORIGENES_PERMITIDOS'),
  );

  return {
    origin: origenes,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  };
}

export function validarOrigenSocket(origen: string | undefined, callback: (error: Error | null, permitir?: boolean) => void): void {
  try {
    const origenes = descomponerOrigenesPermitidos(process.env.CORS_ORIGENES_PERMITIDOS ?? '');
    if (!origen || origenes.includes(origen)) {
      callback(null, true);
      return;
    }

    callback(new Error('Origen no permitido por la política CORS.'));
  } catch (error) {
    callback(error instanceof Error ? error : new Error('Configuración CORS inválida.'));
  }
}
