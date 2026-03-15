/**
 * @archivo   IncidenteIntento.ts
 * @descripcion Modela incidentes de seguridad acumulados sobre un intento.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { TipoIncidente } from '../Enums/TipoIncidente';

export interface IncidenteIntento {
  id: string;
  tipo: TipoIncidente;
  descripcion: string | null;
  contadorAcumulado: number;
  altoRiesgo: boolean;
  fechaRegistro: string;
  intentoId: string;
}
