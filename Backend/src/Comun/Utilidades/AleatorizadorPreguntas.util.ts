/**
 * @archivo   AleatorizadorPreguntas.util.ts
 * @descripcion Reordena arreglos de forma determinística usando una semilla numérica reproducible.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */

/**
 * Reordena un arreglo con algoritmo Fisher-Yates controlado por semilla.
 * @param elementos - Elementos a aleatorizar.
 * @param semilla - Número base para generar aleatoriedad reproducible.
 * @returns Nuevo arreglo con orden aleatorio determinístico.
 */
export function aleatorizarConSemilla<T>(elementos: T[], semilla: number): T[] {
  const copia = [...elementos];
  let estado = semilla;

  const numeroPseudoaleatorio = (): number => {
    estado = (estado * 9301 + 49297) % 233280;
    return estado / 233280;
  };

  for (let indice = copia.length - 1; indice > 0; indice -= 1) {
    const indiceAleatorio = Math.floor(numeroPseudoaleatorio() * (indice + 1));
    [copia[indice], copia[indiceAleatorio]] = [copia[indiceAleatorio], copia[indice]];
  }

  return copia;
}
