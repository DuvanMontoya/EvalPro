/**
 * @archivo   Cargando.tsx
 * @descripcion Muestra un estado de carga uniforme para listas y vistas de detalle.
 * @modulo    ComponentesComunes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Loader2 } from 'lucide-react';

interface PropiedadesCargando {
  mensaje?: string;
}

/**
 * Renderiza un indicador de carga centrado.
 * @param mensaje - Texto opcional mostrado bajo el ícono.
 * @returns Estado visual de espera.
 */
export function Cargando({ mensaje = 'Cargando información...' }: PropiedadesCargando) {
  return (
    <div className="flex min-h-40 flex-col items-center justify-center gap-3 rounded-lg border border-dashed border-[var(--borde-default)] bg-fondo-elevado-2 p-8">
      <Loader2 className="h-7 w-7 animate-spin text-[var(--acento-primario)]" strokeWidth={1.5} />
      <p className="texto-muted">{mensaje}</p>
    </div>
  );
}
