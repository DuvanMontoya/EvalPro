/**
 * @archivo   layout.tsx
 * @descripcion Aplica layout administrativo con sidebar, encabezado, control de sesión y React Query.
 * @modulo    Admin
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { BarraLateral } from '@/Componentes/Layout/BarraLateral';
import { EncabezadoAdmin } from '@/Componentes/Layout/EncabezadoAdmin';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { ErrorLimite } from '@/Componentes/Comunes/ErrorLimite';
import { ProveedorConsulta } from '@/Componentes/Comunes/ProveedorConsulta';
import { rolPuedeAccederPanel } from '@/Lib/Permisos';

interface PropiedadesLayoutAdmin {
  children: React.ReactNode;
}

/**
 * Renderiza layout principal con control de autenticación para rutas administrativas.
 */
export default function LayoutAdmin({ children }: PropiedadesLayoutAdmin) {
  const router = useRouter();
  const {
    verificarSesion,
    cerrarSesion,
    usuario,
    cargando,
    estaAutenticado,
  } = useAutenticacion();

  useEffect(() => {
    verificarSesion().catch(() => {
      router.replace(RUTAS.INICIO_SESION);
    });
  }, [router, verificarSesion]);

  useEffect(() => {
    if (cargando || !estaAutenticado || rolPuedeAccederPanel(usuario?.rol)) {
      return;
    }

    cerrarSesion().finally(() => {
      router.replace(RUTAS.INICIO_SESION);
    });
  }, [cargando, cerrarSesion, estaAutenticado, router, usuario?.rol]);

  if (cargando) {
    return <Cargando mensaje="Verificando sesión..." />;
  }

  if (!estaAutenticado) {
    return null;
  }

  if (!rolPuedeAccederPanel(usuario?.rol)) {
    return <Cargando mensaje="Validando permisos..." />;
  }

  return (
    <ProveedorConsulta>
      <ErrorLimite>
        <div className="flex min-h-screen bg-fondo-raiz text-[var(--texto-primario)]">
          <BarraLateral />
          <div className="flex min-w-0 flex-1 flex-col">
            <EncabezadoAdmin />
            <main className="flex-1 p-4 md:p-8">
              <div className="mx-auto w-full max-w-7xl">{children}</div>
            </main>
          </div>
        </div>
      </ErrorLimite>
    </ProveedorConsulta>
  );
}
