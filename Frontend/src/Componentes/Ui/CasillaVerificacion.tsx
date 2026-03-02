/**
 * @archivo   CasillaVerificacion.tsx
 * @descripcion Ofrece checkbox basado en Radix para selección booleana en formularios.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import * as Checkbox from '@radix-ui/react-checkbox';
import { Check } from 'lucide-react';
import { cn } from '@/Lib/utils';

export const CasillaVerificacion = React.forwardRef<
  React.ElementRef<typeof Checkbox.Root>,
  React.ComponentPropsWithoutRef<typeof Checkbox.Root>
>(({ className, ...props }, ref) => (
  <Checkbox.Root
    ref={ref}
    className={cn(
      'peer h-4 w-4 shrink-0 rounded-sm border border-borde ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primario data-[state=checked]:bg-primario data-[state=checked]:text-white',
      className,
    )}
    {...props}
  >
    <Checkbox.Indicator className="flex items-center justify-center text-current">
      <Check className="h-3.5 w-3.5" />
    </Checkbox.Indicator>
  </Checkbox.Root>
));
CasillaVerificacion.displayName = 'CasillaVerificacion';
