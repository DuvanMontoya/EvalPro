import { Body, Controller, Param, ParseUUIDPipe, Patch, Post, UseGuards } from '@nestjs/common';
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
@Roles(RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
export class GruposController {
  constructor(private readonly gruposService: GruposService) {}

  @Post()
  @ApiOperation({ summary: 'Crea grupo académico en estado BORRADOR' })
  async crear(@Body() dto: CrearGrupoDto, @UsuarioActual() actor: UsuarioAutenticado) {
    return this.gruposService.crear(dto, actor);
  }

  @Post(':id/docentes')
  @ApiOperation({ summary: 'Asigna docente a grupo' })
  async asignarDocente(
    @Param('id', ParseUUIDPipe) idGrupo: string,
    @Body() dto: AsignarDocenteGrupoDto,
    @UsuarioActual() actor: UsuarioAutenticado,
  ) {
    return this.gruposService.asignarDocente(idGrupo, dto, actor);
  }

  @Post(':id/estudiantes')
  @ApiOperation({ summary: 'Inscribe estudiante en grupo' })
  async inscribirEstudiante(
    @Param('id', ParseUUIDPipe) idGrupo: string,
    @Body() dto: InscribirEstudianteGrupoDto,
    @UsuarioActual() actor: UsuarioAutenticado,
  ) {
    return this.gruposService.inscribirEstudiante(idGrupo, dto, actor);
  }

  @Patch(':id/estado')
  @ApiOperation({ summary: 'Cambia estado de grupo académico' })
  async cambiarEstado(
    @Param('id', ParseUUIDPipe) idGrupo: string,
    @Body() dto: CambiarEstadoGrupoDto,
    @UsuarioActual() actor: UsuarioAutenticado,
  ) {
    return this.gruposService.cambiarEstado(idGrupo, dto, actor);
  }
}
