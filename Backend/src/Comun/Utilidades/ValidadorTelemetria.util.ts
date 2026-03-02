/**
 * @archivo   ValidadorTelemetria.util.ts
 * @descripcion Evalúa señales de fraude a partir de eventos y tiempo total de resolución.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { TipoEventoTelemetria } from '@prisma/client';

/**
 * Indica si un tipo de evento corresponde a fraude crítico inmediato.
 * @param tipo - Tipo de evento de telemetría.
 * @returns Verdadero cuando el evento es crítico.
 */
export function esEventoFraudeCritico(tipo: TipoEventoTelemetria): boolean {
  return (
    tipo === TipoEventoTelemetria.APLICACION_EN_SEGUNDO_PLANO ||
    tipo === TipoEventoTelemetria.PANTALLA_ABANDONADA ||
    tipo === TipoEventoTelemetria.FORZAR_CIERRE
  );
}

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
