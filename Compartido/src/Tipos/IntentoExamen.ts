/**
 * @archivo   IntentoExamen.ts
 * @descripcion Contiene el estado operativo y de fraude de cada intento de examen.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { EstadoIntento } from '../Enums/EstadoIntento';

export interface IntentoExamen {
  id: string;
  estado: EstadoIntento;
  semillaPersonal: number;
  puntajeObtenido: number | null;
  porcentaje: number | null;
  fechaInicio: string;
  fechaEnvio: string | null;
  ipDispositivo: string | null;
  modeloDispositivo: string | null;
  sistemaOperativo: string | null;
  versionApp: string | null;
  esSospechoso: boolean;
  razonSospecha: string | null;
  estudianteId: string;
  sesionId: string;
}
