/**
 * @archivo   ProveedorConsulta.tsx
 * @descripcion Inicializa React Query con configuración global para consumo de datos remotos.
 * @modulo    ComponentesComunes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useState } from 'react';

interface PropiedadesProveedorConsulta {
  children: React.ReactNode;
}

/**
 * Provee contexto de React Query a las rutas hijas.
 * @param children - Nodos React que consumen queries y mutaciones.
 * @returns Provider de QueryClient.
 */
export function ProveedorConsulta({ children }: PropiedadesProveedorConsulta) {
  const [clienteConsulta] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 1000 * 60 * 2,
            refetchOnWindowFocus: false,
            retry: 1,
          },
        },
      }),
  );

  return <QueryClientProvider client={clienteConsulta}>{children}</QueryClientProvider>;
}
