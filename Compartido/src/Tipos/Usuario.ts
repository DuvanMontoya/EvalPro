/**
 * @archivo   Usuario.ts
 * @descripcion Define el tipo compartido del usuario sin exponer datos sensibles innecesarios.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { RolUsuario } from '../Enums/RolUsuario';

export enum EstadoCuenta {
  PENDIENTE_ACTIVACION = 'PENDIENTE_ACTIVACION',
  ACTIVO = 'ACTIVO',
  BLOQUEADO = 'BLOQUEADO',
  SUSPENDIDO = 'SUSPENDIDO',
}

export interface Usuario {
  id: string;
  idInstitucion?: string | null;
  nombre: string;
  apellidos: string;
  correo: string;
  rol: RolUsuario;
  estadoCuenta?: EstadoCuenta;
  primerLogin?: boolean;
  activo: boolean;
  fechaCreacion: string;
  fechaActualizacion: string;
  credencialTemporalPlano?: string | null;
}

export interface UsuarioConSeguridad extends Usuario {
  contrasena: string;
  tokenRefresh: string | null;
}
