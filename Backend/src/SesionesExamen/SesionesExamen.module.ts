/**
 * @archivo   SesionesExamen.module.ts
 * @descripcion Registra componentes de sesiones y publica gateway para tiempo real.
 * @modulo    SesionesExamen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module, forwardRef } from '@nestjs/common';
import { RespuestasModule } from '../Respuestas/Respuestas.module';
import { SesionesExamenController } from './SesionesExamen.controller';
import { SesionesExamenService } from './SesionesExamen.service';
import { SesionesExamenGateway } from './SesionesExamen.gateway';

@Module({
  imports: [forwardRef(() => RespuestasModule)],
  controllers: [SesionesExamenController],
  providers: [SesionesExamenService, SesionesExamenGateway],
  exports: [SesionesExamenService, SesionesExamenGateway],
})
export class SesionesExamenModule {}
