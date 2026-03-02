/**
 * @archivo   EncabezadoAdmin.tsx
 * @descripcion Muestra encabezado superior del panel con título contextual y menú de usuario.
 * @modulo    ComponentesLayout
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { Menu } from 'lucide-react';
import { usePathname } from 'next/navigation';
import { Boton } from '@/Componentes/Ui/Boton';
import { useUiAlmacen } from '@/Almacen/UiAlmacen';
import { MenuUsuario } from '@/Componentes/Layout/MenuUsuario';

function obtenerTituloDesdeRuta(ruta: string): string {
  const segmentos = ruta.split('/').filter(Boolean);
  if (segmentos.length === 0) {
    return 'Tablero';
  }

  const seccion = segmentos[0] ?? '';
  const mapaTitulos: Record<string, string> = {
    Tablero: 'Tablero Ejecutivo',
    Instituciones: 'Gobierno Institucional',
    Grupos: 'Gestión de Grupos',
    Examenes: 'Gestión de Exámenes',
    Sesiones: 'Control de Sesiones',
    Estudiantes: 'Usuarios Académicos',
    Reportes: 'Reportes y Analítica',
    Configuracion: 'Configuración',
  };

  return mapaTitulos[seccion] ?? seccion.replaceAll('-', ' ');
}

/**
 * Renderiza barra superior para vistas administrativas.
 */
export function EncabezadoAdmin() {
  const ruta = usePathname();
  const alternarBarraLateral = useUiAlmacen((estado) => estado.alternarBarraLateral);
  const fechaActual = new Intl.DateTimeFormat('es-CO', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(new Date());

  return (
    <header className="sticky top-0 z-20 flex h-16 items-center justify-between border-b border-[var(--borde-sutil)] bg-[var(--fondo-encabezado)] px-4 backdrop-blur-xl md:px-8">
      <div className="flex items-center gap-3">
        <Boton variante="fantasma" tamano="pequeno" onClick={alternarBarraLateral}>
          <Menu className="h-4 w-4" strokeWidth={1.5} />
        </Boton>
        <div>
          <h1 className="font-display text-base font-bold text-[var(--texto-primario)] md:text-lg">
            {obtenerTituloDesdeRuta(ruta)}
          </h1>
          <p className="text-xs text-[var(--texto-terciario)]">{fechaActual}</p>
        </div>
      </div>
      <MenuUsuario />
    </header>
  );
}
