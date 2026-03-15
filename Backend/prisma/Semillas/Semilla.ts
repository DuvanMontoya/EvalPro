/**
 * @archivo   Semilla.ts
 * @descripcion Crea cuentas iniciales de todos los perfiles y datos mínimos de operación.
 * @modulo    Semillas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { EstadoCuenta, EstadoGrupo, EstadoInstitucion, PrismaClient, RolUsuario, Usuario } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomBytes } from 'crypto';

const prisma = new PrismaClient();
const MAX_INTENTOS_CODIGO_GRUPO = 10;

interface DefinicionCuentaInicial {
  correo: string;
  contrasena: string;
  rol: RolUsuario;
  idInstitucion: string | null;
  nombre: string;
  apellidos: string;
}

/**
 * Inserta cuentas iniciales y estructura mínima demo en la base de datos.
 */
async function ejecutarSemilla(): Promise<void> {
  const correoAdministrador = obtenerTextoEntornoObligatorio('ADMIN_CORREO_INICIAL');
  const contrasenaAdministrador = obtenerTextoEntornoObligatorio('ADMIN_CONTRASENA_INICIAL');
  const correoSuperadmin = obtenerTextoEntornoObligatorio('SUPERADMIN_CORREO_INICIAL');
  const contrasenaSuperadmin = obtenerTextoEntornoObligatorio('SUPERADMIN_CONTRASENA_INICIAL');
  const correoDocente = obtenerTextoEntornoObligatorio('DOCENTE_CORREO_INICIAL');
  const contrasenaDocente = obtenerTextoEntornoObligatorio('DOCENTE_CONTRASENA_INICIAL');
  const correoEstudiante = obtenerTextoEntornoObligatorio('ESTUDIANTE_CORREO_INICIAL');
  const contrasenaEstudiante = obtenerTextoEntornoObligatorio('ESTUDIANTE_CONTRASENA_INICIAL');
  const nombreInstitucionInicial = obtenerTextoEntornoObligatorio('INSTITUCION_NOMBRE_INICIAL');
  const dominioInstitucionInicial = obtenerTextoEntornoObligatorio('INSTITUCION_DOMINIO_INICIAL');
  const nombrePeriodoInicial = obtenerTextoEntornoObligatorio('PERIODO_NOMBRE_INICIAL');
  const nombreGrupoInicial = obtenerTextoEntornoObligatorio('GRUPO_NOMBRE_INICIAL');
  const descripcionGrupoInicial = obtenerTextoEntornoObligatorio('GRUPO_DESCRIPCION_INICIAL');
  const rondasHash = obtenerEnteroEntorno('BCRYPT_RONDAS_HASH', 12);

  const correoAdministradorNormalizado = correoAdministrador.trim().toLowerCase();
  const correoSuperadminNormalizado = correoSuperadmin.trim().toLowerCase();
  const correoDocenteNormalizado = correoDocente.trim().toLowerCase();
  const correoEstudianteNormalizado = correoEstudiante.trim().toLowerCase();
  const correosIniciales = new Set<string>([
    correoAdministradorNormalizado,
    correoSuperadminNormalizado,
    correoDocenteNormalizado,
    correoEstudianteNormalizado,
  ]);
  if (correosIniciales.size < 4) {
    throw new Error('Las cuentas iniciales ADMIN/SUPERADMIN/DOCENTE/ESTUDIANTE deben tener correos distintos.');
  }

  const institucion = await prisma.institucion.upsert({
    where: { nombre: nombreInstitucionInicial },
    update: {},
    create: {
      nombre: nombreInstitucionInicial,
      dominio: dominioInstitucionInicial,
      estado: EstadoInstitucion.ACTIVA,
    },
  });

  const cuentasIniciales: DefinicionCuentaInicial[] = [
    {
      correo: correoSuperadminNormalizado,
      contrasena: contrasenaSuperadmin,
      rol: RolUsuario.SUPERADMINISTRADOR,
      idInstitucion: null,
      nombre: 'Superadministrador',
      apellidos: 'Inicial',
    },
    {
      correo: correoAdministradorNormalizado,
      contrasena: contrasenaAdministrador,
      rol: RolUsuario.ADMINISTRADOR,
      idInstitucion: institucion.id,
      nombre: 'Administrador',
      apellidos: 'Inicial',
    },
    {
      correo: correoDocenteNormalizado,
      contrasena: contrasenaDocente,
      rol: RolUsuario.DOCENTE,
      idInstitucion: institucion.id,
      nombre: 'Docente',
      apellidos: 'Inicial',
    },
    {
      correo: correoEstudianteNormalizado,
      contrasena: contrasenaEstudiante,
      rol: RolUsuario.ESTUDIANTE,
      idInstitucion: institucion.id,
      nombre: 'Estudiante',
      apellidos: 'Inicial',
    },
  ];

  let usuarioAdministrador: Usuario | null = null;
  let usuarioDocente: Usuario | null = null;
  let usuarioEstudiante: Usuario | null = null;

  for (const definicion of cuentasIniciales) {
    const usuario = await asegurarCuentaInicial(definicion, rondasHash);
    console.log(`Cuenta inicial asegurada: ${definicion.rol} (${definicion.correo}) => ${usuario.id}`);
    if (definicion.rol === RolUsuario.ADMINISTRADOR) {
      usuarioAdministrador = usuario;
    }
    if (definicion.rol === RolUsuario.DOCENTE) {
      usuarioDocente = usuario;
    }
    if (definicion.rol === RolUsuario.ESTUDIANTE) {
      usuarioEstudiante = usuario;
    }
  }

  if (!usuarioAdministrador || !usuarioDocente || !usuarioEstudiante) {
    throw new Error('No se pudieron resolver cuentas iniciales obligatorias para datos demo.');
  }

  const periodoExistente = await prisma.periodoAcademico.findFirst({
    where: {
      idInstitucion: institucion.id,
      nombre: nombrePeriodoInicial,
    },
  });
  const periodo = periodoExistente
    ? await prisma.periodoAcademico.update({
        where: { id: periodoExistente.id },
        data: {
          fechaInicio: new Date('2026-01-15T08:00:00.000Z'),
          fechaFin: new Date('2026-12-15T18:00:00.000Z'),
          activo: true,
        },
      })
    : await prisma.periodoAcademico.create({
        data: {
          idInstitucion: institucion.id,
          nombre: nombrePeriodoInicial,
          fechaInicio: new Date('2026-01-15T08:00:00.000Z'),
          fechaFin: new Date('2026-12-15T18:00:00.000Z'),
          activo: true,
        },
      });

  const grupoExistente = await prisma.grupoAcademico.findFirst({
    where: {
      idInstitucion: institucion.id,
      idPeriodo: periodo.id,
      nombre: nombreGrupoInicial,
    },
  });

  const grupo =
    grupoExistente ??
    (await prisma.grupoAcademico.create({
      data: {
        idInstitucion: institucion.id,
        idPeriodo: periodo.id,
        nombre: nombreGrupoInicial,
        descripcion: descripcionGrupoInicial,
        estado: EstadoGrupo.BORRADOR,
        codigoAcceso: await generarCodigoGrupoUnico(),
      },
    }));

  await prisma.grupoDocente.upsert({
    where: {
      idGrupo_idDocente: {
        idGrupo: grupo.id,
        idDocente: usuarioDocente.id,
      },
    },
    update: { activo: true, asignadoPor: usuarioAdministrador.id },
    create: {
      idGrupo: grupo.id,
      idDocente: usuarioDocente.id,
      asignadoPor: usuarioAdministrador.id,
      activo: true,
    },
  });

  await prisma.grupoEstudiante.upsert({
    where: {
      idGrupo_idEstudiante: {
        idGrupo: grupo.id,
        idEstudiante: usuarioEstudiante.id,
      },
    },
    update: { activo: true, inscritoPor: usuarioAdministrador.id },
    create: {
      idGrupo: grupo.id,
      idEstudiante: usuarioEstudiante.id,
      inscritoPor: usuarioAdministrador.id,
      activo: true,
    },
  });

  console.log(`Periodo demo asegurado: ${periodo.id}`);
  console.log(`Grupo demo asegurado: ${grupo.id}`);
}

