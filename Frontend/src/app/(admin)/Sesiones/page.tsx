/**
 * @archivo   page.tsx
 * @descripcion Lista sesiones de examen y permite gestionar su ciclo de vida desde el panel.
 * @modulo    Sesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import Link from 'next/link';
import { toast } from 'sonner';
import { useSesiones } from '@/Hooks/useSesiones';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Boton } from '@/Componentes/Ui/Boton';
import { TablaSesiones } from '@/Componentes/Sesiones/TablaSesiones';

/**
 * Renderiza catálogo de sesiones del docente.
 */
export default function PaginaSesiones() {
  const { consultaSesiones, mutacionActivarSesion, mutacionFinalizarSesion } = useSesiones();

  if (consultaSesiones.isLoading) {
    return <Cargando mensaje="Cargando sesiones..." />;
  }

  const sesiones = consultaSesiones.data ?? [];
  if (sesiones.length === 0) {
    return (
      <EstadoVacio
        titulo="No hay sesiones"
        descripcion="Crea una sesión para iniciar exámenes con tus estudiantes."
        etiquetaAccion="Nueva sesión"
        hrefAccion={RUTAS.SESION_NUEVA}
      />
    );
  }

  return (
    <section className="space-y-4">
      <div className="flex justify-end">
        <Boton comoHijo>
          <Link href={RUTAS.SESION_NUEVA}>Nueva sesión</Link>
        </Boton>
      </div>
      <TablaSesiones
        sesiones={sesiones}
        onActivar={async (idSesion) => {
          await mutacionActivarSesion.mutateAsync(idSesion);
          toast.success('Sesión activada correctamente.');
        }}
        onFinalizar={async (idSesion) => {
          await mutacionFinalizarSesion.mutateAsync(idSesion);
          toast.success('Sesión finalizada correctamente.');
        }}
      />
    </section>
  );
}
