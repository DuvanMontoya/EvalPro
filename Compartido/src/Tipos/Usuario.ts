/**
 * @archivo   Usuario.ts
 * @descripcion Define el tipo compartido del usuario sin exponer datos sensibles innecesarios.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { RolUsuario } from '../Enums/RolUsuario';

export interface Usuario {
  id: string;
  nombre: string;
  apellidos: string;
  correo: string;
  rol: RolUsuario;
  activo: boolean;
  fechaCreacion: string;
  fechaActualizacion: string;
}

export interface UsuarioConSeguridad extends Usuario {
  contrasena: string;
  tokenRefresh: string | null;
}
