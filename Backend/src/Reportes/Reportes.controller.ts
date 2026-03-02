/**
 * @archivo   Reportes.controller.ts
 * @descripcion Publica endpoints de reportes por sesión y por estudiante con autorización contextual.
 * @modulo    Reportes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Controller, ForbiddenException, Get, Param, ParseUUIDPipe, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario, Usuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { ReportesService } from './Reportes.service';

@ApiTags('Reportes')
@ApiBearerAuth()
@Controller('reportes')
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class ReportesController {
  constructor(private readonly reportesService: ReportesService) {}

  /**
   * Obtiene reporte estadístico de una sesión específica.
   */
  @Get('sesion/:idSesion')
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Obtiene reporte de sesión' })
  async obtenerReporteSesion(@Param('idSesion', ParseUUIDPipe) idSesion: string, @UsuarioActual() usuario: Usuario) {
    return this.reportesService.obtenerReporteSesion(idSesion, usuario.rol, usuario.id);
  }

  /**
   * Obtiene reporte histórico para un estudiante específico.
   */
  @Get('estudiante/:idEstudiante')
  @Roles(RolUsuario.ADMINISTRADOR, RolUsuario.DOCENTE, RolUsuario.ESTUDIANTE)
  @ApiOperation({ summary: 'Obtiene reporte por estudiante' })
  async obtenerReporteEstudiante(
    @Param('idEstudiante', ParseUUIDPipe) idEstudiante: string,
    @UsuarioActual() usuario: Usuario,
  ) {
    if (usuario.rol === RolUsuario.ESTUDIANTE && usuario.id !== idEstudiante) {
      throw new ForbiddenException('No tiene permisos para consultar este estudiante');
    }

    return this.reportesService.obtenerReporteEstudiante(idEstudiante, usuario.rol, usuario.id);
  }
}
