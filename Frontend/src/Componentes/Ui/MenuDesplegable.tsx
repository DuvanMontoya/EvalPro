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
      className={cn(
        'z-50 min-w-44 rounded-lg border border-[var(--borde-default)] bg-fondo-elevado-2 p-1 shadow-sombra-md',
        className,
      )}
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
    className={cn(
      'cursor-pointer rounded-sm px-2 py-1.5 text-sm text-[var(--texto-secundario)] outline-none transicion-rapida hover:bg-fondo-elevado-3 hover:text-[var(--texto-primario)] focus:bg-fondo-elevado-3 focus:text-[var(--texto-primario)]',
      className,
    )}
    {...props}
  />
));
MenuDesplegableItem.displayName = 'MenuDesplegableItem';

export const MenuDesplegableEtiqueta = React.forwardRef<
  React.ElementRef<typeof DropdownMenu.Label>,
  React.ComponentPropsWithoutRef<typeof DropdownMenu.Label>
>(({ className, ...props }, ref) => (
  <DropdownMenu.Label
    ref={ref}
    className={cn('px-2 py-1 text-xs font-semibold uppercase tracking-[0.08em] text-[var(--texto-terciario)]', className)}
    {...props}
  />
));
MenuDesplegableEtiqueta.displayName = 'MenuDesplegableEtiqueta';

export const MenuDesplegableSeparador = React.forwardRef<
  React.ElementRef<typeof DropdownMenu.Separator>,
  React.ComponentPropsWithoutRef<typeof DropdownMenu.Separator>
>(({ className, ...props }, ref) => (
  <DropdownMenu.Separator
    ref={ref}
    className={cn('my-1 h-px bg-[var(--borde-sutil)]', className)}
    {...props}
  />
));
MenuDesplegableSeparador.displayName = 'MenuDesplegableSeparador';
