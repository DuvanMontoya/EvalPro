/**
 * @archivo   Autenticacion.servicio.ts
 * @descripcion Encapsula operaciones de inicio, refresco y cierre de sesión contra backend y API interna.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { API } from '@/Constantes/Api.constantes';
import { RespuestaApi, SesionAutenticada, Usuario } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

export interface IniciarSesionDto {
  correo: string;
  contrasena: string;
}

interface RespuestaRefrescoInterno {
  tokenAcceso: string;
  usuario: Usuario;
}

export interface RespuestaPrimerLogin {
  requiereCambioContrasena: true;
  tokenTemporal: string;
}

export type RespuestaInicioSesion = SesionAutenticada | RespuestaPrimerLogin;

interface CambiarContrasenaPrimerLoginDto {
  nuevaContrasena: string;
}

export function esRespuestaPrimerLogin(
  respuesta: RespuestaInicioSesion,
): respuesta is RespuestaPrimerLogin {
  return 'requiereCambioContrasena' in respuesta && respuesta.requiereCambioContrasena === true;
}

/**
 * Inicia sesión con credenciales válidas.
 * @param credenciales - Correo y contraseña del usuario.
 * @returns Sesión autenticada con tokens y usuario.
 */
export async function iniciarSesion(credenciales: IniciarSesionDto): Promise<RespuestaInicioSesion> {
  const respuesta = await apiCliente.post<RespuestaApi<RespuestaInicioSesion>>(
    API.AUTENTICACION.INICIAR_SESION,
    credenciales,
  );
  return extraerDatos(respuesta);
}

/**
 * Completa activación de primer login intercambiando token temporal por sesión completa.
 * @param tokenTemporal - Token temporal emitido durante primer login.
 * @param nuevaContrasena - Nueva contraseña definitiva del usuario.
 */
export async function cambiarContrasenaPrimerLogin(
  tokenTemporal: string,
  nuevaContrasena: string,
): Promise<SesionAutenticada> {
  const respuesta = await apiCliente.post<RespuestaApi<SesionAutenticada>>(
    API.AUTENTICACION.CAMBIAR_CONTRASENA,
    { nuevaContrasena } satisfies CambiarContrasenaPrimerLoginDto,
    {
      headers: {
        Authorization: `Bearer ${tokenTemporal}`,
      },
    },
  );

  return extraerDatos(respuesta);
}

/**
 * Solicita cierre de sesión en backend invalidando refresh token almacenado.
 */
export async function cerrarSesion(): Promise<void> {
  await apiCliente.post(API.AUTENTICACION.CERRAR_SESION);
}

/**
 * Persiste el refresh token en cookie httpOnly mediante endpoint interno de Next.
 * @param tokenRefresh - Token de larga duración emitido por backend.
 */
export async function guardarRefreshEnCookie(tokenRefresh: string): Promise<void> {
  await fetch('/api/auth/sesion', {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ tokenRefresh }),
  });
}

/**
 * Elimina la cookie httpOnly de refresh token en frontend.
 */
export async function eliminarRefreshDeCookie(): Promise<void> {
  await fetch('/api/auth/sesion', {
    method: 'DELETE',
    credentials: 'include',
  });
}

/**
 * Intenta refrescar token de acceso usando la cookie httpOnly.
 * @returns Token renovado y usuario autenticado.
 */
export async function refrescarDesdeCookie(): Promise<RespuestaRefrescoInterno> {
  const respuesta = await fetch('/api/auth/refrescar', {
    method: 'POST',
    credentials: 'include',
  });

  if (!respuesta.ok) {
    throw new Error('No fue posible refrescar la sesión');
  }

  return (await respuesta.json()) as RespuestaRefrescoInterno;
}
