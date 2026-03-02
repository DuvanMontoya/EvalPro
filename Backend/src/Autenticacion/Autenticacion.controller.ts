/**
 * @archivo   Autenticacion.controller.ts
 * @descripcion Expone endpoints de inicio de sesión, refresco de tokens y cierre de sesión.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Body, Controller, HttpCode, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { Request } from 'express';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { JwtRefreshGuard } from '../Comun/Guards/JwtRefresh.guard';
import { JwtTemporalGuard } from '../Comun/Guards/JwtTemporal.guard';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { CambiarContrasenaPrimerLoginDto } from './Dto/CambiarContrasenaPrimerLogin.dto';
import { IniciarSesionDto } from './Dto/IniciarSesion.dto';
import { AutenticacionService } from './Autenticacion.service';

interface SolicitudConRefresh extends Request {
  user: {
    idUsuario: string;
    tokenRefreshRecibido: string;
  };
}

@ApiTags('Autenticacion')
@Controller('autenticacion')
export class AutenticacionController {
  constructor(private readonly autenticacionService: AutenticacionService) {}

  /**
   * Autentica al usuario y emite tokens de acceso y refresh.
   * @param dto - Credenciales de inicio de sesión.
   * @returns Tokens y datos del usuario autenticado.
   */
  @Post('iniciar-sesion')
  @HttpCode(200)
  @Throttle({ default: { limit: 10, ttl: 60_000 * 15 } })
  @ApiOperation({ summary: 'Inicia sesión y devuelve tokens' })
  async iniciarSesion(@Body() dto: IniciarSesionDto, @Req() request: Request): Promise<unknown> {
    return this.autenticacionService.iniciarSesionConCredenciales(dto.correo, dto.contrasena, {
      ip: this.obtenerIp(request),
      userAgent: request.headers['user-agent'] ?? null,
    });
  }

  /**
   * Rota tokens de autenticación a partir de un refresh token válido.
   * @param solicitud - Solicitud con datos extraídos del refresh token validado.
   * @returns Nuevo par de tokens para la sesión.
   */
  @Post('refrescar-tokens')
  @HttpCode(200)
  @UseGuards(JwtRefreshGuard)
  @ApiBearerAuth()
  @Throttle({ default: { limit: 10, ttl: 60_000 * 15 } })
  @ApiOperation({ summary: 'Refresca access token y refresh token' })
  async refrescarTokens(@Req() solicitud: SolicitudConRefresh): Promise<unknown> {
    return this.autenticacionService.refrescarTokens(
      solicitud.user.idUsuario,
      solicitud.user.tokenRefreshRecibido,
      {
        ip: this.obtenerIp(solicitud),
        userAgent: solicitud.headers['user-agent'] ?? null,
      },
    );
  }

  /**
   * Completa activación de cuenta en primer login mediante token temporal.
   */
  @Post('cambiar-contrasena')
  @HttpCode(200)
  @UseGuards(JwtTemporalGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Cambia contraseña en primer login con token temporal' })
  async cambiarContrasenaPrimerLogin(
    @Body() dto: CambiarContrasenaPrimerLoginDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
    @Req() request: Request,
  ): Promise<unknown> {
    return this.autenticacionService.cambiarContrasenaPrimerLogin(usuario.id, dto.nuevaContrasena, {
      ip: this.obtenerIp(request),
      userAgent: request.headers['user-agent'] ?? null,
    });
  }

  /**
   * Cierra sesión invalidando el refresh token persistido del usuario.
   * @param usuario - Usuario autenticado actual.
   * @returns Confirmación de cierre de sesión.
   */
  @Post('cerrar-sesion')
  @HttpCode(200)
  @UseGuards(JwtAutenticacionGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Cierra la sesión actual del usuario' })
  async cerrarSesion(@UsuarioActual() usuario: UsuarioAutenticado, @Req() request: Request) {
    const authorization = request.headers.authorization ?? '';
    const tokenAcceso = authorization.startsWith('Bearer ') ? authorization.slice(7).trim() : null;
    await this.autenticacionService.cerrarSesion(usuario.id, tokenAcceso, {
      ip: this.obtenerIp(request),
      userAgent: request.headers['user-agent'] ?? null,
    });
    return { cerrado: true };
  }

  private obtenerIp(request: Request): string | null {
    const ipEncabezado = request.headers['x-forwarded-for'];
    if (typeof ipEncabezado === 'string' && ipEncabezado.trim().length > 0) {
      return ipEncabezado.split(',')[0].trim();
    }
    return request.ip ?? null;
  }
}
