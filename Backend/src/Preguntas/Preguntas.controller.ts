/**
 * @archivo   Preguntas.controller.ts
 * @descripcion Expone endpoints anidados de preguntas dentro de exámenes.
 * @modulo    Preguntas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Body, Controller, Delete, Get, Param, Patch, Post, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario, Usuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
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
@Roles(RolUsuario.DOCENTE)
export class PreguntasController {
  constructor(private readonly preguntasService: PreguntasService) {}

  /**
   * Lista preguntas de un examen.
   */
  @Get()
  @ApiOperation({ summary: 'Lista preguntas por examen' })
  async listar(@Param('idExamen') idExamen: string) {
    return this.preguntasService.listar(idExamen);
  }

  /**
   * Crea una pregunta en el examen indicado.
   */
  @Post()
  @ApiOperation({ summary: 'Crea una pregunta dentro del examen' })
  async crear(@Param('idExamen') idExamen: string, @Body() dto: CrearPreguntaDto) {
    return this.preguntasService.crear(idExamen, dto);
  }

  /**
   * Actualiza una pregunta existente.
   */
  @Put(':id')
  @ApiOperation({ summary: 'Actualiza una pregunta existente' })
  async actualizar(
    @Param('idExamen') idExamen: string,
    @Param('id') idPregunta: string,
    @Body() dto: ActualizarPreguntaDto,
    @UsuarioActual() usuario: Usuario,
  ) {
    return this.preguntasService.actualizar(idExamen, idPregunta, dto, usuario.id);
  }

  /**
   * Elimina una pregunta.
   */
  @Delete(':id')
  @ApiOperation({ summary: 'Elimina una pregunta del examen' })
  async eliminar(
    @Param('idExamen') idExamen: string,
    @Param('id') idPregunta: string,
    @UsuarioActual() usuario: Usuario,
  ) {
    return this.preguntasService.eliminar(idExamen, idPregunta, usuario.id);
  }

  /**
   * Reordena preguntas del examen.
   */
  @Patch('reordenar')
  @ApiOperation({ summary: 'Reordena preguntas dentro del examen' })
  async reordenar(
    @Param('idExamen') idExamen: string,
    @Body() dto: ReordenarPreguntasDto,
    @UsuarioActual() usuario: Usuario,
  ) {
    return this.preguntasService.reordenar(idExamen, dto, usuario.id);
  }
}
