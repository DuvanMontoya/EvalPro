/**
 * @archivo   Asignaciones.servicio.ts
 * @descripcion Gestiona creación de asignaciones de examen para flujos canónicos de sesiones.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-03
 */
import { API } from '@/Constantes/Api.constantes';
import { RespuestaApi } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

export interface CrearAsignacionDto {
  idExamen: string;
  idGrupo?: string;
  idEstudiante?: string;
  fechaInicio: string;
  fechaFin: string;
  intentosMaximos: number;
  mostrarPuntajeInmediato: boolean;
  mostrarRespuestasCorrectas: boolean;
  publicarResultadosEn?: string;
}

export interface AsignacionExamen {
  id: string;
  idInstitucion: string;
  idExamen: string;
  idGrupo: string | null;
  idEstudiante: string | null;
  fechaInicio: string;
  fechaFin: string;
  intentosMaximos: number;
  mostrarPuntajeInmediato: boolean;
  mostrarRespuestasCorrectas: boolean;
  publicarResultadosEn: string | null;
  creadoPor: string;
  fechaCreacion: string;
}

/**
 * Crea una asignación de examen por grupo o por estudiante.
 * @param dto - Carga útil de asignación.
 */
export async function crearAsignacion(dto: CrearAsignacionDto): Promise<AsignacionExamen> {
  const respuesta = await apiCliente.post<RespuestaApi<AsignacionExamen>>(API.ASIGNACIONES, dto);
  return extraerDatos(respuesta);
}

