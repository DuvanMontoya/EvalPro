/**
 * @archivo   Examenes.e2e-spec.ts
 * @descripcion Valida acceso autenticado al listado de exámenes para roles con permiso.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { afterAll, beforeAll, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import { AppModule } from '../src/App.module';

describe('Examenes (e2e)', () => {
  jest.setTimeout(30_000);
  let aplicacion: INestApplication;

  beforeAll(async () => {
    const moduloPruebas = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    aplicacion = moduloPruebas.createNestApplication();
    aplicacion.setGlobalPrefix('api/v1');
    await aplicacion.init();
  });

  afterAll(async () => {
    await aplicacion.close();
  });

  it('retorna lista de exámenes para administrador autenticado', async () => {
    const correoAdmin = process.env.ADMIN_CORREO_INICIAL ?? 'admin@evalPro.com';
    const contrasenaAdmin = process.env.ADMIN_CONTRASENA_INICIAL ?? 'CambiarInmediatamente123!';

    const autenticacion = await request(aplicacion.getHttpServer()).post('/api/v1/autenticacion/iniciar-sesion').send({
      correo: correoAdmin,
      contrasena: contrasenaAdmin,
    });

    const datosSesion = autenticacion.body?.datos ?? autenticacion.body;
    const tokenAcceso = datosSesion?.tokenAcceso as string;
    const respuesta = await request(aplicacion.getHttpServer())
      .get('/api/v1/examenes')
      .set('Authorization', `Bearer ${tokenAcceso}`);

    const datos = respuesta.body?.datos ?? respuesta.body;

    expect(respuesta.status).toBe(200);
    expect(Array.isArray(datos)).toBe(true);
  });
});
