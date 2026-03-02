/**
 * @archivo   Telemetria.e2e-spec.ts
 * @descripcion Valida reglas de autorización y marcación de sospecha en eventos de telemetría.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication } from '@nestjs/common';
import { ModalidadExamen, RolUsuario, TipoEventoTelemetria, TipoPregunta } from '@prisma/client';
import { afterAll, beforeAll, describe, expect, it, jest } from '@jest/globals';
import request from 'supertest';
import { crearAplicacionE2e, crearUsuarioPrueba, iniciarSesionE2e, obtenerPrismaPruebas } from './UtilidadesPruebasE2e';

describe('Telemetria (e2e)', () => {
  jest.setTimeout(30_000);
  let aplicacion: INestApplication;
  const prisma = obtenerPrismaPruebas();

  beforeAll(async () => {
    aplicacion = await crearAplicacionE2e();
  });

  afterAll(async () => {
    await aplicacion.close();
  });

  it('rechaza consulta de telemetría para rol estudiante', async () => {
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const sesionEstudiante = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);

    const respuesta = await request(aplicacion.getHttpServer())
      .get('/api/v1/intentos/00000000-0000-0000-0000-000000000000/telemetria')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);

    expect(respuesta.status).toBe(403);
  });

  it('marca sospechoso al registrar evento crítico y bloquea intento ajeno', async () => {
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudianteUno = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const estudianteDos = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const sesionDocente = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);
    const sesionEstudianteUno = await iniciarSesionE2e(aplicacion, estudianteUno.correo, estudianteUno.contrasena);
    const sesionEstudianteDos = await iniciarSesionE2e(aplicacion, estudianteDos.correo, estudianteDos.contrasena);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        titulo: 'Examen telemetría',
        descripcion: 'Fraude crítico',
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
        enunciado: '2 + 3',
        tipo: TipoPregunta.OPCION_MULTIPLE,
        puntaje: 1,
        opciones: [
          { letra: 'A', contenido: '5', esCorrecta: true, orden: 1 },
          { letra: 'B', contenido: '6', esCorrecta: false, orden: 2 },
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

    const intentoUno = await request(aplicacion.getHttpServer())
      .post('/api/v1/intentos')
      .set('Authorization', `Bearer ${sesionEstudianteUno.tokenAcceso}`)
      .send({ idSesion, codigoAcceso });
    const datosIntentoUno = intentoUno.body?.datos ?? intentoUno.body;
    const idIntentoUno = datosIntentoUno?.id;
    expect(intentoUno.status).toBe(201);

    const intentoAjeno = await request(aplicacion.getHttpServer())
      .post('/api/v1/telemetria')
      .set('Authorization', `Bearer ${sesionEstudianteDos.tokenAcceso}`)
      .send({
        idIntento: idIntentoUno,
        tipo: TipoEventoTelemetria.APLICACION_EN_SEGUNDO_PLANO,
      });
    expect(intentoAjeno.status).toBe(403);

    const eventoCritico = await request(aplicacion.getHttpServer())
      .post('/api/v1/telemetria')
      .set('Authorization', `Bearer ${sesionEstudianteUno.tokenAcceso}`)
      .send({
        idIntento: idIntentoUno,
        tipo: TipoEventoTelemetria.APLICACION_EN_SEGUNDO_PLANO,
        descripcion: 'Se envió la app a segundo plano',
      });
    expect(eventoCritico.status).toBe(201);

    const intentoActualizado = await prisma.intentoExamen.findUnique({ where: { id: idIntentoUno } });
    expect(intentoActualizado?.esSospechoso).toBe(true);
    expect(String(intentoActualizado?.razonSospecha ?? '')).toContain('segundo plano');
  });
});
