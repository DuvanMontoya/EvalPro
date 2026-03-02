/**
 * @archivo   Autenticacion.e2e-spec.ts
 * @descripcion Valida autenticación, rotación de refresh token y bloqueo de usuarios inactivos.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication } from '@nestjs/common';
import { RolUsuario } from '@prisma/client';
import { afterAll, beforeAll, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import {
  crearAplicacionE2e,
  crearUsuarioPrueba,
  iniciarSesionE2e,
  obtenerPrismaPruebas,
} from './UtilidadesPruebasE2e';

describe('Autenticacion (e2e)', () => {
  jest.setTimeout(30_000);
  let aplicacion: INestApplication;
  const prisma = obtenerPrismaPruebas();

  beforeAll(async () => {
    aplicacion = await crearAplicacionE2e();
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
    expect(usuario?.tokenRefresh).toBeUndefined();
  });

  it('rechaza login con credenciales inválidas usando código estándar', async () => {
    const respuesta = await request(aplicacion.getHttpServer()).post('/api/v1/autenticacion/iniciar-sesion').send({
      correo: 'inexistente@evalpro.test',
      contrasena: 'incorrecta',
    });

    expect(respuesta.status).toBe(401);
    expect(respuesta.body?.codigoError).toBe('CREDENCIALES_INVALIDAS');
  });

  it('rota refresh token y revoca el anterior tras cerrar sesión', async () => {
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const inicio = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);
    const tokenRefresh = inicio.tokenRefresh;

    const refresco = await request(aplicacion.getHttpServer())
      .post('/api/v1/autenticacion/refrescar-tokens')
      .set('Authorization', `Bearer ${tokenRefresh}`);
    const datosRefresco = refresco.body?.datos ?? refresco.body;

    expect(refresco.status).toBe(200);
    expect(typeof datosRefresco?.tokenAcceso).toBe('string');
    expect(typeof datosRefresco?.tokenRefresh).toBe('string');
    expect(datosRefresco?.tokenRefresh).not.toBe(tokenRefresh);

    const cierre = await request(aplicacion.getHttpServer())
      .post('/api/v1/autenticacion/cerrar-sesion')
      .set('Authorization', `Bearer ${datosRefresco?.tokenAcceso}`);

    expect(cierre.status).toBe(200);

    const refrescoRevocado = await request(aplicacion.getHttpServer())
      .post('/api/v1/autenticacion/refrescar-tokens')
      .set('Authorization', `Bearer ${datosRefresco?.tokenRefresh}`);
    expect(refrescoRevocado.status).toBe(403);
  });

  it('bloquea operaciones de usuarios desactivados aunque conserven token previo', async () => {
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const inicio = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);
    expect(inicio.estado).toBe(200);

    await prisma.usuario.update({ where: { id: docente.id }, data: { activo: false } });
    const respuesta = await request(aplicacion.getHttpServer())
      .get('/api/v1/examenes')
      .set('Authorization', `Bearer ${inicio.tokenAcceso}`);

    expect(respuesta.status).toBe(403);
    expect(respuesta.body?.codigoError).toBe('USUARIO_INACTIVO');
  });
});
