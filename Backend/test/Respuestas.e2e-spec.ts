/**
 * @archivo   Respuestas.e2e-spec.ts
 * @descripcion Comprueba que endpoints de respuestas requieren autenticación válida.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { afterAll, beforeAll, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import { AppModule } from '../src/App.module';

describe('Respuestas (e2e)', () => {
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

  it('rechaza sincronización de respuestas sin token', async () => {
    const respuesta = await request(aplicacion.getHttpServer()).post('/api/v1/respuestas/sincronizar-lote').send({
      idIntento: '00000000-0000-0000-0000-000000000000',
      respuestas: [],
    });

    expect(respuesta.status).toBe(401);
  });
});
