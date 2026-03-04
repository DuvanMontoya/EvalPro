/**
 * @archivo   verificacion-e2e-integral.ts
 * @descripcion Ejecuta una verificación integral del flujo de negocio completo en entorno real.
 * @modulo    Scripts
 * @autor     EvalPro
 * @fecha     2026-03-03
 */
const API_BASE = process.env.API_BASE_VERIFICACION ?? 'http://localhost:3001/api/v1';

interface RespuestaApi<T> {
  exito: boolean;
  datos: T | null;
  mensaje: string;
  codigoError?: string;
}

interface SesionAutenticada {
  tokenAcceso: string;
  tokenRefresh: string;
  usuario: {
    id: string;
    rol: string;
    idInstitucion: string | null;
    correo: string;
  };
}

interface PrimerLogin {
  requiereCambioContrasena: true;
  tokenTemporal: string;
}

function assertOrThrow(condicion: unknown, mensaje: string): asserts condicion {
  if (!condicion) {
    throw new Error(mensaje);
  }
}

function ahoraIsoMas(segundos: number): string {
  return new Date(Date.now() + segundos * 1000).toISOString();
}

function construirCorreo(etiqueta: string, sufijo: string): string {
  return `${etiqueta}.${sufijo}@evalpro-e2e.local`;
}

async function solicitud<T>(
  ruta: string,
  opciones: RequestInit = {},
  esperado: number | number[] = [200, 201],
): Promise<{ estado: number; datos: T | null; cuerpo: unknown }> {
  const respuesta = await fetch(`${API_BASE}${ruta}`, {
    ...opciones,
    headers: {
      'Content-Type': 'application/json',
      ...(opciones.headers ?? {}),
    },
  });

  const cuerpo = (await respuesta.json().catch(() => null)) as RespuestaApi<T> | null;
  const esperados = Array.isArray(esperado) ? esperado : [esperado];
  if (!esperados.includes(respuesta.status)) {
    throw new Error(
      `HTTP inesperado en ${ruta}: esperado ${esperados.join(',')}, recibido ${respuesta.status} - ${JSON.stringify(cuerpo)}`,
    );
  }

  if (!cuerpo) {
    return { estado: respuesta.status, datos: null, cuerpo: null };
  }

  if (!cuerpo.exito) {
    return { estado: respuesta.status, datos: null, cuerpo };
  }

  return { estado: respuesta.status, datos: cuerpo.datos as T, cuerpo };
}

