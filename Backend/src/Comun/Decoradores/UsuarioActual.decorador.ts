/**
 * @archivo   UsuarioActual.decorador.ts
 * @descripcion Extrae el usuario autenticado almacenado en la solicitud HTTP actual.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { Usuario } from '@prisma/client';

/**
 * Obtiene el usuario autenticado desde el request de NestJS.
 */
export const UsuarioActual = createParamDecorator(
  (propiedad: keyof Usuario | undefined, contexto: ExecutionContext) => {
    const solicitud = contexto.switchToHttp().getRequest<{ user?: Usuario }>();
    if (!solicitud.user) {
      return null;
    }

    return propiedad ? solicitud.user[propiedad] : solicitud.user;
  },
);
