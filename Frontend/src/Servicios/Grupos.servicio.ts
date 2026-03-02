/**
 * @archivo   Grupos.servicio.ts
 * @descripcion Consume endpoints de grupos académicos y membresías.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { API } from '@/Constantes/Api.constantes';
import { RespuestaApi } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

export type EstadoGrupo = 'BORRADOR' | 'ACTIVO' | 'CERRADO' | 'ARCHIVADO';

export interface GrupoDocenteItem {
  id: string;
  idDocente: string;
  activo: boolean;
  docente: {
    id: string;
    nombre: string;
    apellidos: string;
    correo: string;
  };
}

export interface GrupoEstudianteItem {
  id: string;
  idEstudiante: string;
  activo: boolean;
  estudiante: {
    id: string;
    nombre: string;
    apellidos: string;
    correo: string;
  };
}

export interface GrupoAcademico {
  id: string;
  idInstitucion: string;
  idPeriodo: string;
  nombre: string;
  descripcion: string | null;
  estado: EstadoGrupo;
  codigoAcceso: string;
  fechaCreacion: string;
  fechaActualizacion: string;
  periodo: {
    id: string;
    nombre: string;
    activo: boolean;
    fechaInicio: string;
    fechaFin: string;
  };
  docentes: GrupoDocenteItem[];
  estudiantes: GrupoEstudianteItem[];
}

export interface CrearGrupoDto {
  nombre: string;
  descripcion?: string;
  idPeriodo: string;
  idInstitucion?: string;
}

export async function listarGrupos(idInstitucion?: string): Promise<GrupoAcademico[]> {
  const respuesta = await apiCliente.get<RespuestaApi<GrupoAcademico[]>>(API.GRUPOS, {
    params: idInstitucion ? { idInstitucion } : undefined,
  });
  return extraerDatos(respuesta);
}

export async function obtenerGrupoPorId(idGrupo: string): Promise<GrupoAcademico> {
  const respuesta = await apiCliente.get<RespuestaApi<GrupoAcademico>>(`${API.GRUPOS}/${idGrupo}`);
  return extraerDatos(respuesta);
}

export async function crearGrupo(dto: CrearGrupoDto): Promise<GrupoAcademico> {
  const respuesta = await apiCliente.post<RespuestaApi<GrupoAcademico>>(API.GRUPOS, dto);
  return extraerDatos(respuesta);
}

export async function asignarDocenteGrupo(idGrupo: string, idDocente: string): Promise<unknown> {
  const respuesta = await apiCliente.post<RespuestaApi<unknown>>(`${API.GRUPOS}/${idGrupo}/docentes`, { idDocente });
  return extraerDatos(respuesta);
}

export async function inscribirEstudianteGrupo(idGrupo: string, idEstudiante: string): Promise<unknown> {
  const respuesta = await apiCliente.post<RespuestaApi<unknown>>(`${API.GRUPOS}/${idGrupo}/estudiantes`, {
    idEstudiante,
  });
  return extraerDatos(respuesta);
}

export async function cambiarEstadoGrupo(idGrupo: string, estado: EstadoGrupo): Promise<GrupoAcademico> {
  const respuesta = await apiCliente.patch<RespuestaApi<GrupoAcademico>>(`${API.GRUPOS}/${idGrupo}/estado`, {
    estado,
  });
  return extraerDatos(respuesta);
}

