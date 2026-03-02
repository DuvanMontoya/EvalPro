/**
 * @archivo   Insignia.tsx
 * @descripcion Renderiza chips de estado con variantes cromáticas reutilizables.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/Lib/utils';

const variantes = cva('inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold', {
  variants: {
    variante: {
      neutro: 'bg-slate-200 text-slate-800',
      exito: 'bg-exito text-exito-frente',
      alerta: 'bg-amber-100 text-amber-800',
      peligro: 'bg-peligro text-peligro-frente',
      primario: 'bg-primario text-primario-frente',
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
