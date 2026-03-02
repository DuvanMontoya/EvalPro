/**
 * @archivo   AutenticacionAlmacen.ts
 * @descripcion Mantiene estado de usuario autenticado y ciclo de sesión con refresh token seguro.
 * @modulo    Almacen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { RolUsuario, Usuario } from '@/Tipos';
import { establecerTokenAcceso, obtenerTokenAcceso } from '@/Servicios/ApiCliente';
import {
  cerrarSesion,
  eliminarRefreshDeCookie,
  guardarRefreshEnCookie,
  iniciarSesion,
  IniciarSesionDto,
  refrescarDesdeCookie,
} from '@/Servicios/Autenticacion.servicio';
import { crearErrorApiNormalizado } from '@/Lib/ErroresApi';

interface EstadoAutenticacion {
  usuario: Usuario | null;
  estaAutenticado: boolean;
  cargando: boolean;
  iniciarSesion: (credenciales: IniciarSesionDto) => Promise<void>;
  cerrarSesion: () => Promise<void>;
  verificarSesion: () => Promise<void>;
}

/**
 * Store de autenticación con sesión en memoria y soporte de refresh por cookie httpOnly.
 */
export const useAutenticacionAlmacen = create<EstadoAutenticacion>()(
  immer((set, get) => ({
    usuario: null,
    estaAutenticado: false,
    cargando: false,
    async iniciarSesion(credenciales) {
      set((estado) => {
        estado.cargando = true;
      });

      try {
        const sesion = await iniciarSesion(credenciales);
        if (sesion.usuario.rol === RolUsuario.ESTUDIANTE) {
          throw crearErrorApiNormalizado(
            'El rol estudiante no puede acceder al panel administrativo.',
            403,
            'SIN_PERMISOS',
          );
        }

        await guardarRefreshEnCookie(sesion.tokenRefresh);
        establecerTokenAcceso(sesion.tokenAcceso);

        set((estado) => {
          estado.usuario = sesion.usuario;
          estado.estaAutenticado = true;
        });
      } finally {
        set((estado) => {
          estado.cargando = false;
        });
      }
    },
    async verificarSesion() {
      set((estado) => {
        estado.cargando = true;
      });

      try {
        const tokenAcceso = obtenerTokenAcceso();
        const usuario = get().usuario;
        if (tokenAcceso && usuario) {
          set((estado) => {
            estado.estaAutenticado = true;
          });
          return;
        }

        const refrescada = await refrescarDesdeCookie();
        if (refrescada.usuario.rol === RolUsuario.ESTUDIANTE) {
          throw crearErrorApiNormalizado(
            'El rol estudiante no puede acceder al panel administrativo.',
            403,
            'SIN_PERMISOS',
          );
        }

        establecerTokenAcceso(refrescada.tokenAcceso);

        set((estado) => {
          estado.usuario = refrescada.usuario;
          estado.estaAutenticado = true;
        });
      } catch {
        await eliminarRefreshDeCookie().catch(() => undefined);
        establecerTokenAcceso(null);
        set((estado) => {
          estado.usuario = null;
          estado.estaAutenticado = false;
        });
        throw new Error('Sesión no válida');
      } finally {
        set((estado) => {
          estado.cargando = false;
        });
      }
    },
    async cerrarSesion() {
      set((estado) => {
        estado.cargando = true;
      });

      try {
        if (obtenerTokenAcceso()) {
          await cerrarSesion().catch(() => undefined);
        }
      } finally {
        await eliminarRefreshDeCookie().catch(() => undefined);
        establecerTokenAcceso(null);
        set((estado) => {
          estado.usuario = null;
          estado.estaAutenticado = false;
          estado.cargando = false;
        });
      }
    },
  })),
);
