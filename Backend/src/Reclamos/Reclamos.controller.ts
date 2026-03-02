import { Body, Controller, Param, ParseUUIDPipe, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { CrearReclamoDto } from './Dto/CrearReclamo.dto';
import { ResolverReclamoDto } from './Dto/ResolverReclamo.dto';
import { ReclamosService } from './Reclamos.service';

@ApiTags('Reclamos')
@ApiBearerAuth()
@Controller()
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class ReclamosController {
  constructor(private readonly reclamosService: ReclamosService) {}

  @Post('resultados/:idResultado/reclamos')
  @Roles(RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Presenta reclamo sobre resultado de intento' })
  async crear(
    @Param('idResultado', ParseUUIDPipe) idResultado: string,
    @Body() dto: CrearReclamoDto,
    @UsuarioActual() actor: UsuarioAutenticado,
  ) {
    return this.reclamosService.crear(idResultado, dto, actor);
  }

  @Patch('reclamos/:idReclamo/resolver')
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Resuelve reclamo de calificación' })
  async resolver(
    @Param('idReclamo', ParseUUIDPipe) idReclamo: string,
    @Body() dto: ResolverReclamoDto,
    @UsuarioActual() actor: UsuarioAutenticado,
  ) {
    return this.reclamosService.resolver(idReclamo, dto, actor);
  }
}
