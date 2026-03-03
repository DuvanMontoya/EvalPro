/**
 * @archivo   Usuarios.e2e-spec.ts
 * @descripcion Verifica que administración de usuarios permita crear docentes/estudiantes con reglas estrictas.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication } from '@nestjs/common';
import { RolUsuario } from '@prisma/client';
import { afterAll, beforeAll, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import { crearAplicacionE2e, crearUsuarioPrueba, iniciarSesionE2e } from './UtilidadesPruebasE2e';

describe('Usuarios (e2e)', () => {
  jest.setTimeout(30_000);
  let aplicacion: INestApplication;

  beforeAll(async () => {
    aplicacion = await crearAplicacionE2e();
  });

  afterAll(async () => {
    await aplicacion.close();
  });

  it('permite al administrador crear docentes y estudiantes por rutas dedicadas', async () => {
    const admin = await crearUsuarioPrueba(RolUsuario.ADMINISTRADOR, true);
    const sesionAdmin = await iniciarSesionE2e(aplicacion, admin.correo, admin.contrasena);

    const sufijo = Date.now();
    const docente = await request(aplicacion.getHttpServer())
      .post('/api/v1/usuarios/docentes')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: 'Docente',
        apellidos: 'Creado',
        correo: `docente_${sufijo}@evalpro.test`,
        contrasena: 'TemporalSegura123!',
      });
    const estudiante = await request(aplicacion.getHttpServer())
      .post('/api/v1/usuarios/estudiantes')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: 'Estudiante',
        apellidos: 'Creado',
        correo: `estudiante_${sufijo}@evalpro.test`,
        contrasena: 'TemporalSegura123!',
      });

    expect(docente.status).toBe(201);
    expect(docente.body?.datos?.rol).toBe(RolUsuario.DOCENTE);
    expect(estudiante.status).toBe(201);
    expect(estudiante.body?.datos?.rol).toBe(RolUsuario.ESTUDIANTE);
  });

  it('bloquea creación de administradores por endpoint público de usuarios', async () => {
    const admin = await crearUsuarioPrueba(RolUsuario.ADMINISTRADOR, true);
    const sesionAdmin = await iniciarSesionE2e(aplicacion, admin.correo, admin.contrasena);

    const respuesta = await request(aplicacion.getHttpServer())
      .post('/api/v1/usuarios')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: 'Nuevo',
        apellidos: 'Administrador',
        correo: `admin_nuevo_${Date.now()}@evalpro.test`,
        contrasena: 'TemporalSegura123!',
        rol: RolUsuario.ADMINISTRADOR,
      });

    expect(respuesta.status).toBe(400);
    expect(respuesta.body?.codigoError).toBe('ROL_NO_PERMITIDO');
  });

  it('permite a superadministrador crear administrador indicando idInstitucion', async () => {
    const adminBase = await crearUsuarioPrueba(RolUsuario.ADMINISTRADOR, true);
    const correoSuperadmin = process.env.SUPERADMIN_CORREO_INICIAL ?? 'superadmin@evalpro.com';
    const contrasenaSuperadmin =
      process.env.SUPERADMIN_CONTRASENA_INICIAL ??
      process.env.ADMIN_CONTRASENA_INICIAL ??
      'CambiarInmediatamente123!';

    const sesionSuperadmin = await iniciarSesionE2e(aplicacion, correoSuperadmin, contrasenaSuperadmin);
    expect(sesionSuperadmin.estado).toBe(200);
    expect(adminBase.idInstitucion).toBeTruthy();

    const respuesta = await request(aplicacion.getHttpServer())
      .post('/api/v1/usuarios')
      .set('Authorization', `Bearer ${sesionSuperadmin.tokenAcceso}`)
      .send({
        nombre: 'Admin',
        apellidos: 'CreadoPorSuperadmin',
        correo: `admin_super_${Date.now()}@evalpro.test`,
        contrasena: 'TemporalSegura123!',
        rol: RolUsuario.ADMINISTRADOR,
        idInstitucion: adminBase.idInstitucion,
      });

    expect(respuesta.status).toBe(201);
    expect(respuesta.body?.datos?.rol).toBe(RolUsuario.ADMINISTRADOR);
    expect(respuesta.body?.datos?.idInstitucion).toBe(adminBase.idInstitucion);
  });

  it('impide a usuarios no admin crear cuentas', async () => {
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const sesionDocente = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);

    const respuesta = await request(aplicacion.getHttpServer())
      .post('/api/v1/usuarios/estudiantes')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        nombre: 'No',
        apellidos: 'Permitido',
        correo: `prohibido_${Date.now()}@evalpro.test`,
        contrasena: 'TemporalSegura123!',
      });

    expect(respuesta.status).toBe(403);
  });

  it('evita que un usuario se autoasigne rol de administrador', async () => {
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const sesion = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);

    const respuesta = await request(aplicacion.getHttpServer())
      .patch(`/api/v1/usuarios/${estudiante.id}`)
      .set('Authorization', `Bearer ${sesion.tokenAcceso}`)
      .send({ rol: RolUsuario.ADMINISTRADOR });

    expect(respuesta.status).toBe(403);
  });
});
