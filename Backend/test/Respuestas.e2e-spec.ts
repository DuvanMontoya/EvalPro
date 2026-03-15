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
        modalidad: ModalidadExamen.CONTENIDO_COMPLETO,
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
    expect(segundoIntento.body?.datos?.intentoExistente?.id).toBe(primerIntento.body?.datos?.id);
  });

  it('bloquea inicio de intento cuando el reporte de integridad marca riesgo crítico', async () => {
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const sesionDocente = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);
    const sesionEstudiante = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        titulo: 'Examen integridad',
        descripcion: 'Control de bloqueo por riesgo',
        modalidad: ModalidadExamen.CONTENIDO_COMPLETO,
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
        enunciado: 'Integridad 1 + 1',
        tipo: TipoPregunta.OPCION_MULTIPLE,
        puntaje: 1,
        opciones: [
          { letra: 'A', contenido: '1', esCorrecta: false, orden: 1 },
          { letra: 'B', contenido: '2', esCorrecta: true, orden: 2 },
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
    const codigoAcceso = datosActivacion?.codigoAcceso as string;

    const intentoBloqueado = await request(aplicacion.getHttpServer())
      .post('/api/v1/intentos')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({
        idSesion,
        codigoAcceso,
        integridadDispositivo: {
          plataforma: 'ANDROID',
          rootDetectado: true,
          bloqueoEstrictoDisponible: true,
          bloqueoEstrictoActivo: true,
          lockTaskActivo: true,
          lockTaskPermitido: true,
          dispositivoPropietario: true,
          puntajeIntegridad: 10,
          razonesRiesgo: ['ROOT_O_JAILBREAK_DETECTADO'],
          timestamp: new Date().toISOString(),
        },
      });

    expect(intentoBloqueado.status).toBe(403);
    expect(intentoBloqueado.body?.codigoError).toBe('DISPOSITIVO_NO_SEGURO');
    expect(intentoBloqueado.body?.datos?.razonesRiesgo).toContain('ROOT_O_JAILBREAK_DETECTADO');

    const intentosPersistidos = await prisma.intentoExamen.count({
      where: {
        sesionId: idSesion,
        estudianteId: estudiante.id,
      },
    });
    expect(intentosPersistidos).toBe(0);
  });

  it('sirve hoja de respuestas sin exponer enunciados y respetando el orden persistido del intento', async () => {
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);
    const sesionDocente = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);
    const sesionEstudiante = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        titulo: 'Examen cuadernillo físico',
        descripcion: 'No debe filtrar enunciados',
        modalidad: ModalidadExamen.SOLO_RESPUESTAS,
        duracionMinutos: 25,
        permitirNavegacion: true,
        mostrarPuntaje: true,
      });
    const datosExamen = examen.body?.datos ?? examen.body;
    expect(examen.status).toBe(201);

    const preguntasBase = [
      { enunciado: 'Pregunta completa A', correcta: 'A' },
      { enunciado: 'Pregunta completa B', correcta: 'B' },
      { enunciado: 'Pregunta completa C', correcta: 'C' },
    ];

    for (let indice = 0; indice < preguntasBase.length; indice += 1) {
      const pregunta = preguntasBase[indice]!;
      const respuestaPregunta = await request(aplicacion.getHttpServer())
        .post(`/api/v1/examenes/${datosExamen?.id}/preguntas`)
        .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
        .send({
          enunciado: pregunta.enunciado,
          tipo: TipoPregunta.OPCION_MULTIPLE,
          puntaje: 1,
          opciones: [
            { letra: 'A', contenido: `Opcion A ${indice}`, esCorrecta: pregunta.correcta === 'A', orden: 1 },
            { letra: 'B', contenido: `Opcion B ${indice}`, esCorrecta: pregunta.correcta === 'B', orden: 2 },
            { letra: 'C', contenido: `Opcion C ${indice}`, esCorrecta: pregunta.correcta === 'C', orden: 3 },
            { letra: 'D', contenido: `Opcion D ${indice}`, esCorrecta: false, orden: 4 },
          ],
        });
      expect(respuestaPregunta.status).toBe(201);
    }

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${datosExamen?.id}/publicar`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .expect(201);

    const sesion = await request(aplicacion.getHttpServer())
      .post('/api/v1/sesiones')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({ idExamen: datosExamen?.id });
    const datosSesion = sesion.body?.datos ?? sesion.body;
    expect(sesion.status).toBe(201);

    const activacion = await request(aplicacion.getHttpServer())
      .post(`/api/v1/sesiones/${datosSesion?.id}/activar`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`);
    const datosActivacion = activacion.body?.datos ?? activacion.body;
    expect(activacion.status).toBe(201);

    const busqueda = await request(aplicacion.getHttpServer())
      .get(`/api/v1/sesiones/buscar/${datosActivacion?.codigoAcceso}`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    expect(busqueda.status).toBe(200);
    expect(busqueda.body?.datos?.examen?.preguntas).toBeUndefined();
    expect(busqueda.body?.datos?.examen?.identificadorCuadernillo).toContain('CUAD-');

    const intento = await request(aplicacion.getHttpServer())
      .post('/api/v1/intentos')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({ idSesion: datosSesion?.id, codigoAcceso: datosActivacion?.codigoAcceso });
    const datosIntento = intento.body?.datos ?? intento.body;
    expect(intento.status).toBe(201);

    const intentoPersistido = await prisma.intentoExamen.findUnique({
      where: { id: datosIntento?.id },
      select: { ordenPreguntasAplicado: true },
    });
    const idsPersistidos =
      (
        intentoPersistido?.ordenPreguntasAplicado as
          | { preguntas?: Array<{ idPregunta?: string }> }
          | null
          | undefined
      )?.preguntas
        ?.map((pregunta) => pregunta.idPregunta ?? '')
        .filter((idPregunta) => idPregunta.length > 0) ?? [];

    const examenIntento = await request(aplicacion.getHttpServer())
      .get(`/api/v1/intentos/${datosIntento?.id}/examen`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    const datosExamenIntento = examenIntento.body?.datos ?? examenIntento.body;
    expect(examenIntento.status).toBe(200);
    expect(datosExamenIntento?.examen?.identificadorCuadernillo).toContain('CUAD-');
    expect(datosExamenIntento?.examen?.preguntas?.map((pregunta: { id: string }) => pregunta.id)).toEqual(idsPersistidos);
    expect(datosExamenIntento?.examen?.preguntas?.every((pregunta: { enunciado: string }) => pregunta.enunciado === '')).toBe(true);
    expect(
      datosExamenIntento?.examen?.preguntas?.every((pregunta: { opciones: Array<{ contenido: string }> }) =>
        pregunta.opciones.every((opcion) => opcion.contenido === ''),
      ),
    ).toBe(true);
  });

  it('mantiene búsqueda disponible con intento en progreso y agota intentos solo tras envío', async () => {
    const admin = await crearUsuarioPrueba(RolUsuario.ADMINISTRADOR, true);
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);

    const sesionAdmin = await iniciarSesionE2e(aplicacion, admin.correo, admin.contrasena);
    const sesionDocente = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);
    const sesionEstudiante = await iniciarSesionE2e(aplicacion, estudiante.correo, estudiante.contrasena);

    const periodo = await request(aplicacion.getHttpServer())
      .post('/api/v1/periodos')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: `Periodo busqueda ${Date.now()}`,
        fechaInicio: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
        fechaFin: new Date(Date.now() + 120 * 24 * 60 * 60 * 1000).toISOString(),
        activo: true,
      });
    const datosPeriodo = periodo.body?.datos ?? periodo.body;
    expect(periodo.status).toBe(201);

    const grupo = await request(aplicacion.getHttpServer())
      .post('/api/v1/grupos')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: `Grupo busqueda ${Date.now()}`,
        descripcion: 'Grupo para validar busqueda con intento en progreso',
        idPeriodo: datosPeriodo?.id,
      });
    const datosGrupo = grupo.body?.datos ?? grupo.body;
    expect(grupo.status).toBe(201);

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/grupos/${datosGrupo?.id}/docentes`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ idDocente: docente.id })
      .expect(201);

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/grupos/${datosGrupo?.id}/estudiantes`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ idEstudiante: estudiante.id })
      .expect(201);

    await request(aplicacion.getHttpServer())
      .patch(`/api/v1/grupos/${datosGrupo?.id}/estado`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ estado: 'ACTIVO' })
      .expect(200);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        titulo: `Examen busqueda ${Date.now()}`,
        descripcion: 'Control de intentos en busqueda',
        modalidad: ModalidadExamen.CONTENIDO_COMPLETO,
        duracionMinutos: 20,
        permitirNavegacion: true,
        mostrarPuntaje: true,
      });
    const datosExamen = examen.body?.datos ?? examen.body;
    expect(examen.status).toBe(201);

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${datosExamen?.id}/preguntas`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        enunciado: 'Pregunta de control',
        tipo: TipoPregunta.OPCION_MULTIPLE,
        puntaje: 1,
        opciones: [
          { letra: 'A', contenido: 'Correcta', esCorrecta: true, orden: 1 },
          { letra: 'B', contenido: 'Incorrecta', esCorrecta: false, orden: 2 },
        ],
      })
      .expect(201);

    await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${datosExamen?.id}/publicar`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .expect(201);

    const asignacion = await prisma.asignacionExamen.create({
      data: {
        idInstitucion: docente.idInstitucion as string,
        idExamen: datosExamen?.id,
        idGrupo: datosGrupo?.id,
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
    const datosSesion = sesion.body?.datos ?? sesion.body;
    expect(sesion.status).toBe(201);

    const activacion = await request(aplicacion.getHttpServer())
      .post(`/api/v1/sesiones/${datosSesion?.id}/activar`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`);
    const datosActivacion = activacion.body?.datos ?? activacion.body;
    expect(activacion.status).toBe(201);
    const codigoAcceso = datosActivacion?.codigoAcceso as string;

    const busquedaInicial = await request(aplicacion.getHttpServer())
      .get(`/api/v1/sesiones/buscar/${codigoAcceso}`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    expect(busquedaInicial.status).toBe(200);
    expect(busquedaInicial.body?.datos?.intentosPrevios).toBe(0);

    const primerIntento = await request(aplicacion.getHttpServer())
      .post('/api/v1/intentos')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({ idSesion: datosSesion?.id, codigoAcceso });
    const datosPrimerIntento = primerIntento.body?.datos ?? primerIntento.body;
    expect(primerIntento.status).toBe(201);

    const busquedaConIntentoEnProgreso = await request(aplicacion.getHttpServer())
      .get(`/api/v1/sesiones/buscar/${codigoAcceso}`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    expect(busquedaConIntentoEnProgreso.status).toBe(200);
    expect(busquedaConIntentoEnProgreso.body?.datos?.intentosPrevios).toBe(0);

    const intentoDuplicado = await request(aplicacion.getHttpServer())
      .post('/api/v1/intentos')
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`)
      .send({ idSesion: datosSesion?.id, codigoAcceso });
    expect(intentoDuplicado.status).toBe(409);
    expect(intentoDuplicado.body?.codigoError).toBe('INTENTO_DUPLICADO');
    expect(intentoDuplicado.body?.datos?.intentoExistente?.id).toBe(datosPrimerIntento?.id);

    const finalizacion = await request(aplicacion.getHttpServer())
      .post(`/api/v1/intentos/${datosPrimerIntento?.id}/finalizar`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    expect(finalizacion.status).toBe(201);

    const busquedaTrasFinalizar = await request(aplicacion.getHttpServer())
      .get(`/api/v1/sesiones/buscar/${codigoAcceso}`)
      .set('Authorization', `Bearer ${sesionEstudiante.tokenAcceso}`);
    expect(busquedaTrasFinalizar.status).toBe(403);
    expect(busquedaTrasFinalizar.body?.codigoError).toBe('INTENTOS_AGOTADOS');
  });

  it('rechaza activar sesión antes de la ventana de asignación', async () => {
    const admin = await crearUsuarioPrueba(RolUsuario.ADMINISTRADOR, true);
    const docente = await crearUsuarioPrueba(RolUsuario.DOCENTE, true);
    const estudiante = await crearUsuarioPrueba(RolUsuario.ESTUDIANTE, true);

    const sesionAdmin = await iniciarSesionE2e(aplicacion, admin.correo, admin.contrasena);
    const sesionDocente = await iniciarSesionE2e(aplicacion, docente.correo, docente.contrasena);

    const fechaInicioPeriodo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    const fechaFinPeriodo = new Date(Date.now() + 120 * 24 * 60 * 60 * 1000).toISOString();
    const periodo = await request(aplicacion.getHttpServer())
      .post('/api/v1/periodos')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: `Periodo ventana ${Date.now()}`,
        fechaInicio: fechaInicioPeriodo,
        fechaFin: fechaFinPeriodo,
        activo: true,
      });
    const datosPeriodo = periodo.body?.datos ?? periodo.body;
    expect(periodo.status).toBe(201);

    const grupo = await request(aplicacion.getHttpServer())
      .post('/api/v1/grupos')
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({
        nombre: `Grupo ventana ${Date.now()}`,
        descripcion: 'Grupo para validar ventana de activación',
        idPeriodo: datosPeriodo?.id,
      });
    const datosGrupo = grupo.body?.datos ?? grupo.body;
    expect(grupo.status).toBe(201);

    const asignarDocente = await request(aplicacion.getHttpServer())
      .post(`/api/v1/grupos/${datosGrupo?.id}/docentes`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ idDocente: docente.id });
    expect(asignarDocente.status).toBe(201);

    const asignarEstudiante = await request(aplicacion.getHttpServer())
      .post(`/api/v1/grupos/${datosGrupo?.id}/estudiantes`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ idEstudiante: estudiante.id });
    expect(asignarEstudiante.status).toBe(201);

    const activarGrupo = await request(aplicacion.getHttpServer())
      .patch(`/api/v1/grupos/${datosGrupo?.id}/estado`)
      .set('Authorization', `Bearer ${sesionAdmin.tokenAcceso}`)
      .send({ estado: 'ACTIVO' });
    expect(activarGrupo.status).toBe(200);

    const examen = await request(aplicacion.getHttpServer())
      .post('/api/v1/examenes')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        titulo: `Examen ventana ${Date.now()}`,
        descripcion: 'Validación de activación por ventana',
        modalidad: ModalidadExamen.CONTENIDO_COMPLETO,
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
        enunciado: 'Pregunta de control ventana',
        tipo: TipoPregunta.OPCION_MULTIPLE,
        puntaje: 1,
        opciones: [
          { letra: 'A', contenido: 'Correcta', esCorrecta: true, orden: 1 },
          { letra: 'B', contenido: 'Incorrecta', esCorrecta: false, orden: 2 },
        ],
      });
    expect(pregunta.status).toBe(201);

    const publicarExamen = await request(aplicacion.getHttpServer())
      .post(`/api/v1/examenes/${idExamen}/publicar`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`);
    expect(publicarExamen.status).toBe(201);

    const fechaInicioAsignacion = new Date(Date.now() + 60 * 1000).toISOString();
    const fechaFinAsignacion = new Date(Date.now() + 20 * 60 * 1000).toISOString();
    const asignacion = await request(aplicacion.getHttpServer())
      .post('/api/v1/asignaciones')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({
        idExamen,
        idGrupo: datosGrupo?.id,
        fechaInicio: fechaInicioAsignacion,
        fechaFin: fechaFinAsignacion,
        intentosMaximos: 1,
        mostrarPuntajeInmediato: true,
        mostrarRespuestasCorrectas: false,
      });
    const datosAsignacion = asignacion.body?.datos ?? asignacion.body;
    expect(asignacion.status).toBe(201);

    const sesion = await request(aplicacion.getHttpServer())
      .post('/api/v1/sesiones')
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`)
      .send({ idAsignacion: datosAsignacion?.id });
    const datosSesion = sesion.body?.datos ?? sesion.body;
    expect(sesion.status).toBe(201);

    const activacionTemprana = await request(aplicacion.getHttpServer())
      .post(`/api/v1/sesiones/${datosSesion?.id}/activar`)
      .set('Authorization', `Bearer ${sesionDocente.tokenAcceso}`);
    expect(activacionTemprana.status).toBe(403);
    expect(String(activacionTemprana.body?.mensaje ?? '')).toContain('ventana de asignación');
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
        modalidad: ModalidadExamen.CONTENIDO_COMPLETO,
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
