/**
 * @archivo   EventoIntento.ts
 * @descripcion Describe cada evento auditado durante el ciclo de vida del intento.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { TipoEventoIntento } from '../Enums/TipoEventoIntento';

export interface EventoIntento {
  id: string;
  tipo: TipoEventoIntento;
  descripcion: string | null;
  metadatos: Record<string, unknown> | null;
  numeroPregunta?: number | null;
  tiempoTranscurrido?: number | null;
  fechaEvento: string;
  intentoId: string;
}
