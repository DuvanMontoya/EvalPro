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
import { ForbiddenException, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../../Configuracion/BaseDatos.config';
import { CODIGOS_ERROR } from '../../Comun/Constantes/Mensajes.constantes';

const EMISOR_JWT_DEFECTO = 'evalpro-backend';
const AUDIENCIA_JWT_DEFECTO = 'evalpro-cliente';

interface PayloadJwt {
  sub: string;
  correo: string;
  rol: RolUsuario;
}

@Injectable()
export class JwtAccesoEstrategia extends PassportStrategy(Strategy, 'jwt-acceso') {
  constructor(
    servicioConfiguracion: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: servicioConfiguracion.get<string>('JWT_SECRETO_ACCESO', ''),
      issuer: servicioConfiguracion.get<string>('JWT_EMISOR', EMISOR_JWT_DEFECTO),
      audience: servicioConfiguracion.get<string>('JWT_AUDIENCIA', AUDIENCIA_JWT_DEFECTO),
    });
  }

  /**
   * Mapea el payload JWT a un objeto de usuario actual usado por guards y controladores.
   * @param payload - Payload JWT validado por Passport.
   * @returns Objeto con identificador, correo y rol.
   */
  async validate(payload: PayloadJwt): Promise<{ id: string; correo: string; rol: RolUsuario }> {
    const usuario = await this.prisma.usuario.findUnique({
      where: { id: payload.sub },
      select: { id: true, correo: true, rol: true, activo: true },
    });

    if (!usuario) {
      throw new UnauthorizedException('Token de acceso inválido');
    }

    if (!usuario.activo) {
      throw new ForbiddenException({ message: 'Usuario inactivo', codigoError: CODIGOS_ERROR.USUARIO_INACTIVO });
    }

    return {
      id: usuario.id,
      correo: usuario.correo,
      rol: usuario.rol,
    };
  }
}
