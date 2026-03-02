/**
 * @archivo   Semilla.ts
 * @descripcion Crea el usuario administrador inicial cuando aún no existe en la base de datos.
 * @modulo    Semillas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { EstadoCuenta, EstadoInstitucion, PrismaClient, RolUsuario } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();
const NOMBRE_INSTITUCION_INICIAL = 'EvalPro Institución Inicial';

/**
 * Inserta un administrador inicial basado en variables de entorno solo si no existe uno previo.
 */
async function ejecutarSemilla(): Promise<void> {
  const correo = process.env.ADMIN_CORREO_INICIAL;
  const contrasenaPlano = process.env.ADMIN_CONTRASENA_INICIAL;
  const correoSuperadmin = process.env.SUPERADMIN_CORREO_INICIAL ?? 'superadmin@evalpro.com';
  const contrasenaSuperadmin = process.env.SUPERADMIN_CONTRASENA_INICIAL ?? contrasenaPlano;
  const rondasHash = Number(process.env.BCRYPT_RONDAS_HASH ?? '12');

  if (!correo || !contrasenaPlano) {
    throw new Error('Faltan ADMIN_CORREO_INICIAL o ADMIN_CONTRASENA_INICIAL en el entorno.');
  }
  if (!contrasenaSuperadmin) {
    throw new Error('No se pudo resolver SUPERADMIN_CONTRASENA_INICIAL.');
  }
  const correoNormalizado = correo.trim().toLowerCase();
  const correoSuperadminNormalizado = correoSuperadmin.trim().toLowerCase();
  if (correoSuperadminNormalizado === correoNormalizado) {
    throw new Error('ADMIN_CORREO_INICIAL y SUPERADMIN_CORREO_INICIAL deben ser diferentes.');
  }

  const institucion = await prisma.institucion.upsert({
    where: { nombre: NOMBRE_INSTITUCION_INICIAL },
    update: {},
    create: {
      nombre: NOMBRE_INSTITUCION_INICIAL,
      dominio: process.env.ADMIN_DOMINIO_INICIAL ?? 'evalpro.local',
      estado: EstadoInstitucion.ACTIVA,
    },
  });

  const superadminExistente = await prisma.usuario.findFirst({
    where: {
      correo: {
        equals: correoSuperadminNormalizado,
        mode: 'insensitive',
      },
    },
  });

  if (superadminExistente) {
    const datosActualizacionSuperadmin: Record<string, unknown> = {
      correo: correoSuperadminNormalizado,
      rol: RolUsuario.SUPERADMINISTRADOR,
      idInstitucion: null,
      estadoCuenta: EstadoCuenta.ACTIVO,
      primerLogin: false,
      activo: true,
      credencialTemporal: null,
      credencialTemporalVence: null,
    };

    if (superadminExistente.estadoCuenta !== EstadoCuenta.ACTIVO || superadminExistente.primerLogin) {
      const contrasenaHash = await bcrypt.hash(contrasenaSuperadmin, Math.max(12, rondasHash));
      datosActualizacionSuperadmin.contrasena = contrasenaHash;
    }

    const actualizado = await prisma.usuario.update({
      where: { id: superadminExistente.id },
      data: datosActualizacionSuperadmin,
    });
    console.log(`Superadministrador inicial actualizado: ${actualizado.id}`);
  } else {
    const contrasenaHash = await bcrypt.hash(contrasenaSuperadmin, Math.max(12, rondasHash));
    const superadmin = await prisma.usuario.create({
      data: {
        nombre: 'Superadministrador',
        apellidos: 'Inicial',
        correo: correoSuperadminNormalizado,
        contrasena: contrasenaHash,
        rol: RolUsuario.SUPERADMINISTRADOR,
        idInstitucion: null,
        estadoCuenta: EstadoCuenta.ACTIVO,
        primerLogin: false,
      },
    });
    console.log(`Superadministrador creado con id: ${superadmin.id}`);
  }

  const administradorExistente = await prisma.usuario.findFirst({
    where: {
      correo: {
        equals: correoNormalizado,
        mode: 'insensitive',
      },
    },
  });

  if (administradorExistente) {
    const datosActualizacion: Record<string, unknown> = {
      correo: correoNormalizado,
      rol: RolUsuario.ADMINISTRADOR,
      idInstitucion: institucion.id,
      estadoCuenta: EstadoCuenta.ACTIVO,
      primerLogin: false,
      activo: true,
      credencialTemporal: null,
      credencialTemporalVence: null,
    };

    if (administradorExistente.estadoCuenta !== EstadoCuenta.ACTIVO || administradorExistente.primerLogin) {
      const contrasena = await bcrypt.hash(contrasenaPlano, Math.max(12, rondasHash));
      datosActualizacion.contrasena = contrasena;
    }

    const actualizado = await prisma.usuario.update({
      where: { id: administradorExistente.id },
      data: datosActualizacion,
    });
    console.log(`Administrador inicial actualizado: ${actualizado.id}`);
    return;
  }

  const contrasena = await bcrypt.hash(contrasenaPlano, Math.max(12, rondasHash));
  const administrador = await prisma.usuario.create({
    data: {
      nombre: 'Administrador',
      apellidos: 'Inicial',
      correo: correoNormalizado,
      contrasena,
      rol: RolUsuario.ADMINISTRADOR,
      idInstitucion: institucion.id,
      estadoCuenta: EstadoCuenta.ACTIVO,
      primerLogin: false,
    },
  });

  console.log(`Administrador creado con id: ${administrador.id}`);
}

ejecutarSemilla()
  .catch((error: unknown) => {
    console.error('Error al ejecutar semilla:', error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
