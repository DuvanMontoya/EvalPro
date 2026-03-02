/**
 * @archivo   UiAlmacen.ts
 * @descripcion Gestiona estado global de interfaz como barra lateral y preferencia de tema.
 * @modulo    Almacen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

type TemaAplicacion = 'claro' | 'oscuro';

interface EstadoUi {
  barraLateralAbierta: boolean;
  tema: TemaAplicacion;
  alternarBarraLateral: () => void;
  establecerBarraLateral: (abierta: boolean) => void;
  alternarTema: () => void;
}

/**
 * Store global de estado visual de la aplicación.
 */
export const useUiAlmacen = create<EstadoUi>()(
  immer((set) => ({
    barraLateralAbierta: true,
    tema: 'claro',
    alternarBarraLateral() {
      set((estado) => {
        estado.barraLateralAbierta = !estado.barraLateralAbierta;
      });
    },
    establecerBarraLateral(abierta) {
      set((estado) => {
        estado.barraLateralAbierta = abierta;
      });
    },
    alternarTema() {
      set((estado) => {
        estado.tema = estado.tema === 'claro' ? 'oscuro' : 'claro';
      });
    },
  })),
);
