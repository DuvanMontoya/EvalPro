/**
 * @archivo   UtilidadesPruebasE2e.ts
 * @descripcion Reúne funciones compartidas para preparar datos y autenticación en pruebas e2e.
 * @modulo    test
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { EstadoCuenta, EstadoInstitucion, PrismaClient, RolUsuario } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import request from 'supertest';
import { AppModule } from '../src/App.module';
import { ExcepcionGlobalFiltro } from '../src/Comun/Filtros/ExcepcionGlobal.filtro';
import { RegistroActividadInterceptor } from '../src/Comun/Interceptores/RegistroActividad.interceptor';
import { TransformRespuestaInterceptor } from '../src/Comun/Interceptores/TransformRespuesta.interceptor';
import { ValidacionGlobalPipe } from '../src/Comun/Pipes/ValidacionGlobal.pipe';

export interface UsuarioPrueba {
  id: string;
  correo: string;
  contrasena: string;
  rol: RolUsuario;
}

const RONDAS_HASH = 12;
const prisma = new PrismaClient();

/**
 * Crea una instancia de aplicación NestJS lista para pruebas end-to-end.
 * @returns Aplicación inicializada con prefijo global.
 */
export async function crearAplicacionE2e(): Promise<INestApplication> {
  const moduloPruebas = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();
  const aplicacion = moduloPruebas.createNestApplication();
  aplicacion.setGlobalPrefix('api/v1');
  aplicacion.useGlobalFilters(new ExcepcionGlobalFiltro());
  aplicacion.useGlobalPipes(new ValidacionGlobalPipe());
  aplicacion.useGlobalInterceptors(
    aplicacion.get(TransformRespuestaInterceptor),
    aplicacion.get(RegistroActividadInterceptor),
  );
  await aplicacion.init();
  return aplicacion;
}

/**
 * Crea un usuario en base de datos para pruebas con contraseña hasheada.
 * @param rol - Rol del usuario de prueba.
 * @param activo - Estado activo del usuario.
 * @returns Datos base del usuario creado.
 */
export async function crearUsuarioPrueba(rol: RolUsuario, activo = true): Promise<UsuarioPrueba> {
  const idInstitucion = rol === RolUsuario.SUPERADMINISTRADOR ? null : await obtenerOCrearInstitucionPruebas();
  const sufijo = `${Date.now()}_${Math.floor(Math.random() * 100000)}`;
  const correo = `${rol.toLowerCase()}_${sufijo}@evalpro.test`;
  const contrasena = 'EvalProPrueba123!';
  const hash = await bcrypt.hash(contrasena, RONDAS_HASH);
  const usuario = await prisma.usuario.create({
    data: {
      nombre: 'Prueba',
      apellidos: rol,
      correo,
      contrasena: hash,
      rol,
      idInstitucion,
      estadoCuenta: activo ? EstadoCuenta.ACTIVO : EstadoCuenta.SUSPENDIDO,
      primerLogin: false,
      activo,
    },
  });

  return { id: usuario.id, correo, contrasena, rol };
}

/**
 * Inicia sesión por API y retorna el token de acceso y refresh emitidos.
 * @param aplicacion - Aplicación e2e inicializada.
 * @param correo - Correo del usuario.
 * @param contrasena - Contraseña en texto plano.
 * @returns Par de tokens de la sesión.
 */
export async function iniciarSesionE2e(aplicacion: INestApplication, correo: string, contrasena: string) {
  const respuesta = await request(aplicacion.getHttpServer()).post('/api/v1/autenticacion/iniciar-sesion').send({
    correo,
    contrasena,
  });
  const datos = respuesta.body?.datos ?? respuesta.body;
  return {
    estado: respuesta.status,
    tokenAcceso: String(datos?.tokenAcceso ?? ''),
    tokenRefresh: String(datos?.tokenRefresh ?? ''),
    datos,
  };
}

/**
 * Devuelve la instancia de Prisma usada por utilidades de pruebas.
 * @returns PrismaClient para consultas auxiliares en tests.
 */
export function obtenerPrismaPruebas(): PrismaClient {
  return prisma;
}

async function obtenerOCrearInstitucionPruebas(): Promise<string> {
  const nombre = 'Institucion Pruebas E2E';
  const existente = await prisma.institucion.findFirst({ where: { nombre }, select: { id: true } });
  if (existente) {
    return existente.id;
  }

  const creada = await prisma.institucion.create({
    data: {
      nombre,
      dominio: `pruebas-${Date.now()}.evalpro.test`,
      estado: EstadoInstitucion.ACTIVA,
    },
    select: { id: true },
  });
  return creada.id;
}
