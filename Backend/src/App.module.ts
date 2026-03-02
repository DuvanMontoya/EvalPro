/**
 * @archivo   App.module.ts
 * @descripcion Registra los módulos globales y funcionales del backend de EvalPro.
 * @modulo    src
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module } from '@nestjs/common';
import { ThrottlerModule } from '@nestjs/throttler';
import { AppController } from './App.controller';
import { ConfiguracionModule } from './Configuracion/Configuracion.module';
import { AutenticacionModule } from './Autenticacion/Autenticacion.module';
import { UsuariosModule } from './Usuarios/Usuarios.module';
import { ExamenesModule } from './Examenes/Examenes.module';
import { PreguntasModule } from './Preguntas/Preguntas.module';
import { SesionesExamenModule } from './SesionesExamen/SesionesExamen.module';
import { IntentosModule } from './Intentos/Intentos.module';
import { RespuestasModule } from './Respuestas/Respuestas.module';
import { TelemetriaModule } from './Telemetria/Telemetria.module';
import { ReportesModule } from './Reportes/Reportes.module';

@Module({
  imports: [
    ConfiguracionModule,
    ThrottlerModule.forRoot([{ ttl: 60_000 * 15, limit: 10 }]),
    AutenticacionModule,
    UsuariosModule,
    ExamenesModule,
    PreguntasModule,
    SesionesExamenModule,
    IntentosModule,
    RespuestasModule,
    TelemetriaModule,
    ReportesModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
