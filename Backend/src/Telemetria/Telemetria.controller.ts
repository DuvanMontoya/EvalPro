/**
 * @archivo   Telemetria.controller.ts
 * @descripcion Expone endpoints para registrar y consultar telemetría de intentos.
 * @modulo    Telemetria
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
import { RegistrarEventoDto } from './Dto/RegistrarEvento.dto';
import { TelemetriaService } from './Telemetria.service';

@ApiTags('Telemetria')
@ApiBearerAuth()
@Controller()
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class TelemetriaController {
  constructor(private readonly telemetriaService: TelemetriaService) {}

  /**
   * Registra un evento de telemetría para el intento indicado.
   */
  @Post('telemetria')
  @Roles(RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Registra evento de telemetría' })
  async registrar(@Body() dto: RegistrarEventoDto, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.telemetriaService.registrar(dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Lista eventos de telemetría de un intento.
   */
  @Get('intentos/:idIntento/telemetria')
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Lista telemetría de un intento' })
  async listarPorIntento(@Param('idIntento', ParseUUIDPipe) idIntento: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.telemetriaService.listarPorIntento(idIntento, usuario.rol, usuario.id, usuario.idInstitucion);
  }
}
