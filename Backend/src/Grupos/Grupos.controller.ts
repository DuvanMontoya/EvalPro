import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { AsignarDocenteGrupoDto } from './Dto/AsignarDocenteGrupo.dto';
import { CambiarEstadoGrupoDto } from './Dto/CambiarEstadoGrupo.dto';
import { CrearGrupoDto } from './Dto/CrearGrupo.dto';
import { InscribirEstudianteGrupoDto } from './Dto/InscribirEstudianteGrupo.dto';
import { GruposService } from './Grupos.service';

@ApiTags('Grupos')
@ApiBearerAuth()
@Controller('grupos')
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class GruposController {
  constructor(private readonly gruposService: GruposService) {}

  @Get()
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Lista grupos visibles para el actor autenticado' })
  async listar(@UsuarioActual() actor: UsuarioAutenticado, @Query('idInstitucion') idInstitucion?: string) {
    return this.gruposService.listar(actor, idInstitucion);
  }

  @Get(':id')
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Obtiene detalle de un grupo académico' })
  async obtenerPorId(@Param('id', ParseUUIDPipe) idGrupo: string, @UsuarioActual() actor: UsuarioAutenticado) {
    return this.gruposService.obtenerPorId(idGrupo, actor);
  }

  @Post()
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Crea grupo académico en estado BORRADOR' })
  async crear(@Body() dto: CrearGrupoDto, @UsuarioActual() actor: UsuarioAutenticado) {
    return this.gruposService.crear(dto, actor);
  }

  @Post(':id/docentes')
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Asigna docente a grupo' })
  async asignarDocente(
    @Param('id', ParseUUIDPipe) idGrupo: string,
    @Body() dto: AsignarDocenteGrupoDto,
    @UsuarioActual() actor: UsuarioAutenticado,
  ) {
    return this.gruposService.asignarDocente(idGrupo, dto, actor);
  }

  @Post(':id/estudiantes')
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Inscribe estudiante en grupo' })
  async inscribirEstudiante(
    @Param('id', ParseUUIDPipe) idGrupo: string,
    @Body() dto: InscribirEstudianteGrupoDto,
    @UsuarioActual() actor: UsuarioAutenticado,
  ) {
    return this.gruposService.inscribirEstudiante(idGrupo, dto, actor);
  }

  @Patch(':id/estado')
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Cambia estado de grupo académico' })
  async cambiarEstado(
    @Param('id', ParseUUIDPipe) idGrupo: string,
    @Body() dto: CambiarEstadoGrupoDto,
    @UsuarioActual() actor: UsuarioAutenticado,
  ) {
    return this.gruposService.cambiarEstado(idGrupo, dto, actor);
  }
}
