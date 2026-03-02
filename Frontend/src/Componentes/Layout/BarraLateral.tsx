/**
 * @archivo   BarraLateral.tsx
 * @descripcion Renderiza navegación lateral principal del panel administrativo con accesos por módulo.
 * @modulo    ComponentesLayout
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  BarChart3,
  BookOpen,
  Cog,
  FileText,
  Home,
  Users,
} from 'lucide-react';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { cn } from '@/Lib/utils';
import { useUiAlmacen } from '@/Almacen/UiAlmacen';

const enlaces = [
  { etiqueta: 'Tablero', href: RUTAS.TABLERO, icono: Home },
  { etiqueta: 'Exámenes', href: RUTAS.EXAMENES, icono: BookOpen },
  { etiqueta: 'Sesiones', href: RUTAS.SESIONES, icono: FileText },
  { etiqueta: 'Estudiantes', href: RUTAS.ESTUDIANTES, icono: Users },
  { etiqueta: 'Reportes', href: RUTAS.REPORTES, icono: BarChart3 },
  { etiqueta: 'Configuración', href: RUTAS.CONFIGURACION, icono: Cog },
] as const;

/**
 * Dibuja barra lateral con navegación y estado abierto/cerrado.
 */
export function BarraLateral() {
  const rutaActual = usePathname();
  const abierta = useUiAlmacen((estado) => estado.barraLateralAbierta);

  return (
    <aside
      className={cn(
        'hidden h-screen border-r border-[var(--borde-sutil)] lg:block transicion-lenta',
        abierta ? 'w-[240px]' : 'w-[60px]',
      )}
      style={{ background: 'var(--gradiente-barra-lateral)' }}
    >
      <div className="flex h-16 items-center justify-between border-b border-[var(--borde-sutil)] px-4">
        <div className="flex items-center gap-2">
          <span className="h-1.5 w-1.5 rounded-full bg-[var(--acento-primario)]" />
          <span className="titulo-app text-lg font-extrabold text-[var(--texto-primario)]">
            {abierta ? 'EvalPro' : 'EP'}
          </span>
        </div>
        {abierta ? <span className="font-mono text-[10px] text-[var(--texto-terciario)]">v1.0</span> : null}
      </div>
      <nav className="space-y-1 p-3">
        {enlaces.map((enlace) => {
          const activo = rutaActual.startsWith(enlace.href);
          const Icono = enlace.icono;

          return (
            <Link
              href={enlace.href}
              key={enlace.href}
              aria-label={enlace.etiqueta}
              className={cn(
                'group flex items-center gap-3 rounded-sm border px-3 py-2 text-sm font-medium transicion-rapida focus-visible:outline-none focus-visible:shadow-sombra-glow-primario',
                activo
                  ? 'border-[var(--acento-primario-borde)] bg-[var(--acento-primario-sutil)] text-[var(--acento-primario-hover)] shadow-sombra-xs'
                  : 'border-transparent text-[var(--texto-secundario)] hover:border-[var(--borde-default)] hover:bg-fondo-elevado-3 hover:text-[var(--texto-primario)]',
              )}
            >
              <Icono className="h-4 w-4 shrink-0" strokeWidth={1.5} />
              {abierta ? enlace.etiqueta : null}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
