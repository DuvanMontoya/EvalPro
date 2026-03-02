/**
 * @archivo   Telemetria.module.ts
 * @descripcion Declara el módulo de telemetría y su integración con sesiones en tiempo real.
 * @modulo    Telemetria
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module, forwardRef } from '@nestjs/common';
import { SesionesExamenModule } from '../SesionesExamen/SesionesExamen.module';
import { TelemetriaController } from './Telemetria.controller';
import { TelemetriaService } from './Telemetria.service';

@Module({
  imports: [forwardRef(() => SesionesExamenModule)],
  controllers: [TelemetriaController],
  providers: [TelemetriaService],
  exports: [TelemetriaService],
})
export class TelemetriaModule {}
