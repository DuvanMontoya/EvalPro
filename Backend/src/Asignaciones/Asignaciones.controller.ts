import { Body, Controller, Get, Param, ParseUUIDPipe, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { CrearAsignacionDto } from './Dto/CrearAsignacion.dto';
import { AsignacionesService } from './Asignaciones.service';

@ApiTags('Asignaciones')
@ApiBearerAuth()
@Controller('asignaciones')
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class AsignacionesController {
  constructor(private readonly asignacionesService: AsignacionesService) {}

  @Get()
  @Roles(RolUsuario.SUPERADMINISTRADOR, RolUsuario.ADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Lista asignaciones visibles para el actor autenticado' })
  async listar(@UsuarioActual() actor: UsuarioAutenticado) {
    return this.asignacionesService.listar(actor);
  }

  @Get(':id')
  @Roles(RolUsuario.SUPERADMINISTRADOR, RolUsuario.ADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Obtiene detalle de una asignación por identificador' })
  async obtenerPorId(@Param('id', ParseUUIDPipe) id: string, @UsuarioActual() actor: UsuarioAutenticado) {
    return this.asignacionesService.obtenerPorId(id, actor);
  }

  @Post()
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Crea asignación de examen para grupo o estudiante individual' })
  async crear(@Body() dto: CrearAsignacionDto, @UsuarioActual() actor: UsuarioAutenticado) {
    return this.asignacionesService.crear(dto, actor);
  }
}
