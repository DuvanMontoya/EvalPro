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
  'inline-flex items-center justify-center rounded-md text-sm font-semibold transicion-rapida focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--acento-primario)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--fondo-raiz)] disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50',
  {
    variants: {
      variante: {
        primario:
          'border border-transparent bg-[var(--acento-primario)] text-[var(--texto-invertido)] shadow-sombra-azul hover:bg-[var(--acento-primario-hover)] active:brightness-95',
        secundario:
          'border border-[var(--borde-default)] bg-fondo-elevado-3 text-[var(--texto-primario)] hover:border-[var(--borde-interactivo)] hover:bg-fondo-elevado-4',
        peligro:
          'border border-[var(--estado-peligro-borde)] bg-[var(--estado-peligro-sutil)] text-[var(--estado-peligro)] hover:bg-[var(--estado-peligro)] hover:text-[var(--texto-invertido)]',
        contorno:
          'border border-[var(--borde-default)] bg-transparent text-[var(--texto-primario)] hover:border-[var(--borde-interactivo)] hover:bg-fondo-elevado-3',
        fantasma:
          'border border-transparent bg-transparent text-[var(--texto-secundario)] hover:bg-fondo-elevado-3 hover:text-[var(--texto-primario)]',
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
