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
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useExamenes } from '@/Hooks/useExamenes';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Boton } from '@/Componentes/Ui/Boton';
import { TablaExamenes } from '@/Componentes/Examenes/TablaExamenes';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { rolPuedeGestionarExamenes } from '@/Lib/Permisos';

/**
 * Renderiza catálogo de exámenes.
 */
export default function PaginaExamenes() {
  const { consultaExamenes, mutacionArchivarExamen, mutacionPublicarExamen } = useExamenes();
  const { usuario } = useAutenticacion();
  const puedeGestionar = rolPuedeGestionarExamenes(usuario?.rol);

  if (consultaExamenes.isLoading) {
    return <Cargando mensaje="Cargando exámenes..." />;
  }

  if (consultaExamenes.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar exámenes"
        descripcion={obtenerMensajeError(consultaExamenes.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  const examenes = consultaExamenes.data ?? [];

  if (examenes.length === 0) {
    return (
      <EstadoVacio
        titulo="No hay exámenes registrados"
        descripcion="Crea tu primer examen para iniciar sesiones con estudiantes."
        etiquetaAccion={puedeGestionar ? 'Crear examen' : undefined}
        hrefAccion={puedeGestionar ? RUTAS.EXAMEN_NUEVO : undefined}
      />
    );
  }

  return (
    <section className="space-y-4">
      {puedeGestionar ? (
        <div className="flex justify-end">
          <Boton comoHijo>
            <Link href={RUTAS.EXAMEN_NUEVO}>Nuevo examen</Link>
          </Boton>
        </div>
      ) : null}
      <TablaExamenes
        examenes={examenes}
        rolUsuario={usuario?.rol}
        onPublicar={async (idExamen) => {
          try {
            await mutacionPublicarExamen.mutateAsync(idExamen);
            toast.success('Examen publicado correctamente.');
          } catch (error) {
            toast.error(obtenerMensajeError(error, 'No se pudo publicar el examen.'));
          }
        }}
        onArchivar={async (idExamen) => {
          try {
            await mutacionArchivarExamen.mutateAsync(idExamen);
            toast.success('Examen archivado correctamente.');
          } catch (error) {
            toast.error(obtenerMensajeError(error, 'No se pudo archivar el examen.'));
          }
        }}
      />
    </section>
  );
}
