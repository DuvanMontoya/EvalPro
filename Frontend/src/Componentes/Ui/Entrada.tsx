/**
 * @archivo   Entrada.tsx
 * @descripcion Provee un input estilizado para formularios del panel administrativo.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import { cn } from '@/Lib/utils';

export interface PropiedadesEntrada extends React.InputHTMLAttributes<HTMLInputElement> {}

/**
 * Renderiza un campo de entrada con estilos consistentes.
 * @param props - Propiedades nativas de input.
 * @returns Input reutilizable del sistema.
 */
export const Entrada = React.forwardRef<HTMLInputElement, PropiedadesEntrada>(
  ({ className, type = 'text', ...props }, ref) => (
    <input
      type={type}
      className={cn(
        'flex h-10 w-full rounded-md border border-borde bg-white px-3 py-2 text-sm placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-primario disabled:cursor-not-allowed disabled:opacity-50',
        className,
      )}
      ref={ref}
      {...props}
    />
  ),
);
Entrada.displayName = 'Entrada';
