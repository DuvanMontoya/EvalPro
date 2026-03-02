/**
 * @archivo   Respuestas.controller.ts
 * @descripcion Expone endpoints de sincronización y finalización de respuestas estudiantiles.
 * @modulo    Respuestas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Body, Controller, Param, ParseUUIDPipe, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
import { CalificarRespuestaManualDto } from './Dto/CalificarRespuestaManual.dto';
import { SincronizarRespuestasDto } from './Dto/SincronizarRespuestas.dto';
import { RespuestasService } from './Respuestas.service';

@ApiTags('Respuestas')
@ApiBearerAuth()
@Controller()
@UseGuards(JwtAutenticacionGuard, RolesGuard)
@Roles(RolUsuario.ESTUDIANTE)
export class RespuestasController {
  constructor(private readonly respuestasService: RespuestasService) {}

  /**
   * Sincroniza un lote de respuestas del estudiante autenticado.
   */
  @Post('respuestas/sincronizar-lote')
  @ApiOperation({ summary: 'Sincroniza respuestas en lote' })
  async sincronizarLote(@Body() dto: SincronizarRespuestasDto, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.respuestasService.sincronizarLote(dto, usuario.id, usuario.idInstitucion);
  }

  /**
   * Finaliza el intento y dispara calificación automática.
   */
  @Post('intentos/:idIntento/finalizar')
  @ApiOperation({ summary: 'Finaliza intento y calcula puntaje' })
  async finalizar(@Param('idIntento', ParseUUIDPipe) idIntento: string, @UsuarioActual() usuario: UsuarioAutenticado) {
    return this.respuestasService.finalizar(idIntento, usuario.id, usuario.idInstitucion);
  }

  /**
   * Registra calificación manual para respuestas abiertas y recalcúla el intento.
   */
  @Patch('respuestas/:id/calificar-manual')
  @Roles(RolUsuario.DOCENTE, RolUsuario.ADMINISTRADOR)
  @ApiOperation({ summary: 'Califica manualmente una respuesta abierta' })
  async calificarManual(
    @Param('id', ParseUUIDPipe) idRespuesta: string,
    @Body() dto: CalificarRespuestaManualDto,
    @UsuarioActual() usuario: UsuarioAutenticado,
  ) {
    return this.respuestasService.calificarManual(idRespuesta, dto, usuario.rol, usuario.id, usuario.idInstitucion);
  }
}
