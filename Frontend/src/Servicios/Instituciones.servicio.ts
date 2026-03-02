/**
 * @archivo   Instituciones.servicio.ts
 * @descripcion Consume endpoints de instituciones para gestión superadministrativa.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { API } from '@/Constantes/Api.constantes';
import { RespuestaApi } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

export type EstadoInstitucion = 'ACTIVA' | 'SUSPENDIDA' | 'ARCHIVADA';

export interface Institucion {
  id: string;
  nombre: string;
  dominio: string | null;
  estado: EstadoInstitucion;
  configuracion: Record<string, unknown> | null;
  fechaCreacion: string;
  fechaActualizacion: string;
}

export interface CrearInstitucionDto {
  nombre: string;
  dominio?: string;
  configuracion?: Record<string, unknown>;
}

export interface CambiarEstadoInstitucionDto {
  estado: EstadoInstitucion;
  razon?: string;
}

export async function listarInstituciones(): Promise<Institucion[]> {
  const respuesta = await apiCliente.get<RespuestaApi<Institucion[]>>(API.INSTITUCIONES);
  return extraerDatos(respuesta);
}

export async function crearInstitucion(dto: CrearInstitucionDto): Promise<Institucion> {
  const respuesta = await apiCliente.post<RespuestaApi<Institucion>>(API.INSTITUCIONES, dto);
  return extraerDatos(respuesta);
}

export async function cambiarEstadoInstitucion(
  idInstitucion: string,
  dto: CambiarEstadoInstitucionDto,
): Promise<Institucion> {
  const respuesta = await apiCliente.patch<RespuestaApi<Institucion>>(
    `${API.INSTITUCIONES}/${idInstitucion}/estado`,
    dto,
  );
  return extraerDatos(respuesta);
}

