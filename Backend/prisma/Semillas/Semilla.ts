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
  const administradorExistente = await prisma.usuario.findFirst({
    where: { rol: RolUsuario.ADMINISTRADOR },
  });

  if (administradorExistente) {
    console.log(`Administrador existente detectado: ${administradorExistente.id}`);
    return;
  }

  const correo = process.env.ADMIN_CORREO_INICIAL;
  const contrasenaPlano = process.env.ADMIN_CONTRASENA_INICIAL;
  const rondasHash = Number(process.env.BCRYPT_RONDAS_HASH ?? '12');

  if (!correo || !contrasenaPlano) {
    throw new Error('Faltan ADMIN_CORREO_INICIAL o ADMIN_CONTRASENA_INICIAL en el entorno.');
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

  const contrasena = await bcrypt.hash(contrasenaPlano, Math.max(12, rondasHash));
  const administrador = await prisma.usuario.create({
    data: {
      nombre: 'Administrador',
      apellidos: 'Inicial',
      correo,
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
