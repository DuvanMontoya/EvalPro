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
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { EditorPreguntas } from '@/Componentes/Examenes/EditorPreguntas';
import { InsigniaEstado } from '@/Componentes/Examenes/InsigniaEstado';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useExamenDetalle } from '@/Hooks/useExamenes';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { puedeEditarContenidoExamen } from '@/Lib/Permisos';

/**
 * Renderiza vista de detalle de examen y edición de preguntas.
 */
export default function PaginaDetalleExamen() {
  const parametros = useParams<{ idExamen: string }>();
  const idExamen = parametros.idExamen;
  const { usuario } = useAutenticacion();
  const { consultaExamen } = useExamenDetalle(idExamen);

  if (consultaExamen.isLoading) {
    return <Cargando mensaje="Cargando examen..." />;
  }

  if (consultaExamen.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar el examen"
        descripcion={obtenerMensajeError(consultaExamen.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  if (!consultaExamen.data) {
    return (
      <EstadoVacio
        titulo="Examen no disponible"
        descripcion="No fue posible encontrar el examen solicitado."
      />
    );
  }

  const examen = consultaExamen.data;
  const soloLectura = !puedeEditarContenidoExamen(usuario?.rol, examen.estado);

  return (
    <section className="space-y-6">
      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>{examen.titulo}</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido className="space-y-2">
          <InsigniaEstado estado={examen.estado} />
          <p className="texto-muted">Modalidad: {examen.modalidad}</p>
          <p className="texto-muted">
            Duración: <span className="font-mono">{examen.duracionMinutos}</span> minutos
          </p>
          {soloLectura ? (
            <p className="text-sm text-[var(--estado-advertencia)]">
              Este examen está en solo lectura para tu rol o por estado.
            </p>
          ) : null}
        </TarjetaContenido>
      </Tarjeta>
      <EditorPreguntas idExamen={idExamen} soloLectura={soloLectura} />
    </section>
  );
}
