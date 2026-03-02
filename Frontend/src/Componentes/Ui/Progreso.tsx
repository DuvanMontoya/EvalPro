/**
 * @archivo   Progreso.tsx
 * @descripcion Presenta barras de progreso sobre Radix para seguimiento visual de avance.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import * as Progress from '@radix-ui/react-progress';
import { cn } from '@/Lib/utils';

interface PropiedadesProgreso extends React.ComponentPropsWithoutRef<typeof Progress.Root> {
  valor?: number;
}

/**
 * Renderiza una barra de progreso horizontal.
 * @param valor - Porcentaje de progreso entre 0 y 100.
 */
export const Progreso = React.forwardRef<
  React.ElementRef<typeof Progress.Root>,
  PropiedadesProgreso
>(({ className, valor = 0, ...props }, ref) => (
  <Progress.Root
    ref={ref}
    className={cn('relative h-2 w-full overflow-hidden rounded-full bg-fondo-elevado-4', className)}
    {...props}
  >
    <Progress.Indicator
      className="h-full w-full flex-1 transicion-normal"
      style={{
        transform: `translateX(-${100 - Math.min(100, Math.max(0, valor))}%)`,
        background: 'var(--gradiente-primario)',
      }}
    />
  </Progress.Root>
));
Progreso.displayName = 'Progreso';
