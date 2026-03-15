/**
 * @archivo   JwtRefresh.estrategia.ts
 * @descripcion Valida refresh tokens cuando se requiere autenticación por estrategia de renovación.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Injectable, UnauthorizedException } from '@nestjs/common';
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
      jwtFromRequest: ExtractJwt.fromExtractors([
        ExtractJwt.fromAuthHeaderAsBearerToken(),
        (solicitud: Request): string | null =>
          typeof solicitud.body?.tokenRefresh === 'string' ? solicitud.body.tokenRefresh : null,
      ]),
      ignoreExpiration: false,
      secretOrKey: servicioConfiguracion.getOrThrow<string>('JWT_SECRETO_REFRESH'),
      issuer: servicioConfiguracion.getOrThrow<string>('JWT_EMISOR'),
      audience: servicioConfiguracion.getOrThrow<string>('JWT_AUDIENCIA'),
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
    const tokenEncabezado = solicitud.headers.authorization?.replace('Bearer ', '')?.trim() ?? '';
    const tokenBody = typeof solicitud.body?.tokenRefresh === 'string' ? solicitud.body.tokenRefresh : '';
    const tokenRecibido = tokenEncabezado || tokenBody;
    if (!tokenRecibido) {
      throw new UnauthorizedException('Refresh token no proporcionado');
    }

    return {
      idUsuario: payload.sub,
      tokenRefreshRecibido: tokenRecibido,
    };
  }
}
