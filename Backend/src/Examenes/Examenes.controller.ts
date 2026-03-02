/**
 * @archivo   Examenes.controller.ts
 * @descripcion Publica endpoints CRUD de exámenes con control de rol y propiedad.
 * @modulo    Examenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Body, Controller, Delete, Get, Param, ParseUUIDPipe, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { CrearExamenDto } from './Dto/CrearExamen.dto';
import { ActualizarExamenDto } from './Dto/ActualizarExamen.dto';
import { ExamenesService } from './Examenes.service';

@ApiTags('Examenes')
@ApiBearerAuth()
@Controller('examenes')
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class ExamenesController {
  constructor(private readonly examenesService: ExamenesService) {}

  /**
   * Lista exámenes visibles para el usuario autenticado.
   */
  @Get()
  @Roles(RolUsuario.SUPERADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Lista exámenes por rol' })
  async listar(@UsuarioActual() usuario: UsuarioAutenticado) {
    return this.examenesService.listar(usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Crea un examen para el docente autenticado.
   */
  @Post()
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Crea un examen en estado borrador' })
  async crear(@Body() dto: CrearExamenDto, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.examenesService.crear(dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Obtiene detalle de un examen por identificador.
   */
  @Get(':id')
  @Roles(RolUsuario.SUPERADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Obtiene examen por id' })
  async obtenerPorId(@Param('id', ParseUUIDPipe) id: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.examenesService.obtenerPorId(id, usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Actualiza un examen en borrador propiedad del docente.
   */
  @Patch(':id')
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Actualiza examen en estado borrador' })
  async actualizar(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ActualizarExamenDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.examenesService.actualizar(id, dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Archiva un examen del docente autenticado.
   */
  @Delete(':id')
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Archiva un examen' })
  async eliminar(@Param('id', ParseUUIDPipe) id: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.examenesService.archivar(id, usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Publica un examen después de validar reglas de negocio.
   */
  @Post(':id/publicar')
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Publica un examen en borrador' })
  async publicar(@Param('id', ParseUUIDPipe) id: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.examenesService.publicar(id, usuario.id, usuario.idInstitucion);
  }
}
