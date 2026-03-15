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
import { AutorizarReingresoDto } from './Dto/AutorizarReingreso.dto';
import { ConsumirTokenReingresoDto } from './Dto/ConsumirTokenReingreso.dto';
import { FinalizarProvisionalIntentoDto } from './Dto/FinalizarProvisionalIntento.dto';
import { IniciarIntentoDto } from './Dto/IniciarIntento.dto';
import { ReconciliarIntentoDto } from './Dto/ReconciliarIntento.dto';
import { RegistrarIncidenteIntentoDto } from './Dto/RegistrarIncidenteIntento.dto';
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
   * Registra incidente y aplica la política automática del intento.
   */
  @Post(':id/incidentes')
  @ApiOperation({ summary: 'Registra incidente y bloquea o suspende el intento' })
  async registrarIncidente(
    @Param('id', ParseUUIDPipe) idIntento: string,
    @Body() dto: RegistrarIncidenteIntentoDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.intentosService.registrarIncidente(idIntento, dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Finaliza provisionalmente un intento cuando el cierre se produce offline.
   */
  @Post(':id/finalizar-provisional')
  @ApiOperation({ summary: 'Marca cierre provisional offline del intento' })
  async finalizarProvisional(
    @Param('id', ParseUUIDPipe) idIntento: string,
    @Body() dto: FinalizarProvisionalIntentoDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.intentosService.finalizarProvisional(idIntento, dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Reconciliación posterior de un intento cerrado provisionalmente.
   */
  @Post(':id/reconciliar')
  @ApiOperation({ summary: 'Reconcilia intento provisional con el backend' })
  async reconciliar(
    @Param('id', ParseUUIDPipe) idIntento: string,
    @Body() dto: ReconciliarIntentoDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.intentosService.reconciliar(idIntento, dto, usuario.id, usuario.idInstitucion);
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

  /**
   * Emite un token de reingreso para un intento bloqueado.
   */
  @Post(':id/reingreso/autorizar')
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Genera token de reingreso para un intento bloqueado' })
  async autorizarReingreso(
    @Param('id', ParseUUIDPipe) idIntento: string,
    @Body() dto: AutorizarReingresoDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.intentosService.autorizarReingreso(idIntento, dto, usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Consume un token de reingreso válido y reanuda el intento.
   */
  @Post(':id/reingreso/consumir')
  @ApiOperation({ summary: 'Consume token de reingreso válido y reanuda el intento' })
  async consumirReingreso(
    @Param('id', ParseUUIDPipe) idIntento: string,
    @Body() dto: ConsumirTokenReingresoDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.intentosService.reanudar(idIntento, dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Lista incidentes registrados sobre un intento.
   */
  @Get(':id/incidentes')
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Lista incidentes de un intento' })
  async listarIncidentes(@Param('id', ParseUUIDPipe) idIntento: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.intentosService.listarIncidentes(idIntento, usuario.rol, usuario.id, usuario.idInstitucion);
  }
}
