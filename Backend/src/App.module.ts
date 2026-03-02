/**
 * @archivo   App.module.ts
 * @descripcion Registra los módulos globales y funcionales del backend de EvalPro.
 * @modulo    src
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
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
import { AuditoriaModule } from './Auditoria/Auditoria.module';
import { TransformRespuestaInterceptor } from './Comun/Interceptores/TransformRespuesta.interceptor';
import { RegistroActividadInterceptor } from './Comun/Interceptores/RegistroActividad.interceptor';
import { InstitucionesModule } from './Instituciones/Instituciones.module';
import { GruposModule } from './Grupos/Grupos.module';
import { AsignacionesModule } from './Asignaciones/Asignaciones.module';
import { ReclamosModule } from './Reclamos/Reclamos.module';

@Module({
  imports: [
    ConfiguracionModule,
    ThrottlerModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (servicioConfiguracion: ConfigService) => {
        const entorno = servicioConfiguracion.get<string>('ENTORNO', 'desarrollo');
        const esPruebas = entorno === 'pruebas' || process.env.NODE_ENV === 'test';
        return [{ ttl: 60_000 * 15, limit: esPruebas ? 10_000 : 10 }];
      },
    }),
    AutenticacionModule,
    UsuariosModule,
    ExamenesModule,
    PreguntasModule,
    SesionesExamenModule,
    IntentosModule,
    RespuestasModule,
    TelemetriaModule,
    ReportesModule,
    AuditoriaModule,
    InstitucionesModule,
    GruposModule,
    AsignacionesModule,
    ReclamosModule,
  ],
  controllers: [AppController],
  providers: [TransformRespuestaInterceptor, RegistroActividadInterceptor],
})
export class AppModule {}
