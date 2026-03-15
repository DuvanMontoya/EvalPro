/**
 * @archivo   SanitizadorExamenEstudiante.util.ts
 * @descripcion Sanitiza el examen expuesto al estudiante segun la modalidad para evitar fugas de contenido sensible.
 * @modulo    Comun/Utilidades
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { ModalidadExamen } from '@prisma/client';

interface OpcionExpuesta {
  contenido?: string | null;
  esCorrecta?: boolean;
  [clave: string]: unknown;
}

interface PreguntaExpuesta {
  enunciado?: string | null;
  imagenUrl?: string | null;
  opciones: OpcionExpuesta[];
  [clave: string]: unknown;
}

interface ExamenExpuesto {
  id: string;
  modalidad: ModalidadExamen;
  version?: number | null;
  descripcion?: string | null;
  instrucciones?: string | null;
  preguntas: PreguntaExpuesta[];
  [clave: string]: unknown;
}

function construirIdentificadorCuadernillo(idExamen: string, version?: number | null): string {
  const prefijo = idExamen.replace(/-/g, '').slice(0, 8).toUpperCase();
  return `CUAD-${prefijo}-V${version ?? 1}`;
}

/**
 * Remueve contenido de preguntas cuando la modalidad solo permite hoja de respuestas.
 * @param examen - Examen listo para exponer al estudiante.
 */
export function sanitizarExamenParaEstudiante<T extends ExamenExpuesto>(examen: T): T & { identificadorCuadernillo: string | null } {
  const esHojaRespuestas = examen.modalidad === ModalidadExamen.HOJA_RESPUESTAS;
  if (!esHojaRespuestas) {
    return {
      ...examen,
      identificadorCuadernillo: null,
    };
  }

  return {
    ...examen,
    descripcion: '',
    instrucciones: '',
    identificadorCuadernillo: construirIdentificadorCuadernillo(examen.id, examen.version),
    preguntas: examen.preguntas.map((pregunta) => ({
      ...pregunta,
      enunciado: '',
      imagenUrl: null,
      opciones: pregunta.opciones.map(({ esCorrecta: _esCorrecta, ...opcion }) => ({
        ...opcion,
        contenido: '',
      })),
    })),
  };
}
