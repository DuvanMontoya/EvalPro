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
        'min-h-24 w-full rounded-md border border-borde bg-white px-3 py-2 text-sm placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-primario disabled:cursor-not-allowed disabled:opacity-50',
        className,
      )}
      ref={ref}
      {...props}
    />
  ),
);
AreaTexto.displayName = 'AreaTexto';
