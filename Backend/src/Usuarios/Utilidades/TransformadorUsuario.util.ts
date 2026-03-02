/**
 * @archivo   TransformadorUsuario.util.ts
 * @descripcion Centraliza transformación de entidades de usuario y normalización de correos.
 * @modulo    Usuarios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { EstadoCuenta, RolUsuario } from '@prisma/client';
import { RespuestaUsuarioDto } from '../Dto/RespuestaUsuario.dto';

interface UsuarioMapeable {
  id: string;
  nombre: string;
  apellidos: string;
  correo: string;
  rol: RolUsuario;
  idInstitucion: string | null;
  estadoCuenta: EstadoCuenta;
  primerLogin: boolean;
  activo: boolean;
  fechaCreacion: Date;
  fechaActualizacion: Date;
}

/**
 * Mapea una entidad de usuario al DTO de respuesta sin exponer datos sensibles.
 * @param usuario - Usuario persistido en base de datos.
 * @returns Objeto serializable para respuestas HTTP.
 */
export function mapearUsuarioRespuesta(usuario: UsuarioMapeable): RespuestaUsuarioDto {
  return {
    id: usuario.id,
    nombre: usuario.nombre,
    apellidos: usuario.apellidos,
    correo: usuario.correo,
    rol: usuario.rol,
    idInstitucion: usuario.idInstitucion,
    estadoCuenta: usuario.estadoCuenta,
    primerLogin: usuario.primerLogin,
    activo: usuario.activo,
    fechaCreacion: usuario.fechaCreacion,
    fechaActualizacion: usuario.fechaActualizacion,
  };
}

/**
 * Normaliza un correo para evitar duplicados por formato.
 * @param correo - Correo recibido de entrada.
 * @returns Correo en minúsculas y sin espacios externos.
 */
export function normalizarCorreoUsuario(correo: string): string {
  return correo.trim().toLowerCase();
}
