/**
 * @archivo   ProgresoPreguntas.util.ts
 * @descripcion Utilidades para mapear preguntas respondidas a índices visibles de monitoreo.
 * @modulo    Comun/Utilidades
 * @autor     EvalPro
 * @fecha     2026-03-05
 */

interface PreguntaOrdenada {
  idPregunta?: unknown;
}

function extraerPreguntasOrdenadas(ordenPreguntasAplicado: unknown): string[] {
  if (!ordenPreguntasAplicado || typeof ordenPreguntasAplicado !== 'object') {
    return [];
  }

  const registro = ordenPreguntasAplicado as { preguntas?: unknown };
  if (!Array.isArray(registro.preguntas)) {
    return [];
  }

  return (registro.preguntas as PreguntaOrdenada[])
    .map((pregunta) => (typeof pregunta.idPregunta === 'string' ? pregunta.idPregunta.trim() : ''))
    .filter((idPregunta) => idPregunta.length > 0);
}

/**
 * Construye índices 1-based de preguntas respondidas según el orden aplicado del intento.
 * @param ordenPreguntasAplicado - JSON persistido con orden de preguntas del intento.
 * @param idsPreguntasRespondidas - IDs de pregunta que tienen respuesta guardada.
 * @param idsFallback - Orden alternativo cuando el intento no tenga orden persistido.
 */
export function calcularIndicesPreguntasRespondidas(
  ordenPreguntasAplicado: unknown,
  idsPreguntasRespondidas: readonly string[],
  idsFallback: readonly string[] = [],
): number[] {
  if (idsPreguntasRespondidas.length === 0) {
    return [];
  }

  const ordenPersistido = extraerPreguntasOrdenadas(ordenPreguntasAplicado);
  const ordenVisible = ordenPersistido.length > 0 ? ordenPersistido : idsFallback.map((id) => id.trim()).filter((id) => id.length > 0);

  if (ordenVisible.length === 0) {
    return [];
  }

  const respondidas = new Set(idsPreguntasRespondidas.map((id) => id.trim()).filter((id) => id.length > 0));
  const indices: number[] = [];

  for (let indice = 0; indice < ordenVisible.length; indice += 1) {
    if (respondidas.has(ordenVisible[indice]!)) {
      indices.push(indice + 1);
    }
  }

  return indices;
}
