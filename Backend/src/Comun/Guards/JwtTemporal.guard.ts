import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';
import { RolUsuario } from '@prisma/client';
import { UsuarioAutenticado } from '../Tipos/UsuarioAutenticado.tipo';

const EMISOR_JWT_DEFECTO = 'evalpro-backend';
const AUDIENCIA_JWT_DEFECTO = 'evalpro-cliente';

interface PayloadTemporal {
  sub: string;
  correo: string;
  rol: RolUsuario;
  idInstitucion: string | null;
  scope: string;
}

@Injectable()
export class JwtTemporalGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request & { user?: UsuarioAutenticado }>();
    const authorization = request.headers.authorization ?? '';
    const token = authorization.startsWith('Bearer ') ? authorization.slice(7).trim() : '';

    if (!token) {
      throw new UnauthorizedException('Token temporal no proporcionado');
    }

    try {
      const payload = this.jwtService.verify<PayloadTemporal>(token, {
        secret: this.configService.get<string>('JWT_SECRETO_ACCESO', ''),
        issuer: this.configService.get<string>('JWT_EMISOR', EMISOR_JWT_DEFECTO),
        audience: this.configService.get<string>('JWT_AUDIENCIA', AUDIENCIA_JWT_DEFECTO),
      });

      if (payload.scope !== 'CAMBIO_CONTRASENA_PRIMER_LOGIN') {
        throw new UnauthorizedException('Token temporal inválido');
      }

      request.user = {
        id: payload.sub,
        correo: payload.correo,
        rol: payload.rol,
        idInstitucion: payload.idInstitucion ?? null,
      };
      return true;
    } catch {
      throw new UnauthorizedException('Token temporal inválido');
    }
  }
}
