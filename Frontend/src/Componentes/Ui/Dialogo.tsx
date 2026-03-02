/**
 * @archivo   Dialogo.tsx
 * @descripcion Exporta primitivas de diálogo basadas en Radix para modales accesibles.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import * as Dialog from '@radix-ui/react-dialog';
import { X } from 'lucide-react';
import { cn } from '@/Lib/utils';

export const Dialogo = Dialog.Root;
export const DialogoDisparador = Dialog.Trigger;
export const DialogoPortal = Dialog.Portal;
export const DialogoCerrar = Dialog.Close;

export const DialogoSuperposicion = React.forwardRef<
  React.ElementRef<typeof Dialog.Overlay>,
  React.ComponentPropsWithoutRef<typeof Dialog.Overlay>
>(({ className, ...props }, ref) => (
  <Dialog.Overlay
    ref={ref}
    className={cn('fixed inset-0 z-50 bg-black/40 backdrop-blur-sm', className)}
    {...props}
  />
));
DialogoSuperposicion.displayName = 'DialogoSuperposicion';

export const DialogoContenido = React.forwardRef<
  React.ElementRef<typeof Dialog.Content>,
  React.ComponentPropsWithoutRef<typeof Dialog.Content>
>(({ className, children, ...props }, ref) => (
  <DialogoPortal>
    <DialogoSuperposicion />
    <Dialog.Content
      ref={ref}
      className={cn(
        'fixed left-1/2 top-1/2 z-50 w-[95vw] max-w-xl -translate-x-1/2 -translate-y-1/2 rounded-lg border border-borde bg-white p-6 shadow-lg',
        className,
      )}
      {...props}
    >
      {children}
      <Dialog.Close className="absolute right-4 top-4 rounded-sm opacity-70 hover:opacity-100">
        <X className="h-4 w-4" />
      </Dialog.Close>
    </Dialog.Content>
  </DialogoPortal>
));
DialogoContenido.displayName = 'DialogoContenido';

export function DialogoEncabezado({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn('mb-4 flex flex-col gap-1 text-left', className)} {...props} />;
}

export function DialogoTitulo({ className, ...props }: React.ComponentPropsWithoutRef<typeof Dialog.Title>) {
  return <Dialog.Title className={cn('text-lg font-semibold', className)} {...props} />;
}

export function DialogoDescripcion({
  className,
  ...props
}: React.ComponentPropsWithoutRef<typeof Dialog.Description>) {
  return <Dialog.Description className={cn('text-sm text-slate-600', className)} {...props} />;
}
