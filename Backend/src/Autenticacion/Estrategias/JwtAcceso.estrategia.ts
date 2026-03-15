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
import { EstadoCuenta, EstadoInstitucion, RolUsuario } from '@prisma/client';
import { ForbiddenException, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../../Configuracion/BaseDatos.config';
import { CODIGOS_ERROR } from '../../Comun/Constantes/Mensajes.constantes';
import { BlacklistTokensService } from '../Servicios/BlacklistTokens.service';
import { UsuarioAutenticado } from '../../Comun/Tipos/UsuarioAutenticado.tipo';

interface PayloadJwt {
  sub: string;
  correo: string;
  rol: RolUsuario;
  idInstitucion: string | null;
  jti?: string;
  exp?: number;
}

@Injectable()
export class JwtAccesoEstrategia extends PassportStrategy(Strategy, 'jwt-acceso') {
  constructor(
    servicioConfiguracion: ConfigService,
    private readonly prisma: PrismaService,
    private readonly blacklistTokensService: BlacklistTokensService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: servicioConfiguracion.getOrThrow<string>('JWT_SECRETO_ACCESO'),
      issuer: servicioConfiguracion.getOrThrow<string>('JWT_EMISOR'),
      audience: servicioConfiguracion.getOrThrow<string>('JWT_AUDIENCIA'),
    });
  }

  /**
   * Mapea el payload JWT a un objeto de usuario actual usado por guards y controladores.
   * @param payload - Payload JWT validado por Passport.
   * @returns Objeto con identificador, correo, rol e institución.
   */
  async validate(payload: PayloadJwt): Promise<UsuarioAutenticado> {
    if (this.blacklistTokensService.estaRevocado(payload.jti)) {
      throw new UnauthorizedException('Token revocado');
    }

    const usuario = await this.prisma.usuario.findUnique({
      where: { id: payload.sub },
      select: {
        id: true,
        correo: true,
        rol: true,
        activo: true,
        idInstitucion: true,
        estadoCuenta: true,
        bloqueadoHasta: true,
        institucion: { select: { estado: true } },
      },
    });

    if (!usuario) {
      throw new UnauthorizedException('Token de acceso inválido');
    }

    if (!usuario.activo) {
      throw new ForbiddenException({ message: 'Usuario inactivo', codigoError: CODIGOS_ERROR.USUARIO_INACTIVO });
    }

    if (usuario.estadoCuenta === EstadoCuenta.SUSPENDIDO) {
      throw new ForbiddenException('Cuenta suspendida');
    }

    if (usuario.estadoCuenta === EstadoCuenta.BLOQUEADO) {
      const bloqueadoHasta = usuario.bloqueadoHasta;
      if (bloqueadoHasta && bloqueadoHasta.getTime() > Date.now()) {
        throw new ForbiddenException('Cuenta bloqueada temporalmente');
      }

      await this.prisma.usuario.update({
        where: { id: usuario.id },
        data: { estadoCuenta: EstadoCuenta.ACTIVO, bloqueadoHasta: null, intentosFallidosLogin: 0 },
      });
    }

    if (usuario.estadoCuenta === EstadoCuenta.PENDIENTE_ACTIVACION) {
      throw new ForbiddenException('Cuenta pendiente de activación');
    }

    if (usuario.rol !== RolUsuario.SUPERADMINISTRADOR) {
      if (!usuario.idInstitucion) {
        throw new ForbiddenException('Usuario sin institución asignada');
      }

      if (!usuario.institucion || usuario.institucion.estado !== EstadoInstitucion.ACTIVA) {
        throw new ForbiddenException('Institución no activa');
      }
    }

    return {
      id: usuario.id,
      correo: usuario.correo,
      rol: usuario.rol,
      idInstitucion: usuario.idInstitucion ?? null,
    };
  }
}
