/**
 * @archivo   JwtRefresh.estrategia.ts
 * @descripcion Valida refresh tokens cuando se requiere autenticación por estrategia de renovación.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { Request } from 'express';

interface PayloadRefresh {
  sub: string;
  correo: string;
  rol: string;
}

@Injectable()
export class JwtRefreshEstrategia extends PassportStrategy(Strategy, 'jwt-refresh') {
  constructor(servicioConfiguracion: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: servicioConfiguracion.get<string>('JWT_SECRETO_REFRESH', ''),
      passReqToCallback: true,
    });
  }

  /**
   * Entrega payload de refresh token junto al token recibido para validaciones adicionales.
   * @param solicitud - Solicitud HTTP actual.
   * @param payload - Payload verificado por Passport.
   * @returns Datos requeridos para rotación de tokens.
   */
  validate(solicitud: Request, payload: PayloadRefresh): { idUsuario: string; tokenRefreshRecibido: string } {
    const tokenEncabezado = solicitud.headers.authorization?.replace('Bearer ', '') ?? '';
    return {
      idUsuario: payload.sub,
      tokenRefreshRecibido: tokenEncabezado,
    };
  }
}
