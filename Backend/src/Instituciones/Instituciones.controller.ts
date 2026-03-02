import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { CambiarEstadoInstitucionDto } from './Dto/CambiarEstadoInstitucion.dto';
import { CrearInstitucionDto } from './Dto/CrearInstitucion.dto';
import { InstitucionesService } from './Instituciones.service';

@ApiTags('Instituciones')
@ApiBearerAuth()
@Controller('instituciones')
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class InstitucionesController {
  constructor(private readonly institucionesService: InstitucionesService) {}

  @Get()
  @Roles(RolUsuario.SUPERADMINISTRADOR, RolUsuario.ADMINISTRADOR, RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Lista instituciones visibles para el actor autenticado' })
  async listar(@UsuarioActual() actor: UsuarioAutenticado) {
    return this.institucionesService.listar(actor);
  }

  @Post()
  @Roles(RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Crea una institución (solo SUPERADMINISTRADOR)' })
  async crear(@Body() dto: CrearInstitucionDto, @UsuarioActual() actor: UsuarioAutenticado) {
    return this.institucionesService.crear(dto, actor.rol);
  }

  @Patch(':id/estado')
  @Roles(RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Cambia estado de institución (solo SUPERADMINISTRADOR)' })
  async cambiarEstado(
    @Param('id', ParseUUIDPipe) idInstitucion: string,
    @Body() dto: CambiarEstadoInstitucionDto,
    @UsuarioActual() actor: UsuarioAutenticado,
  ) {
    return this.institucionesService.cambiarEstado(idInstitucion, dto, actor.rol);
  }
}
