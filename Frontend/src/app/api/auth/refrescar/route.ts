/**
 * @archivo   route.ts
 * @descripcion Renueva token de acceso leyendo refresh token desde cookie httpOnly del frontend.
 * @modulo    ApiInternaAutenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { cookies } from 'next/headers';
import { NextResponse } from 'next/server';
import { API } from '@/Constantes/Api.constantes';
import { RespuestaApi, SesionAutenticada, Usuario } from '@/Tipos';

interface PayloadRefresh {
  sub: string;
}

function extraerIdUsuario(token: string): string | null {
  try {
    const partes = token.split('.');
    if (partes.length < 2) {
      return null;
    }

    const json = Buffer.from(partes[1]!, 'base64url').toString('utf8');
    const payload = JSON.parse(json) as PayloadRefresh;
    return payload.sub ?? null;
  } catch {
    return null;
  }
}

/**
 * Refresca la sesión usando el refresh token guardado como cookie httpOnly.
 */
export async function POST(): Promise<NextResponse> {
  const almacenCookies = await cookies();
  const tokenRefresh = almacenCookies.get(API.COOKIE_REFRESH)?.value;

  if (!tokenRefresh) {
    return NextResponse.json({ mensaje: 'Sesión expirada' }, { status: 401 });
  }

  const idUsuario = extraerIdUsuario(tokenRefresh);
  if (!idUsuario) {
    return NextResponse.json({ mensaje: 'Token refresh inválido' }, { status: 401 });
  }

  let sesion: SesionAutenticada;
  try {
    const respuestaBackend = await fetch(`${API.BASE_INTERNA}${API.AUTENTICACION.REFRESCAR_TOKENS}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ idUsuario, tokenRefresh }),
    });

    const cuerpoBackend = (await respuestaBackend.json()) as RespuestaApi<SesionAutenticada>;

    if (!respuestaBackend.ok || !cuerpoBackend.exito || !cuerpoBackend.datos) {
      const respuestaError = NextResponse.json({ mensaje: 'No fue posible renovar la sesión' }, { status: 401 });
      respuestaError.cookies.delete(API.COOKIE_REFRESH);
      return respuestaError;
    }

    sesion = cuerpoBackend.datos;
  } catch {
    const respuestaError = NextResponse.json({ mensaje: 'No fue posible renovar la sesión' }, { status: 401 });
    respuestaError.cookies.delete(API.COOKIE_REFRESH);
    return respuestaError;
  }
  const respuesta = NextResponse.json({
    tokenAcceso: sesion.tokenAcceso,
    usuario: sesion.usuario as Usuario,
  });

  respuesta.cookies.set({
    name: API.COOKIE_REFRESH,
    value: sesion.tokenRefresh,
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/',
    maxAge: 60 * 60 * 24 * 7,
  });

  return respuesta;
}
