/**
 * @archivo   TarjetaPregunta.tsx
 * @descripcion Representa visualmente una pregunta y sus opciones para edición rápida del docente.
 * @modulo    ComponentesExamenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { GripVertical } from 'lucide-react';
import { Pregunta } from '@/Tipos';
import { Boton } from '@/Componentes/Ui/Boton';
import { Insignia } from '@/Componentes/Ui/Insignia';

interface PropiedadesTarjetaPregunta {
  pregunta: Pregunta;
  onEliminar: (idPregunta: string) => void;
  escuchadores?: Record<string, (...args: unknown[]) => void>;
  atributos?: Record<string, unknown>;
}

/**
 * Muestra una tarjeta compacta de pregunta con acción de eliminar.
 */
export function TarjetaPregunta({
  pregunta,
  onEliminar,
  escuchadores,
  atributos,
}: PropiedadesTarjetaPregunta) {
  return (
    <div className="rounded-lg border border-borde bg-white p-4 shadow-sm">
      <div className="mb-2 flex items-start justify-between gap-3">
        <div className="flex items-center gap-2">
          <button className="cursor-grab text-slate-500" {...escuchadores} {...atributos}>
            <GripVertical className="h-4 w-4" />
          </button>
          <h4 className="font-medium">{pregunta.orden}. {pregunta.enunciado}</h4>
        </div>
        <div className="flex items-center gap-2">
          <Insignia variante="primario">{pregunta.tipo}</Insignia>
          <Boton tamano="pequeno" variante="peligro" onClick={() => onEliminar(pregunta.id)}>
            Eliminar
          </Boton>
        </div>
      </div>

      {pregunta.opciones.length > 0 ? (
        <ul className="space-y-1 text-sm text-slate-700">
          {pregunta.opciones.map((opcion) => (
            <li key={opcion.id} className="flex items-center gap-2">
              <span className="font-semibold">{opcion.letra}.</span>
              <span>{opcion.contenido}</span>
              {opcion.esCorrecta ? <Insignia variante="exito">Correcta</Insignia> : null}
            </li>
          ))}
        </ul>
      ) : (
        <p className="texto-muted">Respuesta abierta (calificación manual).</p>
      )}
    </div>
  );
}
