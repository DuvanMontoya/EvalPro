/**
 * @archivo   SesionesExamen.module.ts
 * @descripcion Registra componentes de sesiones y publica gateway para tiempo real.
 * @modulo    SesionesExamen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module, forwardRef } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { RespuestasModule } from '../Respuestas/Respuestas.module';
import { AutorizacionSocketSesionesService } from './AutorizacionSocketSesiones.service';
import { SesionesExamenController } from './SesionesExamen.controller';
import { SesionesExamenService } from './SesionesExamen.service';
import { SesionesExamenGateway } from './SesionesExamen.gateway';

@Module({
  imports: [
    forwardRef(() => RespuestasModule),
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (servicioConfiguracion: ConfigService) => ({
        secret: servicioConfiguracion.get<string>('JWT_SECRETO_ACCESO', ''),
      }),
    }),
  ],
  controllers: [SesionesExamenController],
  providers: [SesionesExamenService, SesionesExamenGateway, AutorizacionSocketSesionesService],
  exports: [SesionesExamenService, SesionesExamenGateway],
})
export class SesionesExamenModule {}
