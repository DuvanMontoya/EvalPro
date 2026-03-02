/**
 * @archivo   Api.constantes.ts
 * @descripcion Centraliza rutas de API, eventos de websocket y nombres de cookies del frontend.
 * @modulo    Constantes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
export const API = {
  BASE_PUBLICA: process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3001/api/v1',
  WEBSOCKET: process.env.NEXT_PUBLIC_WEBSOCKET_URL ?? 'http://localhost:3001',
  VERSION: process.env.NEXT_PUBLIC_VERSION_APP ?? '1.0.0',
  COOKIE_REFRESH: 'token_refresh_evalpro',
  AUTENTICACION: {
    INICIAR_SESION: '/autenticacion/iniciar-sesion',
    REFRESCAR_TOKENS: '/autenticacion/refrescar-tokens',
    CERRAR_SESION: '/autenticacion/cerrar-sesion',
  },
  EXAMENES: '/examenes',
  SESIONES: '/sesiones',
  USUARIOS: '/usuarios',
  REPORTES: '/reportes',
  EVENTOS_SOCKET: {
    ESPACIO_SESIONES: '/sesiones',
    UNIRSE_SALA: 'unirse_sala_sesion',
    ESTUDIANTE_PROGRESO: 'estudiante:progreso',
    ESTUDIANTE_FRAUDE: 'estudiante:fraude_detectado',
    SESION_FINALIZADA: 'sesion:finalizada',
  },
} as const;

export const MENSAJES_ERROR_GENERALES = {
  SIN_PERMISOS: 'No tienes permisos para esta acción.',
  ERROR_SERVIDOR: 'Ocurrió un error en el servidor. Intenta de nuevo.',
  ERROR_RED: 'Sin conexión. Verifica tu internet.',
} as const;
