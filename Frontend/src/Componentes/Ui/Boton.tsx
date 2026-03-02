/**
 * @archivo   Boton.tsx
 * @descripcion Implementa botón reutilizable con variantes visuales para acciones del panel.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import { Slot } from '@radix-ui/react-slot';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/Lib/utils';

const variantesBoton = cva(
  'inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variante: {
        primario: 'bg-primario text-primario-frente hover:opacity-90',
        secundario: 'bg-secundario text-secundario-frente hover:opacity-90',
        peligro: 'bg-peligro text-peligro-frente hover:opacity-90',
        contorno: 'border border-borde bg-white hover:bg-slate-50',
        fantasma: 'hover:bg-slate-100',
      },
      tamano: {
        normal: 'h-10 px-4 py-2',
        pequeno: 'h-8 px-3 text-xs',
        grande: 'h-11 px-8',
      },
    },
    defaultVariants: {
      variante: 'primario',
      tamano: 'normal',
    },
  },
);

export interface PropiedadesBoton
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof variantesBoton> {
  comoHijo?: boolean;
}

/**
 * Renderiza un botón basado en variantes de estilo.
 * @param props - Propiedades visuales y de interacción.
 * @returns Elemento de botón reutilizable.
 */
export const Boton = React.forwardRef<HTMLButtonElement, PropiedadesBoton>(
  ({ className, variante, tamano, comoHijo = false, ...props }, ref) => {
    const Componente = comoHijo ? Slot : 'button';
    return (
      <Componente
        className={cn(variantesBoton({ variante, tamano, className }))}
        ref={ref}
        {...props}
      />
    );
  },
);
Boton.displayName = 'Boton';
