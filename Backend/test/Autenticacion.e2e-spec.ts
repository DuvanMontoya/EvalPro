/**
 * @archivo   Autenticacion.e2e-spec.ts
 * @descripcion Verifica flujo base de autenticación con credenciales administrativas iniciales.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { afterAll, beforeAll, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import { AppModule } from '../src/App.module';

describe('Autenticacion (e2e)', () => {
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

  it('inicia sesión con el administrador inicial', async () => {
    const correoAdmin = process.env.ADMIN_CORREO_INICIAL ?? 'admin@evalPro.com';
    const contrasenaAdmin = process.env.ADMIN_CONTRASENA_INICIAL ?? 'CambiarInmediatamente123!';

    const respuesta = await request(aplicacion.getHttpServer()).post('/api/v1/autenticacion/iniciar-sesion').send({
      correo: correoAdmin,
      contrasena: contrasenaAdmin,
    });

    const datos = respuesta.body?.datos ?? respuesta.body;
    const usuario = datos?.usuario ?? {};

    expect([200, 201]).toContain(respuesta.status);
    expect(typeof datos?.tokenAcceso).toBe('string');
    expect(usuario?.rol).toBe('ADMINISTRADOR');
  });
});
