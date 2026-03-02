/**
 * @archivo   page.tsx
 * @descripcion Lista exámenes del docente y habilita acciones rápidas de publicación y archivado.
 * @modulo    Examenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import Link from 'next/link';
import { toast } from 'sonner';
import { useExamenes } from '@/Hooks/useExamenes';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Boton } from '@/Componentes/Ui/Boton';
import { TablaExamenes } from '@/Componentes/Examenes/TablaExamenes';

/**
 * Renderiza catálogo de exámenes.
 */
export default function PaginaExamenes() {
  const { consultaExamenes, mutacionArchivarExamen, mutacionPublicarExamen } = useExamenes();

  if (consultaExamenes.isLoading) {
    return <Cargando mensaje="Cargando exámenes..." />;
  }

  const examenes = consultaExamenes.data ?? [];

  if (examenes.length === 0) {
    return (
      <EstadoVacio
        titulo="No hay exámenes registrados"
        descripcion="Crea tu primer examen para iniciar sesiones con estudiantes."
        etiquetaAccion="Crear examen"
        hrefAccion={RUTAS.EXAMEN_NUEVO}
      />
    );
  }

  return (
    <section className="space-y-4">
      <div className="flex justify-end">
        <Boton comoHijo>
          <Link href={RUTAS.EXAMEN_NUEVO}>Nuevo examen</Link>
        </Boton>
      </div>
      <TablaExamenes
        examenes={examenes}
        onPublicar={async (idExamen) => {
          await mutacionPublicarExamen.mutateAsync(idExamen);
          toast.success('Examen publicado correctamente.');
        }}
        onArchivar={async (idExamen) => {
          await mutacionArchivarExamen.mutateAsync(idExamen);
          toast.success('Examen archivado correctamente.');
        }}
      />
    </section>
  );
}
