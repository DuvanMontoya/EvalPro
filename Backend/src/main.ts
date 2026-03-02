/**
 * @archivo   main.ts
 * @descripcion Inicializa la aplicación NestJS con configuración global de seguridad, validación y documentación.
 * @modulo    src
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './App.module';
import { ExcepcionGlobalFiltro } from './Comun/Filtros/ExcepcionGlobal.filtro';
import { ValidacionGlobalPipe } from './Comun/Pipes/ValidacionGlobal.pipe';
import { TransformRespuestaInterceptor } from './Comun/Interceptores/TransformRespuesta.interceptor';
import { RegistroActividadInterceptor } from './Comun/Interceptores/RegistroActividad.interceptor';

/**
 * Arranca el servidor HTTP aplicando filtros, pipes e interceptores globales.
 */
async function iniciarAplicacion(): Promise<void> {
  const aplicacion = await NestFactory.create(AppModule);
  const servicioConfiguracion = aplicacion.get(ConfigService);

  const documento = new DocumentBuilder()
    .setTitle('EvalPro API')
    .setDescription('API REST y WebSocket del sistema EvalPro')
    .setVersion('1.0.0')
    .addBearerAuth()
    .build();
  const especificacion = SwaggerModule.createDocument(aplicacion, documento);
  SwaggerModule.setup('api/docs', aplicacion, especificacion);

  aplicacion.setGlobalPrefix('api/v1');
  aplicacion.enableCors({
    origin: (servicioConfiguracion.get<string>('CORS_ORIGENES_PERMITIDOS') ?? '')
      .split(',')
      .map((origen: string) => origen.trim())
      .filter((origen: string) => origen.length > 0),
    credentials: true,
  });

  aplicacion.useGlobalFilters(new ExcepcionGlobalFiltro());
  aplicacion.useGlobalPipes(new ValidacionGlobalPipe());
  aplicacion.useGlobalInterceptors(
    aplicacion.get(TransformRespuestaInterceptor),
    aplicacion.get(RegistroActividadInterceptor),
  );

  const puerto = servicioConfiguracion.get<number>('PUERTO_APP') ?? 3001;
  await aplicacion.listen(puerto);
  Logger.log(`Servidor listo en puerto ${puerto}`, 'EvalPro');
}

void iniciarAplicacion();
