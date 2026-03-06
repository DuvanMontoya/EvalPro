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

export interface ConfiguracionAntifraudeRed {
  ventanaSegundos: number;
  maxReconexionesVentana: number;
  maxCambiosTipoRedVentana: number;
  maxTiempoOfflineSegundos: number;
  riesgoPorReconexion: number;
  riesgoPorCambioTipoRed: number;
  riesgoPorOfflineExtenso: number;
  umbralRiesgoSospechoso: number;
  umbralRiesgoCritico: number;
}

export interface ActualizarConfiguracionAntifraudeDto {
  red: ConfiguracionAntifraudeRed;
}

export const CONFIGURACION_ANTIFRAUDE_RED_POR_DEFECTO: ConfiguracionAntifraudeRed = {
  ventanaSegundos: 120,
  maxReconexionesVentana: 3,
  maxCambiosTipoRedVentana: 4,
  maxTiempoOfflineSegundos: 90,
  riesgoPorReconexion: 8,
  riesgoPorCambioTipoRed: 6,
  riesgoPorOfflineExtenso: 10,
  umbralRiesgoSospechoso: 30,
  umbralRiesgoCritico: 60,
};

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

export async function actualizarConfiguracionAntifraudeInstitucion(
  idInstitucion: string,
  dto: ActualizarConfiguracionAntifraudeDto,
): Promise<Institucion> {
  const respuesta = await apiCliente.patch<RespuestaApi<Institucion>>(
    `${API.INSTITUCIONES}/${idInstitucion}/configuracion-antifraude`,
    dto,
  );
  return extraerDatos(respuesta);
}

function extraerObjeto(valor: unknown): Record<string, unknown> | null {
  if (!valor || typeof valor !== 'object' || Array.isArray(valor)) {
    return null;
  }
  return valor as Record<string, unknown>;
}

function normalizarNumero(
  valor: unknown,
  minimo: number,
  maximo: number,
  defecto: number,
): number {
  if (typeof valor === 'number' && Number.isFinite(valor)) {
    return Math.min(maximo, Math.max(minimo, Math.round(valor)));
  }
  if (typeof valor === 'string' && valor.trim().length > 0) {
    const convertido = Number.parseInt(valor, 10);
    if (Number.isFinite(convertido)) {
      return Math.min(maximo, Math.max(minimo, convertido));
    }
  }
  return defecto;
}

export function obtenerConfiguracionAntifraudeRed(
  configuracion: Record<string, unknown> | null | undefined,
): ConfiguracionAntifraudeRed {
  const antifraude = extraerObjeto(configuracion)?.antifraude;
  const red = extraerObjeto(extraerObjeto(antifraude)?.red);
  const base = CONFIGURACION_ANTIFRAUDE_RED_POR_DEFECTO;
  const umbralSospechoso = normalizarNumero(red?.umbralRiesgoSospechoso, 0, 100, base.umbralRiesgoSospechoso);
  const umbralCritico = normalizarNumero(red?.umbralRiesgoCritico, 1, 100, base.umbralRiesgoCritico);

  return {
    ventanaSegundos: normalizarNumero(red?.ventanaSegundos, 30, 3600, base.ventanaSegundos),
    maxReconexionesVentana: normalizarNumero(
      red?.maxReconexionesVentana,
      1,
      30,
      base.maxReconexionesVentana,
    ),
    maxCambiosTipoRedVentana: normalizarNumero(
      red?.maxCambiosTipoRedVentana,
      1,
      30,
      base.maxCambiosTipoRedVentana,
    ),
    maxTiempoOfflineSegundos: normalizarNumero(
      red?.maxTiempoOfflineSegundos,
      5,
      900,
      base.maxTiempoOfflineSegundos,
    ),
    riesgoPorReconexion: normalizarNumero(red?.riesgoPorReconexion, 1, 50, base.riesgoPorReconexion),
    riesgoPorCambioTipoRed: normalizarNumero(
      red?.riesgoPorCambioTipoRed,
      1,
      50,
      base.riesgoPorCambioTipoRed,
    ),
    riesgoPorOfflineExtenso: normalizarNumero(
      red?.riesgoPorOfflineExtenso,
      1,
      50,
      base.riesgoPorOfflineExtenso,
    ),
    umbralRiesgoSospechoso: umbralSospechoso,
    umbralRiesgoCritico: Math.max(umbralCritico, umbralSospechoso),
  };
}
