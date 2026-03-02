/**
 * @archivo   Periodos.servicio.ts
 * @descripcion Consume endpoints de periodos académicos para administración institucional.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { API } from '@/Constantes/Api.constantes';
import { RespuestaApi } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

export interface PeriodoAcademico {
  id: string;
  idInstitucion: string;
  nombre: string;
  fechaInicio: string;
  fechaFin: string;
  activo: boolean;
  fechaCreacion: string;
}

export interface CrearPeriodoAcademicoDto {
  nombre: string;
  fechaInicio: string;
  fechaFin: string;
  activo?: boolean;
  idInstitucion?: string;
}

export async function listarPeriodos(idInstitucion?: string): Promise<PeriodoAcademico[]> {
  const respuesta = await apiCliente.get<RespuestaApi<PeriodoAcademico[]>>(API.PERIODOS, {
    params: idInstitucion ? { idInstitucion } : undefined,
  });
  return extraerDatos(respuesta);
}

export async function crearPeriodo(dto: CrearPeriodoAcademicoDto): Promise<PeriodoAcademico> {
  const respuesta = await apiCliente.post<RespuestaApi<PeriodoAcademico>>(API.PERIODOS, dto);
  return extraerDatos(respuesta);
}

export async function actualizarEstadoPeriodo(idPeriodo: string, activo: boolean): Promise<PeriodoAcademico> {
  const respuesta = await apiCliente.patch<RespuestaApi<PeriodoAcademico>>(
    `${API.PERIODOS}/${idPeriodo}/estado`,
    { activo },
  );
  return extraerDatos(respuesta);
}

