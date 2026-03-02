/**
 * @archivo   Intentos.servicio.ts
 * @descripcion Define operaciones de lectura de intentos y telemetría para vistas administrativas.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { RespuestaApi } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

export interface EventoIntentoTelemetria {
  id: string;
  tipo: string;
  descripcion: string | null;
  fechaEvento: string;
}

/**
 * Consulta eventos de telemetría de un intento específico.
 * @param idIntento - UUID del intento.
 */
export async function listarTelemetriaIntento(idIntento: string): Promise<EventoIntentoTelemetria[]> {
  const respuesta = await apiCliente.get<RespuestaApi<EventoIntentoTelemetria[]>>(`/intentos/${idIntento}/telemetria`);
  return extraerDatos(respuesta);
}
