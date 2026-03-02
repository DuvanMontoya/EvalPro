/**
 * @archivo   Insignia.tsx
 * @descripcion Renderiza chips de estado con variantes cromáticas reutilizables.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/Lib/utils';

const variantes = cva(
  'inline-flex items-center gap-1 rounded-full border px-2.5 py-1 text-[0.7rem] font-semibold uppercase tracking-[0.04em]',
  {
  variants: {
    variante: {
      neutro:
        'border-[var(--estado-neutro-borde)] bg-[var(--estado-neutro-sutil)] text-[var(--texto-secundario)]',
      exito:
        'border-[var(--estado-exito-borde)] bg-[var(--estado-exito-sutil)] text-[var(--estado-exito)]',
      alerta:
        'border-[var(--estado-advertencia-borde)] bg-[var(--estado-advertencia-sutil)] text-[var(--estado-advertencia)]',
      peligro:
        'border-[var(--estado-peligro-borde)] bg-[var(--estado-peligro-sutil)] text-[var(--estado-peligro)]',
      primario:
        'border-[var(--acento-primario-borde)] bg-[var(--acento-primario-sutil)] text-[var(--acento-primario-hover)]',
    },
  },
  defaultVariants: {
    variante: 'neutro',
  },
});

interface PropiedadesInsignia extends React.HTMLAttributes<HTMLDivElement>, VariantProps<typeof variantes> {}

/**
 * Muestra una insignia breve de estado.
 * @param props - Variantes y contenido visual.
 * @returns Componente insignia.
 */
export function Insignia({ className, variante, ...props }: PropiedadesInsignia) {
  return <div className={cn(variantes({ variante }), className)} {...props} />;
}
