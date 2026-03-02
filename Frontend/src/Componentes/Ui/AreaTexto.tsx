/**
 * @archivo   AreaTexto.tsx
 * @descripcion Encapsula un textarea con estilos base para formularios del sistema.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import { cn } from '@/Lib/utils';

export interface PropiedadesAreaTexto
  extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {}

/**
 * Renderiza un área de texto reutilizable.
 * @param props - Propiedades de textarea.
 * @returns Componente de texto multilínea.
 */
export const AreaTexto = React.forwardRef<HTMLTextAreaElement, PropiedadesAreaTexto>(
  ({ className, ...props }, ref) => (
    <textarea
      className={cn(
        'min-h-24 w-full rounded-md border border-[var(--borde-default)] bg-fondo-elevado-2 px-3 py-2 text-sm text-[var(--texto-primario)] placeholder:text-[var(--texto-terciario)] outline-none transicion-rapida focus-visible:border-[var(--acento-primario)] focus-visible:bg-fondo-elevado-3 focus-visible:shadow-sombra-glow-primario disabled:cursor-not-allowed disabled:bg-fondo-elevado-1 disabled:opacity-50',
        className,
      )}
      ref={ref}
      {...props}
    />
  ),
);
AreaTexto.displayName = 'AreaTexto';
