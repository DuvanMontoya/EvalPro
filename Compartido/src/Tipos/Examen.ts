/**
 * @archivo   Examen.ts
 * @descripcion Modela los datos compartidos de definición y publicación de exámenes.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { EstadoExamen } from '../Enums/EstadoExamen';
import { ModalidadExamen } from '../Enums/ModalidadExamen';

export interface Examen {
  id: string;
  titulo: string;
  descripcion: string | null;
  instrucciones: string | null;
  identificadorCuadernillo?: string | null;
  modalidad: ModalidadExamen;
  estado: EstadoExamen;
  duracionMinutos: number;
  totalPreguntas: number;
  puntajeMaximo: number;
  semillaAleatorizacion: number;
  permitirNavegacion: boolean;
  permitirCambioRespuesta?: boolean;
  mostrarPuntaje: boolean;
  fechaCreacion: string;
  fechaActualizacion: string;
  creadoPorId: string;
}
