/**
 * @archivo   useAutenticacion.ts
 * @descripcion Exponer helpers de autenticación para componentes cliente del panel.
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useAutenticacionAlmacen } from '@/Almacen/AutenticacionAlmacen';

/**
 * Provee acceso reactivo a estado y acciones de autenticación.
 */
export function useAutenticacion() {
  const usuario = useAutenticacionAlmacen((estado) => estado.usuario);
  const estaAutenticado = useAutenticacionAlmacen((estado) => estado.estaAutenticado);
  const cargando = useAutenticacionAlmacen((estado) => estado.cargando);
  const requiereCambioContrasena = useAutenticacionAlmacen((estado) => estado.requiereCambioContrasena);
  const iniciarSesion = useAutenticacionAlmacen((estado) => estado.iniciarSesion);
  const completarPrimerLogin = useAutenticacionAlmacen((estado) => estado.completarPrimerLogin);
  const verificarSesion = useAutenticacionAlmacen((estado) => estado.verificarSesion);
  const cerrarSesion = useAutenticacionAlmacen((estado) => estado.cerrarSesion);

  return {
    usuario,
    estaAutenticado,
    cargando,
    requiereCambioContrasena,
    iniciarSesion,
    completarPrimerLogin,
    verificarSesion,
    cerrarSesion,
  };
}