async function iniciarSesionConFlujoPrimerLogin(
  correo: string,
  contrasena: string,
  nuevaContrasena: string,
): Promise<SesionAutenticada> {
  const inicio = await solicitud<SesionAutenticada | PrimerLogin>('/autenticacion/iniciar-sesion', {
    method: 'POST',
    body: JSON.stringify({ correo, contrasena }),
  });

  const datosInicio = inicio.datos;
  assertOrThrow(datosInicio, `No se obtuvo respuesta de sesión para ${correo}`);

  if ('requiereCambioContrasena' in datosInicio && datosInicio.requiereCambioContrasena) {
    const cambio = await solicitud<SesionAutenticada>('/autenticacion/cambiar-contrasena', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${datosInicio.tokenTemporal}`,
      },
      body: JSON.stringify({ nuevaContrasena }),
    });

    assertOrThrow(cambio.datos, `No se pudo completar primer login para ${correo}`);
    return cambio.datos;
  }

  return datosInicio as SesionAutenticada;
}

async function ejecutarVerificacionIntegral(): Promise<void> {
  const sufijo = `${Date.now().toString(36)}${Math.random().toString(36).slice(2, 6)}`;
  const violacionesDetectadas: string[] = [];
  const superadminCorreo = process.env.SUPERADMIN_CORREO_INICIAL ?? 'superadmin@evalpro.com';
  const superadminContrasena = process.env.SUPERADMIN_CONTRASENA_INICIAL ?? 'Gaussiano1008*';

  const adminTemporal = 'TemporalAdmin1!';
  const adminNueva = 'AdminDefinitiva1!';
  const docenteTemporal = 'TemporalDocente1!';
  const docenteNueva = 'DocenteDefinitiva1!';
  const estudianteTemporal = 'TemporalEstudiante1!';
  const estudianteNueva = 'EstudianteDefinitiva1!';

  console.log(`\n[1/16] Autenticando superadministrador (${superadminCorreo})...`);
  const sesionSuperadmin = await iniciarSesionConFlujoPrimerLogin(
    superadminCorreo,
    superadminContrasena,
    `${superadminContrasena}#`,
  );
  const tokenSuperadmin = sesionSuperadmin.tokenAcceso;

  console.log('[2/16] Creando institución...');
  const institucion = await solicitud<{ id: string; nombre: string; estado: string }>('/instituciones', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenSuperadmin}` },
    body: JSON.stringify({
      nombre: `Institucion E2E ${sufijo}`,
      dominio: `${sufijo}.evalpro-e2e.local`,
      configuracion: { origen: 'script_verificacion_integral' },
    }),
  });
  assertOrThrow(institucion.datos, 'No se pudo crear institución');

  const idInstitucion = institucion.datos.id;
  console.log(`     Institución creada: ${idInstitucion}`);

  console.log('[3/16] Creando administrador de institución...');
  const correoAdmin = construirCorreo('admin', sufijo);
  const adminCreado = await solicitud<{ id: string }>('/usuarios', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenSuperadmin}` },
    body: JSON.stringify({
      nombre: 'Admin',
      apellidos: 'E2E',
      correo: correoAdmin,
      contrasena: adminTemporal,
      rol: 'ADMINISTRADOR',
      idInstitucion,
    }),
  });
  assertOrThrow(adminCreado.datos, 'No se pudo crear administrador');

  console.log('[4/16] Autenticando administrador y creando periodo/grupo...');
  const sesionAdmin = await iniciarSesionConFlujoPrimerLogin(correoAdmin, adminTemporal, adminNueva);
  const tokenAdmin = sesionAdmin.tokenAcceso;

  const institucionesAdmin = await solicitud<Array<{ id: string }>>('/instituciones', {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
  });
  assertOrThrow((institucionesAdmin.datos?.length ?? 0) === 1, 'ADMINISTRADOR debe ver solo su institución');
  assertOrThrow(institucionesAdmin.datos?.[0]?.id === idInstitucion, 'ADMINISTRADOR no visualiza su institución correcta');

  const periodo = await solicitud<{ id: string }>('/periodos', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({
      nombre: `Periodo-${sufijo}`,
      fechaInicio: ahoraIsoMas(60),
      fechaFin: ahoraIsoMas(60 * 60 * 24 * 120),
      activo: true,
    }),
  });
  assertOrThrow(periodo.datos, 'No se pudo crear periodo');
  const idPeriodo = periodo.datos.id;

  const grupo = await solicitud<{ id: string; estado: string }>('/grupos', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({
      nombre: `Grupo-${sufijo}`,
      descripcion: 'Grupo de verificación integral',
      idPeriodo,
    }),
  });
  assertOrThrow(grupo.datos, 'No se pudo crear grupo');
  const idGrupo = grupo.datos.id;

  const periodosListado = await solicitud<Array<{ id: string }>>('/periodos', {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
  });
  assertOrThrow((periodosListado.datos?.some((item) => item.id === idPeriodo) ?? false), 'Periodo creado no aparece en listado');

  const gruposListadoInicial = await solicitud<Array<{ id: string }>>('/grupos', {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
  });
  assertOrThrow((gruposListadoInicial.datos?.some((item) => item.id === idGrupo) ?? false), 'Grupo creado no aparece en listado');

  console.log('[5/16] Creando docente y estudiante...');
  const correoDocente = construirCorreo('docente', sufijo);
  const correoEstudiante = construirCorreo('estudiante', sufijo);

  const docenteCreado = await solicitud<{ id: string }>('/usuarios', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({
      nombre: 'Docente',
      apellidos: 'E2E',
      correo: correoDocente,
      contrasena: docenteTemporal,
      rol: 'DOCENTE',
    }),
  });
  assertOrThrow(docenteCreado.datos, 'No se pudo crear docente');
  const idDocente = docenteCreado.datos.id;

  const estudianteCreado = await solicitud<{ id: string }>('/usuarios', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({
      nombre: 'Estudiante',
      apellidos: 'E2E',
      correo: correoEstudiante,
      contrasena: estudianteTemporal,
      rol: 'ESTUDIANTE',
    }),
  });
  assertOrThrow(estudianteCreado.datos, 'No se pudo crear estudiante');
  const idEstudiante = estudianteCreado.datos.id;

  const usuariosListado = await solicitud<Array<{ id: string }>>('/usuarios', {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
  });
  assertOrThrow((usuariosListado.datos?.some((item) => item.id === idDocente) ?? false), 'Docente no aparece en listado de usuarios');
  assertOrThrow((usuariosListado.datos?.some((item) => item.id === idEstudiante) ?? false), 'Estudiante no aparece en listado de usuarios');

  await solicitud(`/usuarios/${idDocente}`, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({
      nombre: 'Docente Actualizado',
      apellidos: 'E2E',
    }),
  });

  const correoEstudianteBaja = construirCorreo('estudiante-baja', sufijo);
  const estudianteBajaCreado = await solicitud<{ id: string }>('/usuarios', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({
      nombre: 'Estudiante',
      apellidos: 'Baja',
      correo: correoEstudianteBaja,
      contrasena: 'TemporalEstudianteBaja1!',
      rol: 'ESTUDIANTE',
    }),
  });
  assertOrThrow(estudianteBajaCreado.datos, 'No se pudo crear estudiante para desactivación');
  const idEstudianteBaja = estudianteBajaCreado.datos.id;

  await solicitud(`/usuarios/${idEstudianteBaja}`, {
    method: 'DELETE',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
  });

  console.log('[6/16] Activando cuentas docente/estudiante y asignándolos al grupo...');
  const sesionDocente = await iniciarSesionConFlujoPrimerLogin(correoDocente, docenteTemporal, docenteNueva);
  const sesionEstudiante = await iniciarSesionConFlujoPrimerLogin(correoEstudiante, estudianteTemporal, estudianteNueva);
  const tokenDocente = sesionDocente.tokenAcceso;
  const tokenEstudiante = sesionEstudiante.tokenAcceso;

  await solicitud(`/grupos/${idGrupo}/docentes`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({ idDocente }),
  });

  await solicitud(`/grupos/${idGrupo}/estudiantes`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({ idEstudiante }),
  });

  await solicitud(`/grupos/${idGrupo}/estado`, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({ estado: 'ACTIVO' }),
  });

  const gruposDocente = await solicitud<Array<{ id: string }>>('/grupos', {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenDocente}` },
  });
  assertOrThrow((gruposDocente.datos?.some((item) => item.id === idGrupo) ?? false), 'DOCENTE no visualiza su grupo asignado');

  await solicitud(`/periodos/${idPeriodo}/estado`, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({ activo: false }),
  });
  await solicitud(`/periodos/${idPeriodo}/estado`, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
    body: JSON.stringify({ activo: true }),
  });

  console.log('[7/16] Creando examen y preguntas (cerrada + abierta)...');
  const examen = await solicitud<{ id: string; estado: string }>('/examenes', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenDocente}` },
    body: JSON.stringify({
      titulo: `Examen Integral ${sufijo}`,
      descripcion: 'Examen para verificación e2e integral',
      instrucciones: 'Responder todas las preguntas',
      modalidad: 'DIGITAL_COMPLETO',
      duracionMinutos: 45,
      permitirNavegacion: true,
      mostrarPuntaje: true,
    }),
  });
  assertOrThrow(examen.datos, 'No se pudo crear examen');

  const preguntaCerrada = await solicitud<{ id: string }>(`/examenes/${examen.datos.id}/preguntas`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenDocente}` },
    body: JSON.stringify({
      enunciado: '¿Capital de Colombia?',
      tipo: 'OPCION_MULTIPLE',
      puntaje: 5,
      opciones: [
        { letra: 'A', contenido: 'Bogotá', esCorrecta: true, orden: 1 },
        { letra: 'B', contenido: 'Medellín', esCorrecta: false, orden: 2 },
      ],
    }),
  });
  assertOrThrow(preguntaCerrada.datos, 'No se pudo crear pregunta cerrada');

  const preguntaAbierta = await solicitud<{ id: string }>(`/examenes/${examen.datos.id}/preguntas`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenDocente}` },
    body: JSON.stringify({
      enunciado: 'Describe un riesgo de fraude en evaluación digital.',
      tipo: 'RESPUESTA_ABIERTA',
      puntaje: 5,
    }),
  });
  assertOrThrow(preguntaAbierta.datos, 'No se pudo crear pregunta abierta');

  console.log('[8/16] Publicando examen...');
  await solicitud(`/examenes/${examen.datos.id}/publicar`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenDocente}` },
  });

  console.log('[9/16] Creando asignación canónica y sesión...');
  const fechaInicioAsignacion = ahoraIsoMas(12);
  const fechaFinAsignacion = ahoraIsoMas(60 * 20);
  const asignacion = await solicitud<{ id: string }>('/asignaciones', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenDocente}` },
    body: JSON.stringify({
      idExamen: examen.datos.id,
      idGrupo: grupo.datos.id,
      fechaInicio: fechaInicioAsignacion,
      fechaFin: fechaFinAsignacion,
      intentosMaximos: 1,
      mostrarPuntajeInmediato: true,
      mostrarRespuestasCorrectas: true,
      publicarResultadosEn: ahoraIsoMas(60 * 30),
    }),
  });
  assertOrThrow(asignacion.datos, 'No se pudo crear asignación');

  const sesion = await solicitud<{ id: string; estado: string }>('/sesiones', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenDocente}` },
    body: JSON.stringify({
      idAsignacion: asignacion.datos.id,
      descripcion: 'Sesión integral e2e',
    }),
  });
  assertOrThrow(sesion.datos, 'No se pudo crear sesión');

  console.log('[10/16] Validando activación fuera de ventana...');
  const activacionTemprana = await solicitud<{ id: string; estado: string; codigoAcceso: string }>(`/sesiones/${sesion.datos.id}/activar`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenDocente}` },
  }, [200, 201, 400, 403, 409, 422]);

  let sesionActiva: { estado: number; datos: { id: string; estado: string; codigoAcceso: string } | null; cuerpo: unknown } | null = null;
  if (activacionTemprana.estado >= 400) {
    await new Promise((resolver) => setTimeout(resolver, 13_000));
    console.log('[11/16] Activando sesión en ventana y obteniendo código...');
    sesionActiva = await solicitud<{ id: string; estado: string; codigoAcceso: string }>(`/sesiones/${sesion.datos.id}/activar`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${tokenDocente}` },
    });
  } else {
    violacionesDetectadas.push(
      'La sesión se activó antes de la ventana de asignación (debería rechazarse por lógica de dominio).',
    );
    sesionActiva = activacionTemprana;
  }

  assertOrThrow(sesionActiva.datos?.estado === 'ACTIVA', 'La sesión no quedó activa');
  assertOrThrow(Boolean(sesionActiva.datos?.codigoAcceso), 'No se generó código de acceso');
  const codigoSesion = sesionActiva.datos.codigoAcceso;

  const inicioAsignacionMs = new Date(fechaInicioAsignacion).getTime();
  const esperaHastaVentana = inicioAsignacionMs - Date.now() + 1_000;
  if (esperaHastaVentana > 0) {
    await new Promise((resolver) => setTimeout(resolver, esperaHastaVentana));
  }

  console.log('[12/16] Flujo estudiante: buscar sesión, iniciar intento y validar duplicado...');
  const sesionBuscada = await solicitud<{ id: string; examen: { preguntas: Array<{ opciones: unknown[] }> } }>(`/sesiones/buscar/${codigoSesion}`, {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenEstudiante}` },
  });
  assertOrThrow(sesionBuscada.datos?.id === sesion.datos.id, 'La sesión encontrada no coincide');

  const intento = await solicitud<{ id: string }>('/intentos', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenEstudiante}` },
    body: JSON.stringify({
      idSesion: sesion.datos.id,
      codigoAcceso: codigoSesion,
      ipDispositivo: '127.0.0.1',
      modeloDispositivo: 'E2E-Browser',
      sistemaOperativo: 'WEB',
      versionApp: '1.0.0',
    }),
  });
  assertOrThrow(intento.datos, 'No se pudo iniciar intento');
  const idIntento = intento.datos.id;

  const intentoDuplicado = await solicitud('/intentos', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenEstudiante}` },
    body: JSON.stringify({
      idSesion: sesion.datos.id,
      codigoAcceso: codigoSesion,
    }),
  }, 409);
  assertOrThrow(intentoDuplicado.estado === 409, 'No se detectó intento duplicado');

  console.log('[13/16] Registrando telemetría y sincronizando respuestas...');
  await solicitud('/telemetria', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenEstudiante}` },
    body: JSON.stringify({
      idIntento: intento.datos.id,
      tipo: 'FORZAR_CIERRE',
      descripcion: 'Evento crítico controlado de verificación',
      tiempoTranscurrido: 30,
    }),
  });

  await solicitud('/respuestas/sincronizar-lote', {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenEstudiante}` },
    body: JSON.stringify({
      idIntento: intento.datos.id,
      respuestas: [
        {
          idPregunta: preguntaCerrada.datos.id,
          opcionesSeleccionadas: ['A'],
          tiempoRespuesta: 12,
        },
        {
          idPregunta: preguntaAbierta.datos.id,
          valorTexto: 'Riesgo: segundo plano sin supervisión.',
          opcionesSeleccionadas: [],
          tiempoRespuesta: 30,
        },
      ],
    }),
  });

  console.log('[14/16] Finalizando intento, validando reportes y telemetría docente...');
  const finalIntento = await solicitud<{ idIntento: string; puntajeObtenido: number | null; porcentaje: number | null }>(
    `/intentos/${idIntento}/finalizar`,
    {
      method: 'POST',
      headers: { Authorization: `Bearer ${tokenEstudiante}` },
    },
  );
  assertOrThrow(finalIntento.datos?.idIntento === idIntento, 'No se finalizó el intento esperado');

  const telemetriaDocente = await solicitud<Array<{ id: string }>>(`/intentos/${idIntento}/telemetria`, {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenDocente}` },
  });
  assertOrThrow((telemetriaDocente.datos?.length ?? 0) >= 1, 'No se registró telemetría');

  await solicitud(`/sesiones/${sesion.datos.id}/finalizar`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenDocente}` },
  });

  const reporteSesion = await solicitud<{
    totalEstudiantes: number;
    estudiantesQueEnviaron: number;
    estudiantesSospechosos: number;
  }>(`/reportes/sesion/${sesion.datos.id}`, {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenDocente}` },
  });
  assertOrThrow(reporteSesion.datos?.totalEstudiantes === 1, 'Reporte de sesión no refleja total de estudiantes');
  assertOrThrow(reporteSesion.datos?.estudiantesQueEnviaron === 1, 'Reporte de sesión no refleja envíos');
  assertOrThrow((reporteSesion.datos?.estudiantesSospechosos ?? 0) >= 1, 'No se reflejó estudiante sospechoso');

  console.log('[14.1/16] Validando pendientes de calificacion manual...');
  const pendientesCalificacion = await solicitud<Array<{ id: string; idIntento: string; pregunta: { puntaje: number } }>>(
    '/respuestas/pendientes-calificacion',
    {
      method: 'GET',
      headers: { Authorization: `Bearer ${tokenDocente}` },
    },
  );
  const pendienteIntento = pendientesCalificacion.datos?.find((respuesta) => respuesta.idIntento === idIntento);
  assertOrThrow(pendienteIntento, 'No se encontró respuesta pendiente de calificación para el intento actual');

  await solicitud(`/respuestas/${pendienteIntento.id}/calificar-manual`, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${tokenDocente}` },
    body: JSON.stringify({
      puntajeObtenido: Math.min(5, pendienteIntento.pregunta.puntaje),
      observacion: 'Calificación manual aplicada desde verificación integral.',
    }),
  });

  const pendientesDespues = await solicitud<Array<{ id: string; idIntento: string }>>('/respuestas/pendientes-calificacion', {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenDocente}` },
  });
  const siguePendiente = pendientesDespues.datos?.some((respuesta) => respuesta.id === pendienteIntento.id) ?? false;
  assertOrThrow(!siguePendiente, 'La respuesta calificada manualmente sigue figurando como pendiente');

  console.log('[15/16] Flujo de reclamo: crear y resolver...');
  const reportePrevioReclamo = await solicitud<{
    intentos: Array<{ idIntento: string; idResultado: string | null }>;
  }>(
    `/reportes/estudiante/${idEstudiante}`,
    {
      method: 'GET',
      headers: { Authorization: `Bearer ${tokenAdmin}` },
    },
  );
  const intentoParaReclamo = reportePrevioReclamo.datos?.intentos.find((item) => item.idIntento === idIntento);
  assertOrThrow(Boolean(intentoParaReclamo?.idResultado), 'No se encontró resultado del intento en reporte de estudiante');

  const reclamo = await solicitud<{ id: string; estado: string }>(`/resultados/${intentoParaReclamo?.idResultado}/reclamos`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${tokenEstudiante}` },
    body: JSON.stringify({
      motivo: 'Solicito revisión por criterio de pregunta abierta.',
    }),
  });
  assertOrThrow(reclamo.datos, 'No se pudo crear reclamo');
  const idReclamo = reclamo.datos.id;

  const reclamosDocente = await solicitud<Array<{ id: string; estado: string }>>('/reclamos', {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenDocente}` },
  });
  const reclamoVisibleDocente = reclamosDocente.datos?.find((item) => item.id === idReclamo);
  assertOrThrow(reclamoVisibleDocente, 'El reclamo creado no es visible para el docente');

  await solicitud(`/reclamos/${idReclamo}/resolver`, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${tokenDocente}` },
    body: JSON.stringify({
      aprobar: true,
      resolucion: 'Se ajusta puntaje por coherencia de argumento.',
      puntajeNuevo: 8,
    }),
  });

  const reclamosAdmin = await solicitud<Array<{ id: string; estado: string }>>('/reclamos', {
    method: 'GET',
    headers: { Authorization: `Bearer ${tokenAdmin}` },
  });
  const reclamoResuelto = reclamosAdmin.datos?.find((item) => item.id === idReclamo);
  assertOrThrow(reclamoResuelto?.estado === 'RESUELTO', 'El reclamo no quedó resuelto para consulta administrativa');

  const reporteEstudiante = await solicitud<{
    intentos: Array<{ idSesion: string; idIntento: string; idResultado: string | null }>;
  }>(
    `/reportes/estudiante/${idEstudiante}`,
    {
      method: 'GET',
      headers: { Authorization: `Bearer ${tokenAdmin}` },
    },
  );
  assertOrThrow((reporteEstudiante.datos?.intentos.length ?? 0) >= 1, 'No hay intentos en reporte de estudiante');
  const intentoReportado = reporteEstudiante.datos?.intentos.find((item) => item.idIntento === idIntento);
  assertOrThrow(Boolean(intentoReportado?.idResultado), 'El reporte de estudiante no devuelve idResultado para reclamos');

  console.log('[16/16] Verificación integral finalizada.');
  if (violacionesDetectadas.length > 0) {
    console.warn('\nVIOLACIONES DE LOGICA DETECTADAS:');
    violacionesDetectadas.forEach((violacion, indice) => {
      console.warn(`  ${indice + 1}. ${violacion}`);
    });
  }
  console.log(`\nOK - Flujo validado para institución ${idInstitucion} (sufijo ${sufijo}).`);
}

ejecutarVerificacionIntegral()
  .catch((error: unknown) => {
    console.error('\nFALLO EN VERIFICACIÓN INTEGRAL');
    console.error(error);
    process.exitCode = 1;
  });
