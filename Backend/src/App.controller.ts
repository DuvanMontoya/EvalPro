/**
 * @archivo   App.controller.ts
 * @descripcion Expone un endpoint de salud básico para verificar disponibilidad del servicio.
 * @modulo    src
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('Aplicacion')
@Controller()
export class AppController {
  /**
   * Retorna un mensaje simple de estado del backend.
   * @returns Objeto con indicador textual de disponibilidad.
   */
  @Get('salud')
  obtenerSalud(): { estado: string } {
    return { estado: 'ok' };
  }
}
