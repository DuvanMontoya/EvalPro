/**
 * @archivo   Jwt.config.ts
 * @descripcion Centraliza lectura de secretos y expiraciones JWT desde variables de entorno.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ConfigService } from '@nestjs/config';

export interface ConfiguracionJwt {
  secretoAcceso: string;
  expiracionAcceso: string;
  secretoRefresh: string;
  expiracionRefresh: string;
}

/**
 * Obtiene configuración JWT tipada y validada desde el entorno.
 * @param servicioConfiguracion - Servicio de configuración de NestJS
 * @returns Objeto con secretos y tiempos de expiración.
 */
export function obtenerConfiguracionJwt(servicioConfiguracion: ConfigService): ConfiguracionJwt {
  return {
    secretoAcceso: servicioConfiguracion.get<string>('JWT_SECRETO_ACCESO', ''),
    expiracionAcceso: servicioConfiguracion.get<string>('JWT_EXPIRACION_ACCESO', '15m'),
    secretoRefresh: servicioConfiguracion.get<string>('JWT_SECRETO_REFRESH', ''),
    expiracionRefresh: servicioConfiguracion.get<string>('JWT_EXPIRACION_REFRESH', '7d'),
  };
}
