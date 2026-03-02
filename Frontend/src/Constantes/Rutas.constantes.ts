/**
 * @archivo   Rutas.constantes.ts
 * @descripcion Define todas las rutas del panel administrativo en un solo objeto tipado.
 * @modulo    Constantes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
export const RUTAS = {
  INICIO_SESION: '/IniciarSesion',
  TABLERO: '/Tablero',
  INSTITUCIONES: '/Instituciones',
  GRUPOS: '/Grupos',
  EXAMENES: '/Examenes',
  EXAMEN_NUEVO: '/Examenes/Nuevo',
  EXAMEN_DETALLE: (id: string) => `/Examenes/${id}`,
  EXAMEN_EDITAR: (id: string) => `/Examenes/${id}/Editar`,
  SESIONES: '/Sesiones',
  SESION_NUEVA: '/Sesiones/Nueva',
  SESION_DETALLE: (id: string) => `/Sesiones/${id}`,
  SESION_RESULTADOS: (id: string) => `/Sesiones/${id}/Resultados`,
  ESTUDIANTES: '/Estudiantes',
  ESTUDIANTE_NUEVO: '/Estudiantes/Nuevo',
  ESTUDIANTE_DETALLE: (id: string) => `/Estudiantes/${id}`,
  REPORTES: '/Reportes',
  CONFIGURACION: '/Configuracion',
} as const;
