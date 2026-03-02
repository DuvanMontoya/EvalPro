/**
 * @archivo   Roles.constantes.ts
 * @descripcion Centraliza metadatos y utilidades de roles usados por guards y decoradores.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { RolUsuario } from '@prisma/client';

export const CLAVE_ROLES = 'roles_permitidos';

export const ROLES_ADMINISTRATIVOS: RolUsuario[] = [
  RolUsuario.ADMINISTRADOR,
  RolUsuario.DOCENTE,
];
