/**
 * @archivo   SesionAlmacen.ts
 * @descripcion Centraliza estado global de monitor de sesión y alertas de fraude del panel.
 * @modulo    Almacen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import { TipoEventoIntento, TipoIncidente } from '@/Tipos';

export interface AlertaFraudeSesion {
  id: string;
  nombreEstudiante: string;
  tipoEvento: TipoEventoIntento | TipoIncidente;
  fecha: string;
}

interface EstadoSesion {
  idSesionActual: string | null;
  alertasFraude: AlertaFraudeSesion[];
  establecerSesionActual: (idSesion: string | null) => void;
  agregarAlertaFraude: (alerta: AlertaFraudeSesion) => void;
  limpiarAlertasFraude: () => void;
}

/**
 * Mantiene estado efímero de la sesión monitoreada en tiempo real.
 */
export const useSesionAlmacen = create<EstadoSesion>()(
  immer((set) => ({
    idSesionActual: null,
    alertasFraude: [],
    establecerSesionActual(idSesion) {
      set((estado) => {
        estado.idSesionActual = idSesion;
      });
    },
    agregarAlertaFraude(alerta) {
      set((estado) => {
        estado.alertasFraude.unshift(alerta);
      });
    },
    limpiarAlertasFraude() {
      set((estado) => {
        estado.alertasFraude = [];
      });
    },
  })),
);
