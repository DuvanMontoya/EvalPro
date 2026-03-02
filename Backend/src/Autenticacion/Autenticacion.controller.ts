/**
 * @archivo   Autenticacion.controller.ts
 * @descripcion Expone endpoints de inicio de sesión, refresco de tokens y cierre de sesión.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Body, Controller, HttpCode, Post, Req, UnauthorizedException, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { Usuario } from '@prisma/client';
import { Request } from 'express';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { CODIGOS_ERROR } from '../Comun/Constantes/Mensajes.constantes';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { JwtRefreshGuard } from '../Comun/Guards/JwtRefresh.guard';
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
  async iniciarSesion(@Body() dto: IniciarSesionDto): Promise<unknown> {
    const usuario = await this.autenticacionService.validarCredenciales(dto.correo, dto.contrasena);
    if (!usuario) {
      throw new UnauthorizedException({
        message: 'Credenciales inválidas',
        codigoError: CODIGOS_ERROR.CREDENCIALES_INVALIDAS,
      });
    }

    return this.autenticacionService.iniciarSesion(usuario);
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
    );
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
  async cerrarSesion(@UsuarioActual() usuario: Usuario) {
    await this.autenticacionService.cerrarSesion(usuario.id);
    return { cerrado: true };
  }
}
