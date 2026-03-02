/**
 * @archivo   EncabezadoPagina.tsx
 * @descripcion Presenta un encabezado reusable con título, descripción y acciones de contexto.
 * @modulo    ComponentesComunes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import type { ReactNode } from 'react';

interface PropiedadesEncabezadoPagina {
  titulo: string;
  descripcion: string;
  etiqueta?: string;
  acciones?: ReactNode;
}

/**
 * Renderiza encabezado visual premium para páginas administrativas.
 */
export function EncabezadoPagina({
  titulo,
  descripcion,
  etiqueta,
  acciones,
}: PropiedadesEncabezadoPagina) {
  return (
    <header className="relative overflow-hidden rounded-2xl border border-[var(--borde-default)] bg-[linear-gradient(120deg,rgba(37,99,235,0.12),rgba(8,12,16,0.86)_45%,rgba(16,185,129,0.08))] p-6 shadow-sombra-md">
      <div className="absolute -right-16 -top-16 h-44 w-44 rounded-full bg-[radial-gradient(circle,rgba(59,130,246,0.22),transparent_65%)]" />
      <div className="absolute -bottom-20 left-8 h-40 w-40 rounded-full bg-[radial-gradient(circle,rgba(16,185,129,0.14),transparent_70%)]" />
      <div className="relative flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
        <div className="space-y-2">
          {etiqueta ? (
            <span className="inline-flex w-fit items-center rounded-full border border-[var(--acento-primario-borde)] bg-[var(--acento-primario-sutil)] px-2.5 py-1 text-[0.7rem] font-semibold uppercase tracking-[0.08em] text-[var(--acento-primario-hover)]">
              {etiqueta}
            </span>
          ) : null}
          <h1 className="text-2xl font-extrabold leading-tight text-[var(--texto-primario)] md:text-3xl">
            {titulo}
          </h1>
          <p className="max-w-2xl text-sm text-[var(--texto-secundario)] md:text-base">{descripcion}</p>
        </div>
        {acciones ? <div className="flex flex-wrap items-center gap-2">{acciones}</div> : null}
      </div>
    </header>
  );
}

