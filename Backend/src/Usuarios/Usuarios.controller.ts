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
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { CrearUsuarioDto } from './Dto/CrearUsuario.dto';
import { CrearUsuarioRolDto } from './Dto/CrearUsuarioRol.dto';
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
  @Roles(RolUsuario.SUPERADMINISTRADOR, RolUsuario.ADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Lista usuarios visibles para el solicitante' })
  async listar(@UsuarioActual() usuario: UsuarioAutenticado) {
    return this.usuariosService.listar(usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Crea un nuevo usuario.
   * @param dto - Datos validados de creación.
   */
  @Post()
  @Roles(RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Crea un usuario nuevo' })
  async crear(@Body() dto: CrearUsuarioDto, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.usuariosService.crear(dto, usuario.idInstitucion);
  }

  /**
   * Crea un usuario docente con rol forzado desde backend.
   * @param dto - Datos base de usuario docente.
   */
  @Post('docentes')
  @Roles(RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Crea un docente' })
  async crearDocente(@Body() dto: CrearUsuarioRolDto, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.usuariosService.crearDocente(dto, usuario.idInstitucion);
  }

  /**
   * Crea un usuario estudiante con rol forzado desde backend.
   * @param dto - Datos base de usuario estudiante.
   */
  @Post('estudiantes')
  @Roles(RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Crea un estudiante' })
  async crearEstudiante(@Body() dto: CrearUsuarioRolDto, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.usuariosService.crearEstudiante(dto, usuario.idInstitucion);
  }

  /**
   * Obtiene un usuario por identificador.
   * @param id - UUID del usuario.
   * @param usuario - Usuario autenticado.
   */
  @Get(':id')
  @Roles(RolUsuario.SUPERADMINISTRADOR, RolUsuario.ADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Obtiene detalles de usuario por id' })
  async obtenerPorId(@Param('id', ParseUUIDPipe) id: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.usuariosService.obtenerPorId(id, usuario.rol, usuario.id, usuario.idInstitucion);
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
  async actualizar(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ActualizarUsuarioDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.usuariosService.actualizar(id, dto, usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Desactiva lógicamente un usuario.
   * @param id - UUID del usuario.
   */
  @Delete(':id')
  @Roles(RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Desactiva un usuario' })
  async desactivar(@Param('id', ParseUUIDPipe) id: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.usuariosService.desactivar(id, usuario.rol, usuario.idInstitucion);
  }
}
