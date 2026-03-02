/**
 * @archivo   Usuarios.controller.ts
 * @descripcion Gestiona endpoints administrativos de usuarios con control de roles y propiedad.
 * @modulo    Usuarios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import {
  Body,
  Controller,
  Delete,
  ForbiddenException,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario, Usuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { CrearUsuarioDto } from './Dto/CrearUsuario.dto';
import { ActualizarUsuarioDto } from './Dto/ActualizarUsuario.dto';
import { UsuariosService } from './Usuarios.service';

@ApiTags('Usuarios')
@ApiBearerAuth()
@Controller('usuarios')
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class UsuariosController {
  constructor(private readonly usuariosService: UsuariosService) {}

  /**
   * Retorna lista de usuarios según alcance del rol autenticado.
   * @param usuario - Usuario autenticado.
   */
  @Get()
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Lista usuarios visibles para el solicitante' })
  async listar(@UsuarioActual() usuario: Usuario) {
    return this.usuariosService.listar(usuario.rol, usuario.id);
  }

  /**
   * Crea un nuevo usuario.
   * @param dto - Datos validados de creación.
   */
  @Post()
  @Roles(RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Crea un usuario nuevo' })
  async crear(@Body() dto: CrearUsuarioDto) {
    return this.usuariosService.crear(dto);
  }

  /**
   * Obtiene un usuario por identificador.
   * @param id - UUID del usuario.
   * @param usuario - Usuario autenticado.
   */
  @Get(':id')
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Obtiene detalles de usuario por id' })
  async obtenerPorId(@Param('id') id: string, @UsuarioActual() usuario: Usuario) {
    this.validarPropiedad(id, usuario);
    return this.usuariosService.obtenerPorId(id);
  }

  /**
   * Actualiza parcialmente un usuario.
   * @param id - UUID del usuario.
   * @param dto - Datos parciales de actualización.
   * @param usuario - Usuario autenticado.
   */
  @Patch(':id')
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Actualiza un usuario por id' })
  async actualizar(@Param('id') id: string, @Body() dto: ActualizarUsuarioDto, @UsuarioActual() usuario: Usuario) {
    this.validarPropiedad(id, usuario);
    return this.usuariosService.actualizar(id, dto);
  }

  /**
   * Desactiva lógicamente un usuario.
   * @param id - UUID del usuario.
   */
  @Delete(':id')
  @Roles(RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Desactiva un usuario' })
  async desactivar(@Param('id') id: string) {
    return this.usuariosService.desactivar(id);
  }

  /**
   * Verifica que el usuario pueda operar sobre el recurso indicado.
   * @param idObjetivo - ID del usuario objetivo.
   * @param usuario - Usuario autenticado.
   */
  private validarPropiedad(idObjetivo: string, usuario: Usuario): void {
    const puede = usuario.rol === RolUsuario.ADMINISTRADOR || usuario.id === idObjetivo;
    if (!puede) {
      throw new ForbiddenException('No tiene permisos para operar sobre este usuario');
    }
  }
}
