/**
 * @archivo   Intentos.module.ts
 * @descripcion Declara el módulo de intentos estudiantiles.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module } from '@nestjs/common';
import { SesionesExamenModule } from '../SesionesExamen/SesionesExamen.module';
import { IntentosController } from './Intentos.controller';
import { IntentosService } from './Intentos.service';

@Module({
  imports: [SesionesExamenModule],
  controllers: [IntentosController],
  providers: [IntentosService],
  exports: [IntentosService],
})
export class IntentosModule {}
