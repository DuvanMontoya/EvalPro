/**
 * @archivo   GestionAccesos.e2e-spec.ts
 * @descripcion Verifica accesos de lectura en gestión para grupos y asignaciones por rol.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-04
 */
import { INestApplication } from '@nestjs/common';
import { ModalidadExamen, RolUsuario, TipoPregunta } from '@prisma/client';
import { afterAll, beforeAll, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import { crearAplicacionE2e, crearUsuarioPrueba, iniciarSesionE2e, obtenerPrismaPruebas } from './UtilidadesPruebasE2e';

type RespuestaApi = { datos?: unknown };

function datos<T = Record<string, unknown>>(cuerpo: unknown): T {
  const respuesta = cuerpo as RespuestaApi;
  return (respuesta?.datos ?? cuerpo) as T;
}

describe('Gestion de accesos (e2e)', () => {
  jest.setTimeout(40_000);
  let aplicacion: INestApplication;
  const prisma = obtenerPrismaPruebas();

  beforeAll(async () => {
    aplicacion = await crearAplicacionE2e();
  });

  afterAll(async () => {
    await aplicacion.close();
  });

  it('permite a estudiante listar solo grupos donde tiene membresia activa', async () => {
    const admin = await crearUsuarioPrueba(RolUsuario.ADMINISTRADOR, true);
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const estudianteExterno = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);

    const sesionAdmin = await iniciarSesionE2e(aplicacion, admin.correo, admin.contrasena);
    const sesionEstudiante = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);

    const periodo = await request(aplicacion.getHttpServer())
      .post('/api/v1/periodos')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: `Periodo grupos ${Date.now()}`,
        fechaInicio: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
        fechaFin: new Date(Date.now() + 120 * 24 * 60 * 60 * 1000).toISOString(),
        activo: true,
      });
    expect(periodo.status).toBe(201);
    const idPeriodo = (datos(periodo.body) as { id: string }).id;

    const grupoVisible = await request(aplicacion.getHttpServer())
      .post('/api/v1/grupos')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: `Grupo Visible ${Date.now()}`,
        descripcion: 'Grupo visible para estudiante',
        idPeriodo,
      });
    expect(grupoVisible.status).toBe(201);
    const idGrupoVisible = (datos(grupoVisible.body) as { id: string }).id;

    const grupoOculto = await request(aplicacion.getHttpServer())
      .post('/api/v1/grupos')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: `Grupo Oculto ${Date.now()}`,
        descripcion: 'Grupo no visible para estudiante',
        idPeriodo,
      });
    expect(grupoOculto.status).toBe(201);
    const idGrupoOculto = (datos(grupoOculto.body) as { id: string }).id;

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/grupos/${idGrupoVisible}/docentes`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ idDocente: docente.id })
      .expect(201);

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/grupos/${idGrupoVisible}/estudiantes`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ idEstudiante: estudiante.id })
      .expect(201);

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/grupos/${idGrupoOculto}/estudiantes`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ idEstudiante: estudianteExterno.id })
      .expect(201);

    const listado = await request(aplicacion.getHttpServer())
      .get('/api/v1/grupos')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    expect(listado.status).toBe(200);

    const grupos = datos<Array<{ id: string }>>(listado.body);
    const ids = grupos.map((grupo) => grupo.id);
    expect(ids).toContain(idGrupoVisible);
    expect(ids).not.toContain(idGrupoOculto);

    await request(aplicacion.getHttpServer())
      .get(`/api/v1/grupos/${idGrupoVisible}`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .expect(200);

    await request(aplicacion.getHttpServer())
      .get(`/api/v1/grupos/${idGrupoOculto}`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .expect(403);
  });

  it('habilita lectura de asignaciones para superadmin/admin/docente/estudiante con alcance correcto', async () => {
    const superadmin = await crearUsuarioPrueba(RolUsuario.SUPERADMINISTRADOR, true);
    const admin = await crearUsuarioPrueba(RolUsuario.ADMINISTRADOR, true);
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const estudianteSinAcceso = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);

    const sesionSuperadmin = await iniciarSesionE2e(aplicacion, superadmin.correo, superadmin.contrasena);
    const sesionAdmin = await iniciarSesionE2e(aplicacion, admin.correo, admin.contrasena);
    const sesionDocente = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);
    const sesionEstudiante = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);
    const sesionEstudianteSinAcceso = await iniciarSesionE2e(aplicacion, estudianteSinAcceso.correo, estudianteSinAcceso.contrasena);

    const periodo = await request(aplicacion.getHttpServer())
      .post('/api/v1/periodos')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: `Periodo asignaciones ${Date.now()}`,
        fechaInicio: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
        fechaFin: new Date(Date.now() + 120 * 24 * 60 * 60 * 1000).toISOString(),
        activo: true,
      });
    expect(periodo.status).toBe(201);
    const idPeriodo = (datos(periodo.body) as { id: string }).id;

    const grupo = await request(aplicacion.getHttpServer())
      .post('/api/v1/grupos')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: `Grupo asignaciones ${Date.now()}`,
        descripcion: 'Grupo para pruebas de lectura de asignaciones',
        idPeriodo,
      });
    expect(grupo.status).toBe(201);
    const idGrupo = (datos(grupo.body) as { id: string }).id;

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/grupos/${idGrupo}/docentes`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ idDocente: docente.id })
      .expect(201);

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/grupos/${idGrupo}/estudiantes`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ idEstudiante: estudiante.id })
      .expect(201);

    await request(aplicacion.getHttpServer())
      .patch(`/api/v1/grupos/${idGrupo}/estado`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ estado: 'ACTIVO' })
      .expect(200);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        titulo: `Examen asignacion ${Date.now()}`,
        descripcion: 'Examen para lectura de asignaciones',
        modalidad: ModalidadExamen.CONTENIDO_COMPLETO,
        duracionMinutos: 25,
        permitirNavegacion: true,
        mostrarPuntaje: true,
      });
    expect(examen.status).toBe(201);
    const idExamen = (datos(examen.body) as { id: string }).id;

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${idExamen}/preguntas`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        enunciado: 'Pregunta para asignación',
        tipo: TipoPregunta.OPCION_MULTIPLE,
        puntaje: 1,
        opciones: [
          { letra: 'A', contenido: 'Correcta', esCorrecta: true, orden: 1 },
          { letra: 'B', contenido: 'Incorrecta', esCorrecta: false, orden: 2 },
        ],
      })
      .expect(201);

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${idExamen}/publicar`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .expect(201);

    const asignacion = await prisma.asignacionExamen.create({
      data: {
        idInstitucion: docente.idInstitucion as string,
        idExamen,
        idGrupo,
        idEstudiante: null,
        fechaInicio: new Date(Date.now() - 60_000),
        fechaFin: new Date(Date.now() + 60 * 60 * 1000),
        intentosMaximos: 1,
        mostrarPuntajeInmediato: true,
        mostrarRespuestasCorrectas: false,
        publicarResultadosEn: null,
        creadoPor: docente.id,
      },
    });

    const sesion = await request(aplicacion.getHttpServer())
      .post('/api/v1/sesiones')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({ idAsignacion: asignacion.id });
    expect(sesion.status).toBe(201);
    const idSesion = (datos(sesion.body) as { id: string }).id;

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/sesiones/${idSesion}/activar`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .expect(201);

    const sesionesEstudiante = await request(aplicacion.getHttpServer())
      .get('/api/v1/sesiones')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    expect(sesionesEstudiante.status).toBe(200);
    const listaSesionesEstudiante = datos<Array<{ id: string }>>(sesionesEstudiante.body);
    expect(listaSesionesEstudiante.map((item) => item.id)).toContain(idSesion);

    const sesionesSinAcceso = await request(aplicacion.getHttpServer())
      .get('/api/v1/sesiones')
      .set('Authorization', `Bearer ${sesionEstudianteSinAcceso.tokenAcceso}`);
    expect(sesionesSinAcceso.status).toBe(200);
    const listaSesionesSinAcceso = datos<Array<{ id: string }>>(sesionesSinAcceso.body);
    expect(listaSesionesSinAcceso.map((item) => item.id)).not.toContain(idSesion);

    const listadoSuperadmin = await request(aplicacion.getHttpServer())
      .get('/api/v1/asignaciones')
      .set('Authorization', `Bearer ${sesionSuperadmin.tokenAcceso}`);
    expect(listadoSuperadmin.status).toBe(200);

    const listadoAdmin = await request(aplicacion.getHttpServer())
      .get('/api/v1/asignaciones')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`);
    expect(listadoAdmin.status).toBe(200);

    const listadoDocente = await request(aplicacion.getHttpServer())
      .get('/api/v1/asignaciones')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`);
    expect(listadoDocente.status).toBe(200);

    const listadoEstudiante = await request(aplicacion.getHttpServer())
      .get('/api/v1/asignaciones')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    expect(listadoEstudiante.status).toBe(200);
    const asignacionesEstudiante = datos<Array<{ id: string }>>(listadoEstudiante.body);
    expect(asignacionesEstudiante.map((item) => item.id)).toContain(asignacion.id);

    await request(aplicacion.getHttpServer())
      .get(`/api/v1/asignaciones/${asignacion.id}`)
      .set('Authorization', `Bearer ${sesionSuperadmin.tokenAcceso}`)
      .expect(200);

    await request(aplicacion.getHttpServer())
      .get(`/api/v1/asignaciones/${asignacion.id}`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .expect(200);

    await request(aplicacion.getHttpServer())
      .get(`/api/v1/asignaciones/${asignacion.id}`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .expect(200);

    await request(aplicacion.getHttpServer())
      .get(`/api/v1/asignaciones/${asignacion.id}`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .expect(200);

    await request(aplicacion.getHttpServer())
      .get(`/api/v1/asignaciones/${asignacion.id}`)
      .set('Authorization', `Bearer ${sesionEstudianteSinAcceso.tokenAcceso}`)
      .expect(403);
  });
});
