/**
 * @archivo   Api.constantes.ts
 * @descripcion Centraliza rutas de API, eventos de websocket y nombres de cookies del frontend.
 * @modulo    Constantes
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
type VariableEntornoPublica =
  | 'NEXT_PUBLIC_API_URL'
  | 'NEXT_PUBLIC_WEBSOCKET_URL'
  | 'NEXT_PUBLIC_VERSION_APP';

function obtenerVariableEntornoPublica(nombre: VariableEntornoPublica): string {
  const valor =
    nombre === 'NEXT_PUBLIC_API_URL'
      ? process.env.NEXT_PUBLIC_API_URL
      : nombre === 'NEXT_PUBLIC_WEBSOCKET_URL'
        ? process.env.NEXT_PUBLIC_WEBSOCKET_URL
        : process.env.NEXT_PUBLIC_VERSION_APP;

  if (!valor?.trim()) {
    throw new Error(`La variable de entorno ${nombre} es obligatoria para el frontend.`);
  }

  return valor.trim();
}

function obtenerVariableEntornoInterna(): string {
  const valor = process.env.API_BASE_INTERNA?.trim();
  if (!valor) {
    throw new Error('La variable de entorno API_BASE_INTERNA es obligatoria para el frontend.');
  }
  return valor;
}

export const API = {
  get BASE_PUBLICA() {
    return obtenerVariableEntornoPublica('NEXT_PUBLIC_API_URL');
  },
  get BASE_INTERNA() {
    return obtenerVariableEntornoInterna();
  },
  get WEBSOCKET() {
    return obtenerVariableEntornoPublica('NEXT_PUBLIC_WEBSOCKET_URL');
  },
  get VERSION() {
    return obtenerVariableEntornoPublica('NEXT_PUBLIC_VERSION_APP');
  },
  COOKIE_REFRESH: 'token_refresh_evalpro',
  AUTENTICACION: {
    INICIAR_SESION: '/autenticacion/iniciar-sesion',
    REFRESCAR_TOKENS: '/autenticacion/refrescar-tokens',
    CAMBIAR_CONTRASENA: '/autenticacion/cambiar-contrasena',
    CERRAR_SESION: '/autenticacion/cerrar-sesion',
  },
  EXAMENES: '/examenes',
  SESIONES: '/sesiones',
  ASIGNACIONES: '/asignaciones',
  USUARIOS: '/usuarios',
  REPORTES: '/reportes',
  INSTITUCIONES: '/instituciones',
  GRUPOS: '/grupos',
  PERIODOS: '/periodos',
  EVENTOS_SOCKET: {
    ESPACIO_SESIONES: '/sesiones',
    UNIRSE_SALA: 'unirse_sala_sesion',
    ESTUDIANTE_PROGRESO: 'estudiante:progreso',
    ESTUDIANTE_FRAUDE: 'estudiante:fraude_detectado',
    SESION_FINALIZADA: 'sesion:finalizada',
  },
};

export const MENSAJES_ERROR_GENERALES = {
  SIN_PERMISOS: 'No tienes permisos para esta acción.',
  ERROR_SERVIDOR: 'Ocurrió un error en el servidor. Intenta de nuevo.',
  ERROR_RED: 'Sin conexión. Verifica tu internet.',
} as const;
