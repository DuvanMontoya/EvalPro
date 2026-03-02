/**
 * @archivo   Sesiones.servicio.ts
 * @descripcion Administra consumo API para ciclo de vida de sesiones de examen.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { API } from '@/Constantes/Api.constantes';
import { EstadoSesion, RespuestaApi, SesionExamen } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

export interface CrearSesionDto {
  idExamen: string;
  descripcion?: string;
}

interface ParametrosListaSesiones {
  estado?: EstadoSesion;
  limite?: number;
  orden?: string;
}

/**
 * Lista sesiones disponibles para el usuario.
 * @param parametros - Filtros opcionales de estado y orden.
 */
export async function listarSesiones(parametros?: ParametrosListaSesiones): Promise<SesionExamen[]> {
  const respuesta = await apiCliente.get<RespuestaApi<SesionExamen[]>>(API.SESIONES, {
    params: parametros,
  });
  return extraerDatos(respuesta);
}

/**
 * Crea una sesión para un examen publicado.
 * @param dto - Datos de creación.
 */
export async function crearSesion(dto: CrearSesionDto): Promise<SesionExamen> {
  const respuesta = await apiCliente.post<RespuestaApi<SesionExamen>>(API.SESIONES, dto);
  return extraerDatos(respuesta);
}

/**
 * Obtiene detalle de sesión por ID.
 * @param idSesion - UUID de la sesión.
 */
export async function obtenerSesionPorId(idSesion: string): Promise<SesionExamen> {
  const respuesta = await apiCliente.get<RespuestaApi<SesionExamen>>(`${API.SESIONES}/${idSesion}`);
  return extraerDatos(respuesta);
}

/**
 * Activa una sesión pendiente.
 * @param idSesion - UUID de la sesión.
 */
export async function activarSesion(idSesion: string): Promise<SesionExamen> {
  const respuesta = await apiCliente.post<RespuestaApi<SesionExamen>>(`${API.SESIONES}/${idSesion}/activar`);
  return extraerDatos(respuesta);
}

/**
 * Finaliza una sesión activa.
 * @param idSesion - UUID de la sesión.
 */
export async function finalizarSesion(idSesion: string): Promise<SesionExamen> {
  const respuesta = await apiCliente.post<RespuestaApi<SesionExamen>>(`${API.SESIONES}/${idSesion}/finalizar`);
  return extraerDatos(respuesta);
}

/**
 * Cancela una sesión pendiente o activa.
 * @param idSesion - UUID de la sesión.
 */
export async function cancelarSesion(idSesion: string): Promise<SesionExamen> {
  const respuesta = await apiCliente.post<RespuestaApi<SesionExamen>>(`${API.SESIONES}/${idSesion}/cancelar`);
  return extraerDatos(respuesta);
}
