/**
 * @archivo   Etiqueta.tsx
 * @descripcion Expone etiqueta accesible basada en Radix para formularios consistentes.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import * as LabelPrimitivo from '@radix-ui/react-label';
import { cn } from '@/Lib/utils';

/**
 * Renderiza una etiqueta vinculable a controles de formulario.
 */
export const Etiqueta = React.forwardRef<
  React.ElementRef<typeof LabelPrimitivo.Root>,
  React.ComponentPropsWithoutRef<typeof LabelPrimitivo.Root>
>(({ className, ...props }, ref) => (
  <LabelPrimitivo.Root
    ref={ref}
    className={cn('text-sm font-medium leading-none', className)}
    {...props}
  />
));
Etiqueta.displayName = 'Etiqueta';
