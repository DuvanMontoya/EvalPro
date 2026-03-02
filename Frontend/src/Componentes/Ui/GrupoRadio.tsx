/**
 * @archivo   GrupoRadio.tsx
 * @descripcion Agrupa botones de selección única con estilo unificado para formularios.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import * as RadioGroup from '@radix-ui/react-radio-group';
import { Circle } from 'lucide-react';
import { cn } from '@/Lib/utils';

export const GrupoRadio = RadioGroup.Root;

export const ItemGrupoRadio = React.forwardRef<
  React.ElementRef<typeof RadioGroup.Item>,
  React.ComponentPropsWithoutRef<typeof RadioGroup.Item>
>(({ className, ...props }, ref) => (
  <RadioGroup.Item
    ref={ref}
    className={cn(
      'aspect-square h-4 w-4 rounded-full border border-borde text-primario focus:outline-none focus:ring-2 focus:ring-primario',
      className,
    )}
    {...props}
  >
    <RadioGroup.Indicator className="flex items-center justify-center">
      <Circle className="h-2.5 w-2.5 fill-current text-current" />
    </RadioGroup.Indicator>
  </RadioGroup.Item>
));
ItemGrupoRadio.displayName = 'ItemGrupoRadio';
