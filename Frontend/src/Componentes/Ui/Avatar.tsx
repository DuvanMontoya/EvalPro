/**
 * @archivo   Avatar.tsx
 * @descripcion Encapsula avatar de Radix para mostrar iniciales en listas y encabezados.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import * as React from 'react';
import * as AvatarPrimitivo from '@radix-ui/react-avatar';
import { cn } from '@/Lib/utils';

export const Avatar = React.forwardRef<
  React.ElementRef<typeof AvatarPrimitivo.Root>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitivo.Root>
>(({ className, ...props }, ref) => (
  <AvatarPrimitivo.Root
    ref={ref}
    className={cn('relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full', className)}
    {...props}
  />
));
Avatar.displayName = 'Avatar';

export const AvatarFallback = React.forwardRef<
  React.ElementRef<typeof AvatarPrimitivo.Fallback>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitivo.Fallback>
>(({ className, ...props }, ref) => (
  <AvatarPrimitivo.Fallback
    ref={ref}
    className={cn(
      'flex h-full w-full items-center justify-center bg-[linear-gradient(135deg,var(--acento-primario)_0%,var(--acento-primario-hover)_100%)] text-sm font-semibold text-[var(--texto-invertido)]',
      className,
    )}
    {...props}
  />
));
AvatarFallback.displayName = 'AvatarFallback';
