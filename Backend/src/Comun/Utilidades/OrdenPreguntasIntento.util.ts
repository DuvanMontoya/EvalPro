/**
 * @archivo   OrdenPreguntasIntento.util.ts
 * @descripcion Reconstruye el orden canonico de preguntas y opciones a partir del snapshot persistido del intento.
 * @modulo    Comun/Utilidades
 * @autor     EvalPro
 * @fecha     2026-03-15
 */

interface OpcionOrdenable {
  id: string;
}

interface PreguntaOrdenable<T extends OpcionOrdenable> {
  id: string;
  opciones: T[];
}

interface OpcionAplicada {
  id?: unknown;
}

interface PreguntaAplicada {
  idPregunta?: unknown;
  opciones?: unknown;
}

interface OrdenPreguntasAplicado {
  preguntas?: unknown;
}

function extraerOrdenAplicado(ordenPreguntasAplicado: unknown): Array<{ idPregunta: string; idsOpciones: string[] }> {
  if (!ordenPreguntasAplicado || typeof ordenPreguntasAplicado !== 'object') {
    return [];
  }

  const registro = ordenPreguntasAplicado as OrdenPreguntasAplicado;
  if (!Array.isArray(registro.preguntas)) {
    return [];
  }

  return (registro.preguntas as PreguntaAplicada[])
    .map((pregunta) => {
      const idPregunta = typeof pregunta.idPregunta === 'string' ? pregunta.idPregunta.trim() : '';
      const idsOpciones = Array.isArray(pregunta.opciones)
        ? (pregunta.opciones as OpcionAplicada[])
            .map((opcion) => (typeof opcion.id === 'string' ? opcion.id.trim() : ''))
            .filter((id) => id.length > 0)
        : [];

      return { idPregunta, idsOpciones };
    })
    .filter((pregunta) => pregunta.idPregunta.length > 0);
}

function ordenarOpcionesSegunSnapshot<T extends OpcionOrdenable>(opciones: T[], idsOpciones: string[]): T[] {
  if (idsOpciones.length === 0) {
    return [...opciones];
  }

  const opcionesPorId = new Map(opciones.map((opcion) => [opcion.id, opcion] as const));
  const opcionesOrdenadas: T[] = [];

  for (const idOpcion of idsOpciones) {
    const opcion = opcionesPorId.get(idOpcion);
    if (opcion) {
      opcionesOrdenadas.push(opcion);
      opcionesPorId.delete(idOpcion);
    }
  }

  return [...opcionesOrdenadas, ...opcionesPorId.values()];
}

/**
 * Reordena preguntas y opciones usando el orden persistido al iniciar el intento.
 * @param preguntas - Preguntas actualmente asociadas al examen.
 * @param ordenPreguntasAplicado - Snapshot guardado en el intento.
 */
export function ordenarPreguntasSegunIntento<T extends PreguntaOrdenable<U>, U extends OpcionOrdenable>(
  preguntas: T[],
  ordenPreguntasAplicado: unknown,
): T[] {
  const snapshot = extraerOrdenAplicado(ordenPreguntasAplicado);
  if (snapshot.length === 0) {
    return [...preguntas];
  }

  const preguntasPorId = new Map(preguntas.map((pregunta) => [pregunta.id, pregunta] as const));
  const preguntasOrdenadas: T[] = [];

  for (const preguntaSnapshot of snapshot) {
    const pregunta = preguntasPorId.get(preguntaSnapshot.idPregunta);
    if (!pregunta) {
      continue;
    }

    preguntasOrdenadas.push({
      ...pregunta,
      opciones: ordenarOpcionesSegunSnapshot(pregunta.opciones, preguntaSnapshot.idsOpciones),
    });
    preguntasPorId.delete(preguntaSnapshot.idPregunta);
  }

  return [...preguntasOrdenadas, ...preguntasPorId.values()];
}
