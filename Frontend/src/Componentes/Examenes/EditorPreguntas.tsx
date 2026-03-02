/**
 * @archivo   EditorPreguntas.tsx
 * @descripcion Gestiona CRUD de preguntas con drag-and-drop y diálogo de creación validada.
 * @modulo    ComponentesExamenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useMemo, useState } from 'react';
import { DndContext, DragEndEvent, PointerSensor, useSensor, useSensors } from '@dnd-kit/core';
import { SortableContext, arrayMove, useSortable, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { toast } from 'sonner';
import { useExamenDetalle } from '@/Hooks/useExamenes';
import { Boton } from '@/Componentes/Ui/Boton';
import {
  Dialogo,
  DialogoContenido,
  DialogoDescripcion,
  DialogoEncabezado,
  DialogoTitulo,
} from '@/Componentes/Ui/Dialogo';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { FormularioPregunta } from '@/Componentes/Examenes/FormularioPregunta';
import { TarjetaPregunta } from '@/Componentes/Examenes/TarjetaPregunta';

interface PropiedadesEditorPreguntas {
  idExamen: string;
}

function ItemOrdenable({ id, children }: { id: string; children: (props: { escuchadores: Record<string, (...args: unknown[]) => void>; atributos: Record<string, unknown>; estilo: React.CSSProperties; }) => React.ReactNode; }) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({ id });
  const estilo = { transform: CSS.Transform.toString(transform), transition };
  return (
    <div ref={setNodeRef} style={estilo}>
      {children({
        escuchadores: listeners as unknown as Record<string, (...args: unknown[]) => void>,
        atributos: attributes as unknown as Record<string, unknown>,
        estilo,
      })}
    </div>
  );
}

/**
 * Renderiza editor de preguntas con creación y reordenamiento inmediato.
 */
export function EditorPreguntas({ idExamen }: PropiedadesEditorPreguntas) {
  const [dialogoAbierto, setDialogoAbierto] = useState(false);
  const sensores = useSensors(useSensor(PointerSensor));
  const {
    consultaPreguntas,
    mutacionAgregarPregunta,
    mutacionEliminarPregunta,
    mutacionReordenarPreguntas,
  } = useExamenDetalle(idExamen);

  const preguntas = useMemo(() => consultaPreguntas.data ?? [], [consultaPreguntas.data]);

  const manejarArrastreFinalizado = async (evento: DragEndEvent) => {
    const { active, over } = evento;
    if (!over || active.id === over.id) {
      return;
    }

    const indiceAnterior = preguntas.findIndex((pregunta) => pregunta.id === active.id);
    const indiceNuevo = preguntas.findIndex((pregunta) => pregunta.id === over.id);
    const reordenadas = arrayMove(preguntas, indiceAnterior, indiceNuevo).map((pregunta, indice) => ({
      idPregunta: pregunta.id,
      orden: indice + 1,
    }));

    try {
      await mutacionReordenarPreguntas.mutateAsync(reordenadas);
    } catch {
      toast.error('No fue posible reordenar las preguntas.');
    }
  };

  if (consultaPreguntas.isLoading) {
    return <Cargando mensaje="Cargando preguntas..." />;
  }

  return (
    <section className="space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold">Preguntas del examen</h3>
        <Boton onClick={() => setDialogoAbierto(true)}>Agregar pregunta</Boton>
      </div>

      {preguntas.length === 0 ? (
        <EstadoVacio titulo="Sin preguntas" descripcion="Agrega la primera pregunta para continuar." />
      ) : (
        <DndContext sensors={sensores} onDragEnd={manejarArrastreFinalizado}>
          <SortableContext items={preguntas.map((pregunta) => pregunta.id)} strategy={verticalListSortingStrategy}>
            <div className="space-y-3">
              {preguntas.map((pregunta) => (
                <ItemOrdenable key={pregunta.id} id={pregunta.id}>
                  {({ escuchadores, atributos }) => (
                    <TarjetaPregunta
                      pregunta={pregunta}
                      onEliminar={(idPregunta) => mutacionEliminarPregunta.mutate(idPregunta)}
                      escuchadores={escuchadores}
                      atributos={atributos}
                    />
                  )}
                </ItemOrdenable>
              ))}
            </div>
          </SortableContext>
        </DndContext>
      )}

      <Dialogo open={dialogoAbierto} onOpenChange={setDialogoAbierto}>
        <DialogoContenido>
          <DialogoEncabezado>
            <DialogoTitulo>Nueva pregunta</DialogoTitulo>
            <DialogoDescripcion>Completa la información y guarda para agregarla al examen.</DialogoDescripcion>
          </DialogoEncabezado>
          <FormularioPregunta
            onGuardar={async (dto) => {
              try {
                await mutacionAgregarPregunta.mutateAsync(dto);
                toast.success('Pregunta creada correctamente.');
                setDialogoAbierto(false);
              } catch {
                toast.error('No se pudo crear la pregunta.');
              }
            }}
          />
        </DialogoContenido>
      </Dialogo>
    </section>
  );
}
