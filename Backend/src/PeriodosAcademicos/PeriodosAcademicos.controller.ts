import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { ActualizarEstadoPeriodoDto } from './Dto/ActualizarEstadoPeriodo.dto';
import { CrearPeriodoAcademicoDto } from './Dto/CrearPeriodoAcademico.dto';
import { PeriodosAcademicosService } from './PeriodosAcademicos.service';

@ApiTags('PeriodosAcademicos')
@ApiBearerAuth()
@Controller('periodos')
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class PeriodosAcademicosController {
  constructor(private readonly periodosService: PeriodosAcademicosService) {}

  @Get()
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Lista periodos académicos del tenant' })
  async listar(@UsuarioActual() actor: UsuarioAutenticado, @Query('idInstitucion') idInstitucion?: string) {
    return this.periodosService.listar(actor, idInstitucion);
  }

  @Post()
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Crea un periodo académico' })
  async crear(@Body() dto: CrearPeriodoAcademicoDto, @UsuarioActual() actor: UsuarioAutenticado) {
    return this.periodosService.crear(dto, actor);
  }

  @Patch(':id/estado')
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Actualiza estado activo de un periodo académico' })
  async actualizarEstado(
    @Param('id', ParseUUIDPipe) idPeriodo: string,
    @Body() dto: ActualizarEstadoPeriodoDto,
    @UsuarioActual() actor: UsuarioAutenticado,
  ) {
    return this.periodosService.actualizarEstado(idPeriodo, dto, actor);
  }
}

