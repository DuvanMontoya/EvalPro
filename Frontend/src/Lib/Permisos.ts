/**
 * @archivo   Permisos.ts
 * @descripcion Centraliza reglas de visibilidad y acciones por rol y estado de dominio.
 * @modulo    Lib
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { EstadoExamen, EstadoSesion, RolUsuario } from '@/Tipos';

/**
 * Valida si el rol puede acceder a rutas administrativas del panel.
 * @param rol - Rol del usuario autenticado.
 */
export function rolPuedeAccederPanel(rol: RolUsuario | null | undefined): boolean {
  return rol === RolUsuario.SUPERADMINISTRADOR || rol === RolUsuario.ADMINISTRADOR || rol === RolUsuario.DOCENTE;
}

/**
 * Define si el rol puede crear o modificar exámenes.
 * @param rol - Rol autenticado.
 */
export function rolPuedeGestionarExamenes(rol: RolUsuario | null | undefined): boolean {
  return rol === RolUsuario.SUPERADMINISTRADOR || rol === RolUsuario.DOCENTE;
}

/**
 * Define si el rol puede crear, activar o finalizar sesiones.
 * @param rol - Rol autenticado.
 */
export function rolPuedeGestionarSesiones(rol: RolUsuario | null | undefined): boolean {
  return rol === RolUsuario.SUPERADMINISTRADOR || rol === RolUsuario.DOCENTE;
}

/**
 * Define si el rol puede crear estudiantes desde el panel.
 * @param rol - Rol autenticado.
 */
export function rolPuedeCrearEstudiantes(rol: RolUsuario | null | undefined): boolean {
  return rol === RolUsuario.SUPERADMINISTRADOR || rol === RolUsuario.ADMINISTRADOR;
}

/**
 * Evalúa si el examen permite edición de contenido y preguntas.
 * @param rol - Rol autenticado.
 * @param estado - Estado actual del examen.
 */
export function puedeEditarContenidoExamen(
  rol: RolUsuario | null | undefined,
  estado: EstadoExamen | undefined,
): boolean {
  return rolPuedeGestionarExamenes(rol) && estado === EstadoExamen.BORRADOR;
}

/**
 * Evalúa si el examen permite publicación desde UI.
 * @param rol - Rol autenticado.
 * @param estado - Estado actual del examen.
 */
export function puedePublicarExamen(
  rol: RolUsuario | null | undefined,
  estado: EstadoExamen | undefined,
): boolean {
  return rolPuedeGestionarExamenes(rol) && estado === EstadoExamen.BORRADOR;
}

/**
 * Evalúa si el examen permite archivado desde UI.
 * @param rol - Rol autenticado.
 * @param estado - Estado actual del examen.
 */
export function puedeArchivarExamen(
  rol: RolUsuario | null | undefined,
  estado: EstadoExamen | undefined,
): boolean {
  return rolPuedeGestionarExamenes(rol) && estado !== EstadoExamen.ARCHIVADO;
}

/**
 * Evalúa si la sesión puede activarse.
 * @param rol - Rol autenticado.
 * @param estado - Estado actual de la sesión.
 */
export function puedeActivarSesion(
  rol: RolUsuario | null | undefined,
  estado: EstadoSesion | undefined,
): boolean {
  return rolPuedeGestionarSesiones(rol) && estado === EstadoSesion.PENDIENTE;
}

/**
 * Evalúa si la sesión puede finalizarse.
 * @param rol - Rol autenticado.
 * @param estado - Estado actual de la sesión.
 */
export function puedeFinalizarSesion(
  rol: RolUsuario | null | undefined,
  estado: EstadoSesion | undefined,
): boolean {
  return rolPuedeGestionarSesiones(rol) && estado === EstadoSesion.ACTIVA;
}
