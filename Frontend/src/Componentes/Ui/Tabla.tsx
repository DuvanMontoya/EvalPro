/**
 * @archivo   Tabla.tsx
 * @descripcion Agrupa componentes semánticos para tablas reutilizables del panel.
 * @modulo    ComponentesUi
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import * as React from 'react';
import { cn } from '@/Lib/utils';

export function Tabla({ className, ...props }: React.TableHTMLAttributes<HTMLTableElement>) {
  return (
    <div className="w-full overflow-auto rounded-xl border border-[var(--borde-sutil)] bg-fondo-elevado-2">
      <table className={cn('w-full caption-bottom text-sm', className)} {...props} />
    </div>
  );
}

export function TablaEncabezado({ className, ...props }: React.HTMLAttributes<HTMLTableSectionElement>) {
  return <thead className={cn('[&_tr]:border-b', className)} {...props} />;
}

export function TablaCuerpo({ className, ...props }: React.HTMLAttributes<HTMLTableSectionElement>) {
  return <tbody className={cn('[&_tr:last-child]:border-0', className)} {...props} />;
}

export function TablaFila({ className, ...props }: React.HTMLAttributes<HTMLTableRowElement>) {
  return (
    <tr
      className={cn(
        'border-b border-[var(--borde-sutil)] transicion-rapida hover:bg-fondo-elevado-3',
        className,
      )}
      {...props}
    />
  );
}

export function TablaCabeza({ className, ...props }: React.ThHTMLAttributes<HTMLTableCellElement>) {
  return (
    <th
      className={cn(
        'h-11 px-4 text-left align-middle text-[0.72rem] font-semibold uppercase tracking-[0.06em] text-[var(--texto-terciario)]',
        className,
      )}
      {...props}
    />
  );
}

export function TablaCelda({ className, ...props }: React.TdHTMLAttributes<HTMLTableCellElement>) {
  return <td className={cn('p-4 align-middle text-[0.875rem] text-[var(--texto-secundario)]', className)} {...props} />;
}
