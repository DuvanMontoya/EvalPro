/**
 * @archivo   Intentos.controller.ts
 * @descripcion Controla endpoints del estudiante para iniciar intentos y recibir examen.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Body, Controller, Get, Param, ParseUUIDPipe, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { IniciarIntentoDto } from './Dto/IniciarIntento.dto';
import { IntentosService } from './Intentos.service';

@ApiTags('Intentos')
@ApiBearerAuth()
@Controller('intentos')
@UseGuards(JwtAutenticacionGuard, RolesGuard)
@Roles(RolUsuario.ESTUDIANTE)
export class IntentosController {
  constructor(private readonly intentosService: IntentosService) {}

  /**
   * Inicia un intento de examen para el estudiante autenticado.
   */
  @Post()
  @ApiOperation({ summary: 'Inicia un intento de examen' })
  async iniciar(@Body() dto: IniciarIntentoDto, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.intentosService.iniciar(dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Obtiene el examen asociado al intento sin datos de respuestas correctas.
   */
  @Get(':id/examen')
  @ApiOperation({ summary: 'Obtiene examen para un intento' })
  async obtenerExamen(@Param('id', ParseUUIDPipe) idIntento: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.intentosService.obtenerExamen(idIntento, usuario.id, usuario.idInstitucion);
  }

  /**
   * Anula un intento por decisión del docente propietario de la sesión o administrador.
   */
  @Post(':id/anular')
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Anula un intento por fraude o contingencia' })
  async anular(@Param('id', ParseUUIDPipe) idIntento: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.intentosService.anular(idIntento, usuario.rol, usuario.id, usuario.idInstitucion);
  }
}
