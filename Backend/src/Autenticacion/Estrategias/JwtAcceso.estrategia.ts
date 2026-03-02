/**
 * @archivo   JwtAcceso.estrategia.ts
 * @descripcion Valida token de acceso y adjunta datos base del usuario autenticado al request.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { RolUsuario } from '@prisma/client';

interface PayloadJwt {
  sub: string;
  correo: string;
  rol: RolUsuario;
}

@Injectable()
export class JwtAccesoEstrategia extends PassportStrategy(Strategy, 'jwt-acceso') {
  constructor(servicioConfiguracion: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: servicioConfiguracion.get<string>('JWT_SECRETO_ACCESO', ''),
    });
  }

  /**
   * Mapea el payload JWT a un objeto de usuario actual usado por guards y controladores.
   * @param payload - Payload JWT validado por Passport.
   * @returns Objeto con identificador, correo y rol.
   */
  validate(payload: PayloadJwt): { id: string; correo: string; rol: RolUsuario } {
    return {
      id: payload.sub,
      correo: payload.correo,
      rol: payload.rol,
    };
  }
}
