/**
 * @archivo   Reportes.servicio.ts
 * @descripcion Consume endpoints de reportes agregados para tablero, sesiones y estudiantes.
 * @modulo    Servicios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { API } from '@/Constantes/Api.constantes';
import { EstadoIntento, RespuestaApi } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

interface SesionResumen {
  id: string;
  codigoAcceso: string;
  estado: string;
  fechaInicio: string | null;
  fechaFin: string | null;
}

interface EstudianteReporteSesion {
  nombre: string;
  apellidos: string;
  puntaje: number | null;
  porcentaje: number | null;
  estado: EstadoIntento;
  esSospechoso: boolean;
}

export interface ReporteSesion {
  sesion: SesionResumen;
  totalEstudiantes: number;
  estudiantesQueEnviaron: number;
  estudiantesSospechosos: number;
  puntajePromedio: number | null;
  puntajeMaximo: number | null;
  puntajeMinimo: number | null;
  distribucionPuntajes: { rango: string; cantidad: number }[];
  dificultadPorPregunta: { idPregunta: string; enunciado: string; porcentajeAcierto: number }[];
  listaEstudiantes: EstudianteReporteSesion[];
}

export interface ReporteEstudiante {
  idEstudiante: string;
  nombreCompleto: string;
  intentos: {
    idSesion: string;
    codigoAcceso: string;
    tituloExamen: string;
    estado: EstadoIntento;
    puntajeObtenido: number | null;
    porcentaje: number | null;
    esSospechoso: boolean;
  }[];
}

/**
 * Obtiene el reporte completo de una sesión.
 * @param idSesion - UUID de sesión.
 */
export async function obtenerReporteSesion(idSesion: string): Promise<ReporteSesion> {
  const respuesta = await apiCliente.get<RespuestaApi<ReporteSesion>>(`${API.REPORTES}/sesion/${idSesion}`);
  return extraerDatos(respuesta);
}

/**
 * Obtiene histórico de intentos para un estudiante.
 * @param idEstudiante - UUID del estudiante.
 */
export async function obtenerReporteEstudiante(idEstudiante: string): Promise<ReporteEstudiante> {
  const respuesta = await apiCliente.get<RespuestaApi<ReporteEstudiante>>(`${API.REPORTES}/estudiante/${idEstudiante}`);
  return extraerDatos(respuesta);
}
