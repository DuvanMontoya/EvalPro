/**
 * @archivo   MenuDesplegable.tsx
 * @descripcion Exporta primitivas de menú desplegable para acciones contextuales en la UI.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import * as DropdownMenu from '@radix-ui/react-dropdown-menu';
import { cn } from '@/Lib/utils';

export const MenuDesplegable = DropdownMenu.Root;
export const MenuDesplegableDisparador = DropdownMenu.Trigger;
export const MenuDesplegableContenido = React.forwardRef<
  React.ElementRef<typeof DropdownMenu.Content>,
  React.ComponentPropsWithoutRef<typeof DropdownMenu.Content>
>(({ className, ...props }, ref) => (
  <DropdownMenu.Portal>
    <DropdownMenu.Content
      ref={ref}
      className={cn('z-50 min-w-44 rounded-md border border-borde bg-white p-1 shadow-md', className)}
      sideOffset={8}
      {...props}
    />
  </DropdownMenu.Portal>
));
MenuDesplegableContenido.displayName = 'MenuDesplegableContenido';

export const MenuDesplegableItem = React.forwardRef<
  React.ElementRef<typeof DropdownMenu.Item>,
  React.ComponentPropsWithoutRef<typeof DropdownMenu.Item>
>(({ className, ...props }, ref) => (
  <DropdownMenu.Item
    ref={ref}
    className={cn('cursor-pointer rounded px-2 py-1.5 text-sm outline-none hover:bg-slate-100', className)}
    {...props}
  />
));
MenuDesplegableItem.displayName = 'MenuDesplegableItem';

export const MenuDesplegableEtiqueta = DropdownMenu.Label;
export const MenuDesplegableSeparador = DropdownMenu.Separator;
