/**
 * @archivo   limpiar-datos-qa.ts
 * @descripcion Elimina datos de QA creados en pruebas manuales/e2e con modo dry-run por defecto.
 * @modulo    scripts
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { PrismaClient } from '@prisma/client';

type ResumenColeccion = {
  total: number;
  ids: string[];
};

type ResultadoEliminacion = Record<string, number>;

const prisma = new PrismaClient();

const argumentos = new Set(process.argv.slice(2));
const aplicar = argumentos.has('--apply');

function obtenerCorreosProtegidos(): string[] {
  return ['ADMIN_CORREO_INICIAL', 'SUPERADMIN_CORREO_INICIAL']
    .map((clave) => process.env[clave]?.trim() ?? '')
    .filter((correo) => correo.length > 0);
}

const CORREOS_PROTEGIDOS = new Set(obtenerCorreosProtegidos());

function idsUnicos(ids: (string | null | undefined)[]): string[] {
  return [...new Set(ids.filter((id): id is string => Boolean(id)))];
}

function resumen(ids: string[]): ResumenColeccion {
  return {
    total: ids.length,
    ids: ids.slice(0, 10),
  };
}

async function main() {
  const instituciones = await prisma.institucion.findMany({
    where: {
      OR: [
        { nombre: { startsWith: 'Inst QA', mode: 'insensitive' } },
        { dominio: { endsWith: '.evalpro.test', mode: 'insensitive' } },
      ],
    },
    select: { id: true },
  });
  const idsInstitucion = idsUnicos(instituciones.map((item) => item.id));

  const usuarios = await prisma.usuario.findMany({
    where: {
      AND: [
        {
          OR: [
            { correo: { endsWith: '@evalpro.test', mode: 'insensitive' } },
            ...(idsInstitucion.length > 0 ? [{ idInstitucion: { in: idsInstitucion } }] : []),
          ],
        },
        {
          correo: {
            notIn: Array.from(CORREOS_PROTEGIDOS),
          },
        },
      ],
    },
    select: { id: true },
  });
  const idsUsuario = idsUnicos(usuarios.map((item) => item.id));

  const periodos = await prisma.periodoAcademico.findMany({
    where: {
      OR: [
        { nombre: { startsWith: '2026-QA-', mode: 'insensitive' } },
        { nombre: { startsWith: 'Periodo-', mode: 'insensitive' } },
        ...(idsInstitucion.length > 0 ? [{ idInstitucion: { in: idsInstitucion } }] : []),
      ],
    },
    select: { id: true },
  });
  const idsPeriodo = idsUnicos(periodos.map((item) => item.id));

  const grupos = await prisma.grupoAcademico.findMany({
    where: {
      OR: [
        { nombre: { startsWith: 'Grupo QA', mode: 'insensitive' } },
        ...(idsInstitucion.length > 0 ? [{ idInstitucion: { in: idsInstitucion } }] : []),
      ],
    },
    select: { id: true },
  });
  const idsGrupo = idsUnicos(grupos.map((item) => item.id));

  const examenes = await prisma.examen.findMany({
    where: {
      OR: [
        { titulo: { startsWith: 'Examen QA', mode: 'insensitive' } },
        ...(idsInstitucion.length > 0 ? [{ idInstitucion: { in: idsInstitucion } }] : []),
        ...(idsUsuario.length > 0 ? [{ creadoPorId: { in: idsUsuario } }] : []),
      ],
    },
    select: { id: true },
  });
  const idsExamen = idsUnicos(examenes.map((item) => item.id));

  const asignaciones = await prisma.asignacionExamen.findMany({
    where: {
      OR: [
        ...(idsInstitucion.length > 0 ? [{ idInstitucion: { in: idsInstitucion } }] : []),
        ...(idsGrupo.length > 0 ? [{ idGrupo: { in: idsGrupo } }] : []),
        ...(idsExamen.length > 0 ? [{ idExamen: { in: idsExamen } }] : []),
        ...(idsUsuario.length > 0 ? [{ idEstudiante: { in: idsUsuario } }, { creadoPor: { in: idsUsuario } }] : []),
      ],
    },
    select: { id: true },
  });
  const idsAsignacion = idsUnicos(asignaciones.map((item) => item.id));

  const sesiones = await prisma.sesionExamen.findMany({
    where: {
      OR: [
        { descripcion: { contains: 'Sesion QA', mode: 'insensitive' } },
        ...(idsInstitucion.length > 0 ? [{ idInstitucion: { in: idsInstitucion } }] : []),
        ...(idsExamen.length > 0 ? [{ examenId: { in: idsExamen } }] : []),
        ...(idsAsignacion.length > 0 ? [{ idAsignacion: { in: idsAsignacion } }] : []),
        ...(idsUsuario.length > 0 ? [{ creadaPorId: { in: idsUsuario } }] : []),
      ],
    },
    select: { id: true },
  });
  const idsSesion = idsUnicos(sesiones.map((item) => item.id));

  const intentos = await prisma.intentoExamen.findMany({
    where: {
      OR: [
        ...(idsInstitucion.length > 0 ? [{ idInstitucion: { in: idsInstitucion } }] : []),
        ...(idsSesion.length > 0 ? [{ sesionId: { in: idsSesion } }] : []),
        ...(idsUsuario.length > 0 ? [{ estudianteId: { in: idsUsuario } }] : []),
      ],
    },
    select: { id: true },
  });
  const idsIntento = idsUnicos(intentos.map((item) => item.id));

  const preguntas = await prisma.pregunta.findMany({
    where: {
      ...(idsExamen.length > 0 ? { examenId: { in: idsExamen } } : { id: { in: [] } }),
    },
    select: { id: true },
  });
  const idsPregunta = idsUnicos(preguntas.map((item) => item.id));

  const resultados = await prisma.resultadoIntento.findMany({
    where: {
      ...(idsIntento.length > 0 ? { intentoId: { in: idsIntento } } : { id: { in: [] } }),
    },
    select: { id: true },
  });
  const idsResultado = idsUnicos(resultados.map((item) => item.id));

  const plan = {
    instituciones: resumen(idsInstitucion),
    usuarios: resumen(idsUsuario),
    periodos: resumen(idsPeriodo),
    grupos: resumen(idsGrupo),
    examenes: resumen(idsExamen),
    asignaciones: resumen(idsAsignacion),
    sesiones: resumen(idsSesion),
    intentos: resumen(idsIntento),
    preguntas: resumen(idsPregunta),
    resultados: resumen(idsResultado),
  };

  console.log('Resumen limpieza QA (dry-run):');
  console.log(JSON.stringify(plan, null, 2));

  if (!aplicar) {
    console.log('\nModo dry-run. Para ejecutar borrado real usa:');
    console.log('npm run datos:limpiar:qa');
    return;
  }

  const eliminados = await prisma.$transaction(async (tx) => {
    const resultado: ResultadoEliminacion = {};

    resultado.eventosTelemetria = idsIntento.length
      ? (await tx.eventoTelemetria.deleteMany({ where: { intentoId: { in: idsIntento } } })).count
      : 0;

    resultado.reclamos = idsResultado.length
      ? (await tx.reclamoCalificacion.deleteMany({ where: { resultadoId: { in: idsResultado } } })).count
      : 0;

    resultado.respuestas = idsIntento.length || idsPregunta.length
      ? (
          await tx.respuesta.deleteMany({
            where: {
              OR: [
                ...(idsIntento.length ? [{ intentoId: { in: idsIntento } }] : []),
                ...(idsPregunta.length ? [{ preguntaId: { in: idsPregunta } }] : []),
              ],
            },
          })
        ).count
      : 0;

    resultado.resultados = idsIntento.length
      ? (await tx.resultadoIntento.deleteMany({ where: { intentoId: { in: idsIntento } } })).count
      : 0;

    resultado.intentos = idsIntento.length
      ? (await tx.intentoExamen.deleteMany({ where: { id: { in: idsIntento } } })).count
      : 0;

    resultado.gruposDocentes = idsGrupo.length || idsUsuario.length
      ? (
          await tx.grupoDocente.deleteMany({
            where: {
              OR: [
                ...(idsGrupo.length ? [{ idGrupo: { in: idsGrupo } }] : []),
                ...(idsUsuario.length ? [{ idDocente: { in: idsUsuario } }, { asignadoPor: { in: idsUsuario } }] : []),
              ],
            },
          })
        ).count
      : 0;

    resultado.gruposEstudiantes = idsGrupo.length || idsUsuario.length
      ? (
          await tx.grupoEstudiante.deleteMany({
            where: {
              OR: [
                ...(idsGrupo.length ? [{ idGrupo: { in: idsGrupo } }] : []),
                ...(idsUsuario.length ? [{ idEstudiante: { in: idsUsuario } }, { inscritoPor: { in: idsUsuario } }] : []),
              ],
            },
          })
        ).count
      : 0;

    resultado.sesiones = idsSesion.length
      ? (await tx.sesionExamen.deleteMany({ where: { id: { in: idsSesion } } })).count
      : 0;

    resultado.asignaciones = idsAsignacion.length
      ? (await tx.asignacionExamen.deleteMany({ where: { id: { in: idsAsignacion } } })).count
      : 0;

    resultado.opciones = idsPregunta.length
      ? (await tx.opcionRespuesta.deleteMany({ where: { preguntaId: { in: idsPregunta } } })).count
      : 0;

    resultado.preguntas = idsPregunta.length
      ? (await tx.pregunta.deleteMany({ where: { id: { in: idsPregunta } } })).count
      : 0;

    resultado.examenes = idsExamen.length
      ? (await tx.examen.deleteMany({ where: { id: { in: idsExamen } } })).count
      : 0;

    resultado.grupos = idsGrupo.length
      ? (await tx.grupoAcademico.deleteMany({ where: { id: { in: idsGrupo } } })).count
      : 0;

    let idsPeriodoEliminables = idsPeriodo;
    if (idsPeriodo.length) {
      const periodosBloqueados = await tx.grupoAcademico.findMany({
        where: {
          idPeriodo: { in: idsPeriodo },
          ...(idsGrupo.length ? { NOT: { id: { in: idsGrupo } } } : {}),
        },
        select: { idPeriodo: true },
        distinct: ['idPeriodo'],
      });
      const periodosBloqueadosSet = new Set(periodosBloqueados.map((item) => item.idPeriodo));
      idsPeriodoEliminables = idsPeriodo.filter((idPeriodo) => !periodosBloqueadosSet.has(idPeriodo));
      resultado.periodosOmitidos = idsPeriodo.length - idsPeriodoEliminables.length;
    } else {
      resultado.periodosOmitidos = 0;
    }

    resultado.periodos = idsPeriodoEliminables.length
      ? (await tx.periodoAcademico.deleteMany({ where: { id: { in: idsPeriodoEliminables } } })).count
      : 0;

    resultado.auditoria = idsInstitucion.length || idsUsuario.length
      ? (
          await tx.auditoriaAccion.deleteMany({
            where: {
              OR: [
                ...(idsInstitucion.length ? [{ idInstitucion: { in: idsInstitucion } }] : []),
                ...(idsUsuario.length ? [{ idActor: { in: idsUsuario } }] : []),
              ],
            },
          })
        ).count
      : 0;

    resultado.usuarios = idsUsuario.length
      ? (await tx.usuario.deleteMany({ where: { id: { in: idsUsuario } } })).count
      : 0;

    let idsInstitucionEliminables = idsInstitucion;
    if (idsInstitucion.length) {
      const institucionesBloqueadas = await tx.institucion.findMany({
        where: {
          id: { in: idsInstitucion },
          OR: [
            { usuarios: { some: {} } },
            { examenes: { some: {} } },
            { grupos: { some: {} } },
            { periodos: { some: {} } },
            { sesiones: { some: {} } },
            { intentos: { some: {} } },
            { asignaciones: { some: {} } },
            { auditorias: { some: {} } },
          ],
        },
        select: { id: true },
      });
      const institucionesBloqueadasSet = new Set(institucionesBloqueadas.map((item) => item.id));
      idsInstitucionEliminables = idsInstitucion.filter((idInstitucion) => !institucionesBloqueadasSet.has(idInstitucion));
      resultado.institucionesOmitidas = idsInstitucion.length - idsInstitucionEliminables.length;
    } else {
      resultado.institucionesOmitidas = 0;
    }

    resultado.instituciones = idsInstitucionEliminables.length
      ? (await tx.institucion.deleteMany({ where: { id: { in: idsInstitucionEliminables } } })).count
      : 0;

    return resultado;
  });

  console.log('\nLimpieza QA ejecutada:');
  console.log(JSON.stringify(eliminados, null, 2));
}

main()
  .catch((error) => {
    console.error('Fallo la limpieza QA:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
