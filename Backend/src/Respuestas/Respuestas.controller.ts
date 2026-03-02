/**
 * @archivo   Respuestas.controller.ts
 * @descripcion Expone endpoints de sincronización y finalización de respuestas estudiantiles.
 * @modulo    Respuestas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Body, Controller, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RolUsuario, Usuario } from '@prisma/client';
import { Roles } from '../Comun/Decoradores/Roles.decorador';
import { UsuarioActual } from '../Comun/Decoradores/UsuarioActual.decorador';
import { JwtAutenticacionGuard } from '../Comun/Guards/JwtAutenticacion.guard';
import { RolesGuard } from '../Comun/Guards/Roles.guard';
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
  async sincronizarLote(@Body() dto: SincronizarRespuestasDto, @UsuarioActual() usuario: Usuario) {
    return this.respuestasService.sincronizarLote(dto, usuario.id);
  }

  /**
   * Finaliza el intento y dispara calificación automática.
   */
  @Post('intentos/:idIntento/finalizar')
  @ApiOperation({ summary: 'Finaliza intento y calcula puntaje' })
  async finalizar(@Param('idIntento') idIntento: string, @UsuarioActual() usuario: Usuario) {
    return this.respuestasService.finalizar(idIntento, usuario.id);
  }
}
