/**
 * @archivo   CalculadorPuntaje.util.ts
 * @descripcion Contiene funciones puras para evaluar corrección y puntaje de respuestas.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */

/**
 * Compara dos conjuntos de letras sin importar el orden para selección múltiple.
 * @param seleccionadas - Letras elegidas por el estudiante.
 * @param correctas - Letras correctas definidas en la pregunta.
 * @returns Verdadero cuando ambos conjuntos son idénticos.
 */
export function compararConjuntosLetras(seleccionadas: string[], correctas: string[]): boolean {
  if (seleccionadas.length !== correctas.length) {
    return false;
  }

  const ordenadasSeleccionadas = [...seleccionadas].sort();
  const ordenadasCorrectas = [...correctas].sort();
  return ordenadasSeleccionadas.every((valor: string, indice: number) => valor === ordenadasCorrectas[indice]);
}

/**
 * Calcula porcentaje de avance respecto del puntaje máximo del examen.
 * @param puntajeObtenido - Puntaje acumulado del intento.
 * @param puntajeMaximo - Puntaje máximo definido por el examen.
 * @returns Porcentaje en rango 0-100 redondeado a 2 decimales.
 */
export function calcularPorcentaje(puntajeObtenido: number, puntajeMaximo: number): number {
  if (puntajeMaximo <= 0) {
    return 0;
  }

  const porcentaje = (puntajeObtenido / puntajeMaximo) * 100;
  return Number(porcentaje.toFixed(2));
}
