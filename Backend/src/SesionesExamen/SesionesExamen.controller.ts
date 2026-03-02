/**
 * @archivo   SesionesExamen.controller.ts
 * @descripcion Expone endpoints de gestión y consulta de sesiones de examen.
 * @modulo    SesionesExamen
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
import { CrearSesionDto } from './Dto/CrearSesion.dto';
import { SesionesExamenService } from './SesionesExamen.service';

@ApiTags('Sesiones')
@ApiBearerAuth()
@Controller('sesiones')
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class SesionesExamenController {
  constructor(private readonly sesionesService: SesionesExamenService) {}

  /**
   * Lista sesiones visibles para el usuario autenticado.
   */
  @Get()
  @Roles(RolUsuario.SUPERADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Lista sesiones por rol' })
  async listar(@UsuarioActual() usuario: UsuarioAutenticado) {
    return this.sesionesService.listar(usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Crea una sesión para un examen publicado del docente.
   */
  @Post()
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Crea una sesión de examen' })
  async crear(@Body() dto: CrearSesionDto, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.sesionesService.crear(dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Busca sesión por código para estudiantes.
   */
  @Get('buscar/:codigo')
  @Roles(RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Busca sesión por código de acceso' })
  async buscarPorCodigo(@Param('codigo') codigo: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.sesionesService.buscarPorCodigo(codigo, usuario.id, usuario.idInstitucion);
  }

  /**
   * Obtiene detalle de sesión por ID.
   */
  @Get(':id')
  @Roles(RolUsuario.SUPERADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Obtiene una sesión por id' })
  async obtenerPorId(@Param('id', ParseUUIDPipe) id: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.sesionesService.obtenerPorId(id, usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Activa sesión pendiente del docente autenticado.
   */
  @Post(':id/activar')
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Activa una sesión pendiente' })
  async activar(@Param('id', ParseUUIDPipe) id: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.sesionesService.activar(id, usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Finaliza sesión activa y dispara cierre masivo de evaluación.
   */
  @Post(':id/finalizar')
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Finaliza una sesión activa' })
  async finalizar(@Param('id', ParseUUIDPipe) id: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.sesionesService.finalizar(id, usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Cancela una sesión pendiente o activa por decisión del docente propietario.
   */
  @Post(':id/cancelar')
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Cancela una sesión pendiente o activa' })
  async cancelar(@Param('id', ParseUUIDPipe) id: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.sesionesService.cancelar(id, usuario.rol, usuario.id, usuario.idInstitucion);
  }
}
