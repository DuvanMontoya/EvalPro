import { Body, Controller, Post, UseGuards } from '@nestjs/common';
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

  @Post()
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Crea asignación de examen para grupo o estudiante individual' })
  async crear(@Body() dto: CrearAsignacionDto, @UsuarioActual() actor: UsuarioAutenticado) {
    return this.asignacionesService.crear(dto, actor);
  }
}
