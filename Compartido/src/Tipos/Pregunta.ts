/**
 * @archivo   Pregunta.ts
 * @descripcion Define el contrato de preguntas y opciones de respuesta para consumo compartido.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { TipoPregunta } from '../Enums/TipoPregunta';

export interface OpcionRespuesta {
  id: string;
  letra: string;
  contenido: string;
  esCorrecta?: boolean;
  orden: number;
  preguntaId: string;
}

export interface Pregunta {
  id: string;
  enunciado: string;
  tipo: TipoPregunta;
  orden: number;
  puntaje: number;
  tiempoSugerido: number | null;
  imagenUrl: string | null;
  fechaCreacion: string;
  fechaActualizacion: string;
  examenId: string;
  opciones: OpcionRespuesta[];
}
