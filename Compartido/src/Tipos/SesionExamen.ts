/**
 * @archivo   SesionExamen.ts
 * @descripcion Estandariza los atributos de una sesión de examen y su visibilidad.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { EstadoSesion } from '../Enums/EstadoSesion';

export interface SesionExamen {
  id: string;
  codigoAcceso: string;
  estado: EstadoSesion;
  fechaInicio: string | null;
  fechaFin: string | null;
  duracionReal: number | null;
  descripcion: string | null;
  semillaGrupo: number;
  fechaCreacion: string;
  fechaActualizacion: string;
  examenId: string;
  creadaPorId: string;
}
