/**
 * @archivo   ReportesCalificacion.e2e-spec.ts
 * @descripcion Verifica alcance de reportes por docente y calificación manual de respuestas abiertas.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication } from '@nestjs/common';
import { ModalidadExamen, RolUsuario, TipoPregunta } from '@prisma/client';
import { afterAll, beforeAll, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import { crearAplicacionE2e, crearUsuarioPrueba, iniciarSesionE2e, obtenerPrismaPruebas } from './UtilidadesPruebasE2e';

describe('Reportes y Calificación (e2e)', () => {
  jest.setTimeout(30_000);
  let aplicacion: INestApplication;
  const prisma = obtenerPrismaPruebas();

  beforeAll(async () => {
    aplicacion = await crearAplicacionE2e();
  });

  afterAll(async () => {
    await aplicacion.close();
  });

  it('bloquea a un docente para consultar reporte de estudiante fuera de sus sesiones', async () => {
    const docentePropietario = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const docenteExterno = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const sesionPropietario = await iniciarSesionE2e(aplicacion, docentePropietario.correo, docentePropietario.contrasena);
    const sesionExterno = await iniciarSesionE2e(aplicacion, docenteExterno.correo, docenteExterno.contrasena);
    const sesionEstudiante = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionPropietario.tokenAcceso}`)
      .send({
        titulo: 'Examen alcance reportes',
        descripcion: 'Control de alcance docente',
        modalidad: ModalidadExamen.DIGITAL_COMPLETO,
        duracionMinutos: 20,
        permitirNavegacion: true,
        mostrarPuntaje: true,
      });
    const datosExamen = examen.body?.datos ?? examen.body;
    const idExamen = datosExamen?.id;
    expect(examen.status).toBe(201);
    const pregunta = await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${idExamen}/preguntas`)
      .set('Authorization', `Bearer ${sesionPropietario.tokenAcceso}`)
      .send({
        enunciado: 'Pregunta alcance',
        tipo: TipoPregunta.OPCION_MULTIPLE,
        puntaje: 1,
        opciones: [
          { letra: 'A', contenido: 'Sí', esCorrecta: true, orden: 1 },
          { letra: 'B', contenido: 'No', esCorrecta: false, orden: 2 },
        ],
      });
    expect(pregunta.status).toBe(201);
    const publicacion = await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${idExamen}/publicar`)
      .set('Authorization', `Bearer ${sesionPropietario.tokenAcceso}`);
    expect(publicacion.status).toBe(201);
    const sesion = await request(aplicacion.getHttpServer())
      .post('/api/v1/sesiones')
      .set('Authorization', `Bearer ${sesionPropietario.tokenAcceso}`)
      .send({ idExamen });
    const datosSesion = sesion.body?.datos ?? sesion.body;
    const idSesion = datosSesion?.id;
    expect(sesion.status).toBe(201);
    const activacion = await request(aplicacion.getHttpServer())
      .post(`/api/v1/sesiones/${idSesion}/activar`)
      .set('Authorization', `Bearer ${sesionPropietario.tokenAcceso}`);
    expect(activacion.status).toBe(201);
    const intento = await request(aplicacion.getHttpServer())
      .post('/api/v1/intentos')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({ idSesion });
    expect(intento.status).toBe(201);

    const reporte = await request(aplicacion.getHttpServer())
      .get(`/api/v1/reportes/estudiante/${estudiante.id}`)
      .set('Authorization', `Bearer ${sesionExterno.tokenAcceso}`);

    expect(reporte.status).toBe(403);
  });

  it('permite calificación manual de abierta y recalcula puntaje del intento', async () => {
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const sesionDocente = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);
    const sesionEstudiante = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        titulo: 'Examen abierta manual',
        descripcion: 'Calificación manual',
        modalidad: ModalidadExamen.DIGITAL_COMPLETO,
        duracionMinutos: 20,
        permitirNavegacion: true,
        mostrarPuntaje: true,
      });
    const datosExamen = examen.body?.datos ?? examen.body;
    const idExamen = datosExamen?.id;
    expect(examen.status).toBe(201);

    const preguntaAbierta = await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${idExamen}/preguntas`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        enunciado: 'Describe un algoritmo de ordenamiento',
        tipo: TipoPregunta.RESPUESTA_ABIERTA,
        puntaje: 5,
      });
    const datosPreguntaAbierta = preguntaAbierta.body?.datos ?? preguntaAbierta.body;
    const idPreguntaAbierta = datosPreguntaAbierta?.id;
    expect(preguntaAbierta.status).toBe(201);

    const publicacion = await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${idExamen}/publicar`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`);
    expect(publicacion.status).toBe(201);
    const sesion = await request(aplicacion.getHttpServer())
      .post('/api/v1/sesiones')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({ idExamen });
    const datosSesion = sesion.body?.datos ?? sesion.body;
    const idSesion = datosSesion?.id;
    expect(sesion.status).toBe(201);
    const activacion = await request(aplicacion.getHttpServer())
      .post(`/api/v1/sesiones/${idSesion}/activar`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`);
    expect(activacion.status).toBe(201);

    const intento = await request(aplicacion.getHttpServer())
      .post('/api/v1/intentos')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({ idSesion });
    const datosIntento = intento.body?.datos ?? intento.body;
    const idIntento = datosIntento?.id;
    expect(intento.status).toBe(201);

    const sincronizacion = await request(aplicacion.getHttpServer())
      .post('/api/v1/respuestas/sincronizar-lote')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({
        idIntento,
        respuestas: [{ idPregunta: idPreguntaAbierta, valorTexto: 'Merge sort', opcionesSeleccionadas: [] }],
      });
    expect(sincronizacion.status).toBe(201);
    const finalizacion = await request(aplicacion.getHttpServer())
      .post(`/api/v1/intentos/${idIntento}/finalizar`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    expect(finalizacion.status).toBe(201);

    const respuesta = await prisma.respuesta.findUnique({
      where: { intentoId_preguntaId: { intentoId: idIntento, preguntaId: idPreguntaAbierta } },
    });
    const calificacion = await request(aplicacion.getHttpServer())
      .patch(`/api/v1/respuestas/${respuesta?.id}/calificar-manual`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({ puntajeObtenido: 4.5, observacion: 'Respuesta parcialmente correcta' });
    const datos = calificacion.body?.datos ?? calificacion.body;

    expect(calificacion.status).toBe(200);
    expect(datos?.puntajeIntento).toBe(4.5);
    expect(datos?.porcentajeIntento).toBe(90);
  });
});
