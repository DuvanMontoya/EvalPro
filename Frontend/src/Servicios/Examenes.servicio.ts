/**
 * @archivo   Examenes.servicio.ts
 * @descripcion Gestiona consumo API para CRUD de exámenes y transición de estados.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { API } from '@/Constantes/Api.constantes';
import { Examen, ModalidadExamen, RespuestaApi } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

export interface CrearExamenDto {
  titulo: string;
  descripcion?: string;
  instrucciones?: string;
  modalidad: ModalidadExamen;
  duracionMinutos: number;
  permitirNavegacion: boolean;
  mostrarPuntaje: boolean;
}

export type ActualizarExamenDto = Partial<CrearExamenDto>;

/**
 * Lista exámenes visibles para el usuario autenticado.
 */
export async function listarExamenes(): Promise<Examen[]> {
  const respuesta = await apiCliente.get<RespuestaApi<Examen[]>>(API.EXAMENES);
  return extraerDatos(respuesta);
}

/**
 * Obtiene detalle de un examen por identificador.
 * @param idExamen - UUID del examen.
 */
export async function obtenerExamenPorId(idExamen: string): Promise<Examen> {
  const respuesta = await apiCliente.get<RespuestaApi<Examen>>(`${API.EXAMENES}/${idExamen}`);
  return extraerDatos(respuesta);
}

/**
 * Crea un examen en estado borrador.
 * @param dto - Datos de creación validados.
 */
export async function crearExamen(dto: CrearExamenDto): Promise<Examen> {
  const respuesta = await apiCliente.post<RespuestaApi<Examen>>(API.EXAMENES, dto);
  return extraerDatos(respuesta);
}

/**
 * Actualiza parcialmente un examen existente.
 * @param idExamen - UUID del examen.
 * @param dto - Cambios solicitados.
 */
export async function actualizarExamen(idExamen: string, dto: ActualizarExamenDto): Promise<Examen> {
  const respuesta = await apiCliente.patch<RespuestaApi<Examen>>(`${API.EXAMENES}/${idExamen}`, dto);
  return extraerDatos(respuesta);
}

/**
 * Cambia un examen a estado archivado.
 * @param idExamen - UUID del examen.
 */
export async function archivarExamen(idExamen: string): Promise<Examen> {
  const respuesta = await apiCliente.delete<RespuestaApi<Examen>>(`${API.EXAMENES}/${idExamen}`);
  return extraerDatos(respuesta);
}

/**
 * Publica un examen borrador tras validaciones del backend.
 * @param idExamen - UUID del examen.
 */
export async function publicarExamen(idExamen: string): Promise<Examen> {
  const respuesta = await apiCliente.post<RespuestaApi<Examen>>(`${API.EXAMENES}/${idExamen}/publicar`);
  return extraerDatos(respuesta);
}
