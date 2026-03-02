/**
 * @archivo   EstadoVacio.tsx
 * @descripcion Presenta un estado vacío reutilizable con acción opcional para navegar.
 * @modulo    ComponentesComunes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import Link from 'next/link';
import { Inbox } from 'lucide-react';
import { Boton } from '@/Componentes/Ui/Boton';

interface PropiedadesEstadoVacio {
  titulo: string;
  descripcion: string;
  etiquetaAccion?: string;
  hrefAccion?: string;
}

/**
 * Renderiza una tarjeta de ausencia de datos.
 */
export function EstadoVacio({
  titulo,
  descripcion,
  etiquetaAccion,
  hrefAccion,
}: PropiedadesEstadoVacio) {
  return (
    <div className="flex min-h-48 flex-col items-center justify-center gap-4 rounded-lg border border-dashed border-borde bg-white p-8 text-center">
      <Inbox className="h-10 w-10 text-slate-400" />
      <div className="space-y-1">
        <h3 className="text-base font-semibold">{titulo}</h3>
        <p className="texto-muted">{descripcion}</p>
      </div>
      {hrefAccion && etiquetaAccion ? (
        <Boton comoHijo>
          <Link href={hrefAccion}>{etiquetaAccion}</Link>
        </Boton>
      ) : null}
    </div>
  );
}
