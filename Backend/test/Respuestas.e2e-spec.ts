/**
 * @archivo   Respuestas.e2e-spec.ts
 * @descripcion Valida sincronización, duplicados y calificación de intentos del flujo estudiantil.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication } from '@nestjs/common';
import { ModalidadExamen, RolUsuario, TipoPregunta } from '@prisma/client';
import { afterAll, beforeAll, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import { crearAplicacionE2e, crearUsuarioPrueba, iniciarSesionE2e, obtenerPrismaPruebas } from './UtilidadesPruebasE2e';

describe('Respuestas (e2e)', () => {
  jest.setTimeout(30_000);
  let aplicacion: INestApplication;
  const prisma = obtenerPrismaPruebas();

  beforeAll(async () => {
    aplicacion = await crearAplicacionE2e();
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

  it('rechaza intento duplicado en la misma sesión con código estándar', async () => {
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const sesionDocente = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);
    const sesionEstudiante = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        titulo: 'Examen duplicado intento',
        descripcion: 'Control de duplicados',
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
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        enunciado: '2 + 2 = ?',
        tipo: TipoPregunta.OPCION_MULTIPLE,
        puntaje: 1,
        opciones: [
          { letra: 'A', contenido: '3', esCorrecta: false, orden: 1 },
          { letra: 'B', contenido: '4', esCorrecta: true, orden: 2 },
        ],
      });
    expect(pregunta.status).toBe(201);

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
    const datosActivacion = activacion.body?.datos ?? activacion.body;
    const codigoAcceso = datosActivacion?.codigoAcceso;
    const primerIntento = await request(aplicacion.getHttpServer())
      .post('/api/v1/intentos')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({ idSesion, codigoAcceso });
    expect(primerIntento.status).toBe(201);

    const segundoIntento = await request(aplicacion.getHttpServer())
      .post('/api/v1/intentos')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({ idSesion, codigoAcceso });
    expect(segundoIntento.status).toBe(409);
    expect(segundoIntento.body?.codigoError).toBe('INTENTO_DUPLICADO');
  });

  it('finaliza intento calculando puntaje y deja preguntas abiertas en calificación manual', async () => {
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const sesionDocente = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);
    const sesionEstudiante = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        titulo: 'Examen calificación mixta',
        descripcion: 'Cierre con abierta',
        modalidad: ModalidadExamen.DIGITAL_COMPLETO,
        duracionMinutos: 20,
        permitirNavegacion: true,
        mostrarPuntaje: true,
      });
    const datosExamen = examen.body?.datos ?? examen.body;
    const idExamen = datosExamen?.id;
    expect(examen.status).toBe(201);

    const preguntaCerrada = await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${idExamen}/preguntas`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        enunciado: 'Capital de Francia',
        tipo: TipoPregunta.OPCION_MULTIPLE,
        puntaje: 2,
        opciones: [
          { letra: 'A', contenido: 'París', esCorrecta: true, orden: 1 },
          { letra: 'B', contenido: 'Roma', esCorrecta: false, orden: 2 },
        ],
      });
    expect(preguntaCerrada.status).toBe(201);
    const datosPreguntaCerrada = preguntaCerrada.body?.datos ?? preguntaCerrada.body;
    const preguntaAbierta = await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${idExamen}/preguntas`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        enunciado: 'Explica la fotosíntesis',
        tipo: TipoPregunta.RESPUESTA_ABIERTA,
        puntaje: 3,
      });
    expect(preguntaAbierta.status).toBe(201);
    const datosPreguntaAbierta = preguntaAbierta.body?.datos ?? preguntaAbierta.body;

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
    const datosActivacion = activacion.body?.datos ?? activacion.body;
    const codigoAcceso = datosActivacion?.codigoAcceso;
    const intento = await request(aplicacion.getHttpServer())
      .post('/api/v1/intentos')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({ idSesion, codigoAcceso });
    const datosIntento = intento.body?.datos ?? intento.body;
    const idIntento = datosIntento?.id;
    expect(intento.status).toBe(201);

    const sincronizacion = await request(aplicacion.getHttpServer())
      .post('/api/v1/respuestas/sincronizar-lote')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({
        idIntento,
        respuestas: [
          { idPregunta: datosPreguntaCerrada?.id, opcionesSeleccionadas: ['A'] },
          { idPregunta: datosPreguntaAbierta?.id, valorTexto: 'Respuesta libre', opcionesSeleccionadas: [] },
        ],
      });
    expect(sincronizacion.status).toBe(201);

    const finalizacion = await request(aplicacion.getHttpServer())
      .post(`/api/v1/intentos/${idIntento}/finalizar`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    const datosFinalizacion = finalizacion.body?.datos ?? finalizacion.body;
    expect(finalizacion.status).toBe(201);
    expect(datosFinalizacion?.puntajeObtenido).toBe(2);
    expect(datosFinalizacion?.porcentaje).toBe(40);

    const respuestaAbiertaDb = await prisma.respuesta.findUnique({
      where: {
        intentoId_preguntaId: {
          intentoId: idIntento,
          preguntaId: datosPreguntaAbierta?.id,
        },
      },
    });
    expect(respuestaAbiertaDb?.esCorrecta).toBeNull();
  });
});
