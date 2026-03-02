/**
 * @archivo   Roles.guard.ts
 * @descripcion Evalúa los roles declarados en metadatos y valida autorización del usuario autenticado.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { RolUsuario, Usuario } from '@prisma/client';
import { MENSAJES } from '../Constantes/Mensajes.constantes';
import { CLAVE_ROLES } from '../Constantes/Roles.constantes';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  /**
   * Permite o deniega acceso comparando rol del usuario con los roles requeridos.
   * @param contexto - Contexto de ejecución HTTP.
   * @returns Verdadero cuando el usuario cumple los roles exigidos.
   */
  canActivate(contexto: ExecutionContext): boolean {
    const rolesRequeridos = this.reflector.getAllAndOverride<RolUsuario[]>(CLAVE_ROLES, [
      contexto.getHandler(),
      contexto.getClass(),
    ]);

    if (!rolesRequeridos || rolesRequeridos.length === 0) {
      return true;
    }

    const solicitud = contexto.switchToHttp().getRequest<{ user?: Usuario }>();
    const usuario = solicitud.user;

    if (!usuario || !rolesRequeridos.includes(usuario.rol)) {
      throw new ForbiddenException(MENSAJES.SIN_PERMISOS);
    }

    return true;
  }
}
