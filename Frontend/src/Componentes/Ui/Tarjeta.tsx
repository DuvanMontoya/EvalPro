/**
 * @archivo   Tarjeta.tsx
 * @descripcion Define bloques de tarjeta reutilizables para agrupar contenido visual del panel.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import * as React from 'react';
import { cn } from '@/Lib/utils';

/**
 * Contenedor principal de tarjeta.
 */
export function Tarjeta({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        'superficie-elevada rounded-xl border border-[var(--borde-sutil)] bg-fondo-elevado-2 transicion-normal',
        className,
      )}
      {...props}
    />
  );
}

/**
 * Cabecera visual de tarjeta.
 */
export function TarjetaEncabezado({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn('flex flex-col gap-1.5 p-6', className)} {...props} />;
}

/**
 * Título principal de tarjeta.
 */
export function TarjetaTitulo({ className, ...props }: React.HTMLAttributes<HTMLHeadingElement>) {
  return <h3 className={cn('font-display text-xl font-bold text-[var(--texto-primario)]', className)} {...props} />;
}

/**
 * Descripción secundaria de tarjeta.
 */
export function TarjetaDescripcion({ className, ...props }: React.HTMLAttributes<HTMLParagraphElement>) {
  return <p className={cn('text-sm text-[var(--texto-secundario)]', className)} {...props} />;
}

/**
 * Cuerpo de contenido de tarjeta.
 */
export function TarjetaContenido({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn('p-6 pt-0', className)} {...props} />;
}

/**
 * Pie de tarjeta para acciones.
 */
export function TarjetaPie({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn('flex items-center p-6 pt-0', className)} {...props} />;
}
