/**
 * @archivo   EventoTelemetria.ts
 * @descripcion Describe cada evento registrado durante la rendición del examen.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { TipoEventoTelemetria } from '../Enums/TipoEventoTelemetria';

export interface EventoTelemetria {
  id: string;
  tipo: TipoEventoTelemetria;
  descripcion: string | null;
  metadatos: Record<string, unknown> | null;
  numeroPregunta: number | null;
  tiempoTranscurrido: number | null;
  fechaEvento: string;
  intentoId: string;
}
