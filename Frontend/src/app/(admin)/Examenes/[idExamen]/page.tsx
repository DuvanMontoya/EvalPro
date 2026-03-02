/**
 * @archivo   page.tsx
 * @descripcion Muestra detalle de examen junto con el editor completo de preguntas.
 * @modulo    Examenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useParams } from 'next/navigation';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EditorPreguntas } from '@/Componentes/Examenes/EditorPreguntas';
import { InsigniaEstado } from '@/Componentes/Examenes/InsigniaEstado';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { useExamenDetalle } from '@/Hooks/useExamenes';

/**
 * Renderiza vista de detalle de examen y edición de preguntas.
 */
export default function PaginaDetalleExamen() {
  const parametros = useParams<{ idExamen: string }>();
  const idExamen = parametros.idExamen;
  const { consultaExamen } = useExamenDetalle(idExamen);

  if (consultaExamen.isLoading || !consultaExamen.data) {
    return <Cargando mensaje="Cargando examen..." />;
  }

  const examen = consultaExamen.data;

  return (
    <section className="space-y-6">
      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>{examen.titulo}</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido className="space-y-2">
          <InsigniaEstado estado={examen.estado} />
          <p className="texto-muted">Modalidad: {examen.modalidad}</p>
          <p className="texto-muted">Duración: {examen.duracionMinutos} minutos</p>
        </TarjetaContenido>
      </Tarjeta>
      <EditorPreguntas idExamen={idExamen} />
    </section>
  );
}
