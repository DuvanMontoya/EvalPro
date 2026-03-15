/**
 * @archivo   ValidadorTelemetria.util.ts
 * @descripcion Evalúa señales de fraude a partir de eventos y tiempo total de resolución.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
/**
 * Verifica si el tiempo usado en el examen es inferior al mínimo esperado.
 * @param tiempoTotalSegundos - Tiempo total transcurrido del intento.
 * @param totalPreguntas - Total de preguntas del examen.
 * @param minimoPorPregunta - Umbral mínimo de segundos por pregunta.
 * @returns Verdadero cuando el tiempo total es sospechosamente bajo.
 */
export function tiempoSospechoso(
  tiempoTotalSegundos: number,
  totalPreguntas: number,
  minimoPorPregunta: number,
): boolean {
  return tiempoTotalSegundos < totalPreguntas * minimoPorPregunta;
}
