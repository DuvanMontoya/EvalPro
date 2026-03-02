/**
 * @archivo   Respuesta.ts
 * @descripcion Tipa respuestas individuales guardadas por intento y por pregunta.
 * @modulo    Tipos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
export interface Respuesta {
  id: string;
  valorTexto: string | null;
  opcionesSeleccionadas: string[];
  esCorrecta: boolean | null;
  puntajeObtenido: number | null;
  tiempoRespuesta: number | null;
  fechaRespuesta: string;
  esSincronizada: boolean;
  intentoId: string;
  preguntaId: string;
}
