/**
 * @archivo   Respuestas.module.ts
 * @descripcion Declara el módulo de respuestas con dependencias de telemetría.
 * @modulo    Respuestas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module, forwardRef } from '@nestjs/common';
import { TelemetriaModule } from '../Telemetria/Telemetria.module';
import { SesionesExamenModule } from '../SesionesExamen/SesionesExamen.module';
import { CalificacionRespuestasService } from './CalificacionRespuestas.service';
import { RespuestasController } from './Respuestas.controller';
import { RespuestasService } from './Respuestas.service';

@Module({
  imports: [forwardRef(() => TelemetriaModule), forwardRef(() => SesionesExamenModule)],
  controllers: [RespuestasController],
  providers: [RespuestasService, CalificacionRespuestasService],
  exports: [RespuestasService],
})
export class RespuestasModule {}
