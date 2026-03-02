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
        'hidden h-screen border-r border-borde bg-white lg:block',
        abierta ? 'w-64' : 'w-20',
      )}
    >
      <div className="flex h-16 items-center border-b border-borde px-4">
        <span className="text-lg font-bold text-primario">{abierta ? 'EvalPro' : 'EP'}</span>
      </div>
      <nav className="space-y-1 p-3">
        {enlaces.map((enlace) => {
          const activo = rutaActual.startsWith(enlace.href);
          const Icono = enlace.icono;

          return (
            <Link
              href={enlace.href}
              key={enlace.href}
              className={cn(
                'flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors',
                activo ? 'bg-primario text-primario-frente' : 'text-slate-700 hover:bg-slate-100',
              )}
            >
              <Icono className="h-4 w-4" />
              {abierta ? enlace.etiqueta : null}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
