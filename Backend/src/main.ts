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
import { construirConfiguracionCors } from './Configuracion/Cors.config';

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
  aplicacion.enableCors(construirConfiguracionCors(servicioConfiguracion));

  aplicacion.useGlobalFilters(new ExcepcionGlobalFiltro());
  aplicacion.useGlobalPipes(new ValidacionGlobalPipe());
  aplicacion.useGlobalInterceptors(
    aplicacion.get(TransformRespuestaInterceptor),
    aplicacion.get(RegistroActividadInterceptor),
  );

  const puerto = servicioConfiguracion.getOrThrow<number>('PUERTO_APP');
  const host = servicioConfiguracion.getOrThrow<string>('HOST_APP');
  await aplicacion.listen(puerto, host);
  Logger.log(`Servidor listo en http://${host}:${puerto}`, 'EvalPro');
}

void iniciarAplicacion();