async function asegurarCuentaInicial(
  definicion: DefinicionCuentaInicial,
  rondasHash: number,
): Promise<Usuario> {
  const existente = await prisma.usuario.findFirst({
    where: {
      correo: {
        equals: definicion.correo,
        mode: 'insensitive',
      },
    },
  });

  const contrasenaHash = await bcrypt.hash(definicion.contrasena, Math.max(12, rondasHash));
  const datosComun = {
    nombre: definicion.nombre,
    apellidos: definicion.apellidos,
    correo: definicion.correo,
    contrasena: contrasenaHash,
    rol: definicion.rol,
    idInstitucion: definicion.idInstitucion,
    estadoCuenta: EstadoCuenta.ACTIVO,
    primerLogin: false,
    activo: true,
    credencialTemporal: null,
    credencialTemporalVence: null,
    tokenRefresh: null,
    intentosFallidosLogin: 0,
    bloqueadoHasta: null,
  };

  if (existente) {
    return prisma.usuario.update({
      where: { id: existente.id },
      data: datosComun,
    });
  }

  return prisma.usuario.create({
    data: datosComun,
  });
}

async function generarCodigoGrupoUnico(): Promise<string> {
  for (let intento = 0; intento < MAX_INTENTOS_CODIGO_GRUPO; intento += 1) {
    const codigo = randomBytes(8)
      .toString('base64url')
      .replace(/[^A-Za-z0-9]/g, '')
      .slice(0, 8)
      .toUpperCase();
    if (codigo.length < 8) {
      continue;
    }
    const existente = await prisma.grupoAcademico.findUnique({
      where: { codigoAcceso: codigo },
      select: { id: true },
    });
    if (!existente) {
      return codigo;
    }
  }
  throw new Error('No se pudo generar código único para el grupo inicial');
}

function obtenerTextoEntornoObligatorio(clave: string): string {
  const valor = process.env[clave]?.trim();
  if (!valor) {
    throw new Error(`Falta la variable de entorno obligatoria ${clave}.`);
  }
  return valor;
}

function obtenerEnteroEntorno(clave: string, minimo: number): number {
  const valor = Number.parseInt(process.env[clave] ?? '', 10);
  if (!Number.isFinite(valor) || valor < minimo) {
    throw new Error(`La variable ${clave} debe ser un entero mayor o igual a ${minimo}.`);
  }
  return valor;
}

ejecutarSemilla()
  .catch((error: unknown) => {
    console.error('Error al ejecutar semilla:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
