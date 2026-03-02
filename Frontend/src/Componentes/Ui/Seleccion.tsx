/**
 * @archivo   Seleccion.tsx
 * @descripcion Encapsula Select de Radix con estilos homogéneos para formularios del panel.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import * as Select from '@radix-ui/react-select';
import { Check, ChevronDown } from 'lucide-react';
import { cn } from '@/Lib/utils';

export const Seleccion = Select.Root;
export const SeleccionValor = Select.Value;

export const SeleccionDisparador = React.forwardRef<
  React.ElementRef<typeof Select.Trigger>,
  React.ComponentPropsWithoutRef<typeof Select.Trigger>
>(({ className, children, ...props }, ref) => (
  <Select.Trigger
    ref={ref}
    className={cn(
      'flex h-10 w-full items-center justify-between rounded-md border border-borde bg-white px-3 py-2 text-sm',
      className,
    )}
    {...props}
  >
    {children}
    <Select.Icon>
      <ChevronDown className="h-4 w-4 text-slate-500" />
    </Select.Icon>
  </Select.Trigger>
));
SeleccionDisparador.displayName = 'SeleccionDisparador';

export const SeleccionContenido = React.forwardRef<
  React.ElementRef<typeof Select.Content>,
  React.ComponentPropsWithoutRef<typeof Select.Content>
>(({ className, children, ...props }, ref) => (
  <Select.Portal>
    <Select.Content
      ref={ref}
      className={cn('z-50 overflow-hidden rounded-md border border-borde bg-white shadow-md', className)}
      {...props}
    >
      <Select.Viewport className="p-1">{children}</Select.Viewport>
    </Select.Content>
  </Select.Portal>
));
SeleccionContenido.displayName = 'SeleccionContenido';

export const SeleccionItem = React.forwardRef<
  React.ElementRef<typeof Select.Item>,
  React.ComponentPropsWithoutRef<typeof Select.Item>
>(({ className, children, ...props }, ref) => (
  <Select.Item
    ref={ref}
    className={cn('relative flex cursor-pointer items-center rounded px-2 py-1.5 text-sm outline-none hover:bg-slate-100', className)}
    {...props}
  >
    <span className="absolute left-2 inline-flex h-3.5 w-3.5 items-center justify-center">
      <Select.ItemIndicator>
        <Check className="h-4 w-4" />
      </Select.ItemIndicator>
    </span>
    <Select.ItemText className="pl-6">{children}</Select.ItemText>
  </Select.Item>
));
SeleccionItem.displayName = 'SeleccionItem';
