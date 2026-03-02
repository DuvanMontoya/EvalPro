/**
 * @archivo   Preguntas.controller.ts
 * @descripcion Expone endpoints anidados de preguntas dentro de exámenes.
 * @modulo    Preguntas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Body, Controller, Delete, Get, Param, ParseUUIDPipe, Patch, Post, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { CrearPreguntaDto } from './Dto/CrearPregunta.dto';
import { ActualizarPreguntaDto } from './Dto/ActualizarPregunta.dto';
import { ReordenarPreguntasDto } from './Dto/ReordenarPreguntas.dto';
import { PreguntasService } from './Preguntas.service';

@ApiTags('Preguntas')
@ApiBearerAuth()
@Controller('examenes/:idExamen/preguntas')
@UseGuards(JwtAutenticacionGuard, RolesGuard)
export class PreguntasController {
  constructor(private readonly preguntasService: PreguntasService) {}

  /**
   * Lista preguntas de un examen.
   */
  @Get()
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR, RolUsuario.SUPERADMINISTRADOR)
  @ApiOperation({ summary: 'Lista preguntas por examen' })
  async listar(@Param('idExamen', ParseUUIDPipe) idExamen: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.preguntasService.listar(idExamen, usuario.rol, usuario.id, usuario.idInstitucion);
  }

  /**
   * Crea una pregunta en el examen indicado.
   */
  @Post()
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Crea una pregunta dentro del examen' })
  async crear(
    @Param('idExamen', ParseUUIDPipe) idExamen: string,
    @Body() dto: CrearPreguntaDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.preguntasService.crear(idExamen, dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Actualiza una pregunta existente.
   */
  @Put(':id')
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Actualiza una pregunta existente' })
  async actualizar(
    @Param('idExamen', ParseUUIDPipe) idExamen: string,
    @Param('id', ParseUUIDPipe) idPregunta: string,
    @Body() dto: ActualizarPreguntaDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.preguntasService.actualizar(idExamen, idPregunta, dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Elimina una pregunta.
   */
  @Delete(':id')
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Elimina una pregunta del examen' })
  async eliminar(
    @Param('idExamen', ParseUUIDPipe) idExamen: string,
    @Param('id', ParseUUIDPipe) idPregunta: string,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.preguntasService.eliminar(idExamen, idPregunta, usuario.id, usuario.idInstitucion);
  }

  /**
   * Reordena preguntas del examen.
   */
  @Patch('reordenar')
  @Roles(RolUsuario.DOCENTE)
  @ApiOperation({ summary: 'Reordena preguntas dentro del examen' })
  async reordenar(
    @Param('idExamen', ParseUUIDPipe) idExamen: string,
    @Body() dto: ReordenarPreguntasDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.preguntasService.reordenar(idExamen, dto, usuario.id, usuario.idInstitucion);
  }
}
