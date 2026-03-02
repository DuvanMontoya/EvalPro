/**
 * @archivo   route.ts
 * @descripcion Administra cookie httpOnly del refresh token para sesión web segura.
 * @modulo    ApiInternaAutenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { NextRequest, NextResponse } from 'next/server';
import { API } from '@/Constantes/Api.constantes';

/**
 * Guarda token refresh en cookie httpOnly.
 * @param request - Solicitud con tokenRefresh en body.
 */
export async function POST(request: NextRequest): Promise<NextResponse> {
  const cuerpo = (await request.json()) as { tokenRefresh?: string };

  if (!cuerpo.tokenRefresh) {
    return NextResponse.json({ mensaje: 'Token refresh requerido' }, { status: 400 });
  }

  const respuesta = NextResponse.json({ exito: true });
  respuesta.cookies.set({
    name: API.COOKIE_REFRESH,
    value: cuerpo.tokenRefresh,
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/',
    maxAge: 60 * 60 * 24 * 7,
  });

  return respuesta;
}

/**
 * Elimina la cookie refresh del navegador.
 */
export async function DELETE(): Promise<NextResponse> {
  const respuesta = NextResponse.json({ exito: true });
  respuesta.cookies.delete(API.COOKIE_REFRESH);
  return respuesta;
}
