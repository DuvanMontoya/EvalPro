/**
 * @archivo   Preguntas.servicio.ts
 * @descripcion Consume endpoints anidados de preguntas y reordenamiento por examen.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { API } from '@/Constantes/Api.constantes';
import { Pregunta, RespuestaApi, TipoPregunta } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

export interface CrearOpcionDto {
  letra: string;
  contenido: string;
  esCorrecta: boolean;
  orden: number;
}

export interface CrearPreguntaDto {
  enunciado: string;
  tipo: TipoPregunta;
  puntaje: number;
  tiempoSugerido?: number;
  imagenUrl?: string;
  opciones?: CrearOpcionDto[];
}

export type ActualizarPreguntaDto = Partial<CrearPreguntaDto>;

/**
 * Lista preguntas de un examen.
 * @param idExamen - UUID del examen.
 */
export async function listarPreguntas(idExamen: string): Promise<Pregunta[]> {
  const respuesta = await apiCliente.get<RespuestaApi<Pregunta[]>>(`${API.EXAMENES}/${idExamen}/preguntas`);
  return extraerDatos(respuesta);
}

/**
 * Crea una pregunta dentro de un examen.
 * @param idExamen - UUID del examen.
 * @param dto - Datos de creación.
 */
export async function crearPregunta(idExamen: string, dto: CrearPreguntaDto): Promise<Pregunta> {
  const respuesta = await apiCliente.post<RespuestaApi<Pregunta>>(`${API.EXAMENES}/${idExamen}/preguntas`, dto);
  return extraerDatos(respuesta);
}

/**
 * Actualiza una pregunta existente.
 * @param idExamen - UUID del examen.
 * @param idPregunta - UUID de la pregunta.
 * @param dto - Datos parciales de actualización.
 */
export async function actualizarPregunta(
  idExamen: string,
  idPregunta: string,
  dto: ActualizarPreguntaDto,
): Promise<Pregunta> {
  const respuesta = await apiCliente.put<RespuestaApi<Pregunta>>(
    `${API.EXAMENES}/${idExamen}/preguntas/${idPregunta}`,
    dto,
  );
  return extraerDatos(respuesta);
}

/**
 * Elimina una pregunta de un examen.
 * @param idExamen - UUID del examen.
 * @param idPregunta - UUID de la pregunta.
 */
export async function eliminarPregunta(idExamen: string, idPregunta: string): Promise<{ eliminada: boolean }> {
  const respuesta = await apiCliente.delete<RespuestaApi<{ eliminada: boolean }>>(
    `${API.EXAMENES}/${idExamen}/preguntas/${idPregunta}`,
  );
  return extraerDatos(respuesta);
}

/**
 * Reordena preguntas después de drag-and-drop.
 * @param idExamen - UUID del examen.
 * @param preguntas - Nuevo orden de preguntas.
 */
export async function reordenarPreguntas(
  idExamen: string,
  preguntas: { idPregunta: string; orden: number }[],
): Promise<Pregunta[]> {
  const respuesta = await apiCliente.patch<RespuestaApi<Pregunta[]>>(`${API.EXAMENES}/${idExamen}/preguntas/reordenar`, {
    preguntas,
  });
  return extraerDatos(respuesta);
}
