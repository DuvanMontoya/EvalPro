/**
 * @archivo   Respuestas.servicio.ts
 * @descripcion Encapsula endpoints de sincronización y cierre de intentos para extensibilidad del panel.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { RespuestaApi } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

export interface EntradaRespuestaDto {
  idPregunta: string;
  valorTexto?: string;
  opcionesSeleccionadas?: string[];
  tiempoRespuesta?: number;
}

export interface SincronizarRespuestasDto {
  idIntento: string;
  respuestas: EntradaRespuestaDto[];
}

export interface ResultadoFinalIntento {
  puntajeObtenido: number | null;
  porcentaje: number | null;
}

/**
 * Envía un lote de respuestas al backend.
 * @param dto - Respuestas por intento a sincronizar.
 */
export async function sincronizarRespuestas(dto: SincronizarRespuestasDto): Promise<{ sincronizado: boolean }> {
  const respuesta = await apiCliente.post<RespuestaApi<{ sincronizado: boolean }>>('/respuestas/sincronizar-lote', dto);
  return extraerDatos(respuesta);
}

/**
 * Finaliza un intento y devuelve resultado calculado.
 * @param idIntento - UUID del intento.
 */
export async function finalizarIntento(idIntento: string): Promise<ResultadoFinalIntento> {
  const respuesta = await apiCliente.post<RespuestaApi<ResultadoFinalIntento>>(`/intentos/${idIntento}/finalizar`);
  return extraerDatos(respuesta);
}
