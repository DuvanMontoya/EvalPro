/**
 * @archivo   Examenes.e2e-spec.ts
 * @descripcion Verifica permisos y reglas de publicación en el módulo de exámenes.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication } from '@nestjs/common';
import { ModalidadExamen, RolUsuario } from '@prisma/client';
import { afterAll, beforeAll, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import { crearAplicacionE2e, crearUsuarioPrueba, iniciarSesionE2e } from './UtilidadesPruebasE2e';

describe('Examenes (e2e)', () => {
  jest.setTimeout(30_000);
  let aplicacion: INestApplication;

  beforeAll(async () => {
    aplicacion = await crearAplicacionE2e();
  });

  afterAll(async () => {
    await aplicacion.close();
  });

  it('retorna lista de exámenes para administrador autenticado', async () => {
    const admin = await crearUsuarioPrueba(RolUsuario.ADMINISTRADOR, true);
    const autenticacion = await iniciarSesionE2e(aplicacion, admin.correo, admin.contrasena);
    const tokenAcceso = autenticacion.tokenAcceso;
    const respuesta = await request(aplicacion.getHttpServer())
      .get('/api/v1/examenes')
      .set('Authorization', `Bearer ${tokenAcceso}`);

    const datos = respuesta.body?.datos ?? respuesta.body;

    expect(respuesta.status).toBe(200);
    expect(Array.isArray(datos)).toBe(true);
  });

  it('impide que un docente edite un examen de otro docente', async () => {
    const docentePropietario = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const docenteExterno = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const sesionPropietario = await iniciarSesionE2e(aplicacion, docentePropietario.correo, docentePropietario.contrasena);
    const sesionExterno = await iniciarSesionE2e(aplicacion, docenteExterno.correo, docenteExterno.contrasena);

    const examenCreado = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionPropietario.tokenAcceso}`)
      .send({
        titulo: 'Examen propiedad privada',
        descripcion: 'Evaluación de control',
        modalidad: ModalidadExamen.CONTENIDO_COMPLETO,
        duracionMinutos: 30,
        permitirNavegacion: true,
        mostrarPuntaje: true,
      });
    const idExamen = examenCreado.body?.datos?.id;

    const intentoEdicion = await request(aplicacion.getHttpServer())
      .patch(`/api/v1/examenes/${idExamen}`)
      .set('Authorization', `Bearer ${sesionExterno.tokenAcceso}`)
      .send({ titulo: 'Intento no autorizado' });

    expect(intentoEdicion.status).toBe(403);
  });

  it('rechaza publicar examen sin preguntas con código EXAMEN_SIN_PREGUNTAS', async () => {
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const sesion = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesion.tokenAcceso}`)
      .send({
        titulo: 'Examen sin preguntas',
        descripcion: 'Debe fallar publicación',
        modalidad: ModalidadExamen.CONTENIDO_COMPLETO,
        duracionMinutos: 20,
        permitirNavegacion: true,
        mostrarPuntaje: true,
      });
    const idExamen = examen.body?.datos?.id;

    const publicacion = await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${idExamen}/publicar`)
      .set('Authorization', `Bearer ${sesion.tokenAcceso}`);

    expect(publicacion.status).toBe(422);
    expect(publicacion.body?.codigoError).toBe('EXAMEN_SIN_PREGUNTAS');
  });
});
