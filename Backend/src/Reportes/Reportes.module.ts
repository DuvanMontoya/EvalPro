/**
 * @archivo   Reportes.module.ts
 * @descripcion Declara controlador y servicio del dominio de reportes académicos.
 * @modulo    Reportes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module } from '@nestjs/common';
import { RespuestasModule } from '../Respuestas/Respuestas.module';
import { ReportesController } from './Reportes.controller';
import { ReportesService } from './Reportes.service';

@Module({
  imports: [RespuestasModule],
  controllers: [ReportesController],
  providers: [ReportesService],
})
export class ReportesModule {}
