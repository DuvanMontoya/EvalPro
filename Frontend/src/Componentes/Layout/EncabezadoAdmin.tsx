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

  return segmentos[0]!.replaceAll('-', ' ');
}

/**
 * Renderiza barra superior para vistas administrativas.
 */
export function EncabezadoAdmin() {
  const ruta = usePathname();
  const alternarBarraLateral = useUiAlmacen((estado) => estado.alternarBarraLateral);

  return (
    <header className="sticky top-0 z-20 flex h-16 items-center justify-between border-b border-borde bg-white/95 px-4 backdrop-blur">
      <div className="flex items-center gap-3">
        <Boton variante="fantasma" tamano="pequeno" onClick={alternarBarraLateral}>
          <Menu className="h-4 w-4" />
        </Boton>
        <h1 className="text-lg font-semibold capitalize">{obtenerTituloDesdeRuta(ruta)}</h1>
      </div>
      <MenuUsuario />
    </header>
  );
}
