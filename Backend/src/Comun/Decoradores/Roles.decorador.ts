/**
 * @archivo   Roles.decorador.ts
 * @descripcion Proporciona un decorador para declarar roles autorizados por endpoint.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { SetMetadata } from '@nestjs/common';
import { RolUsuario } from '@prisma/client';
import { CLAVE_ROLES } from '../Constantes/Roles.constantes';

/**
 * Asigna metadatos de roles permitidos a un controlador o método.
 * @param roles - Lista de roles autorizados.
 * @returns Decorador para aplicar en endpoints.
 */
export const Roles = (...roles: RolUsuario[]): MethodDecorator & ClassDecorator =>
  SetMetadata(CLAVE_ROLES, roles);
