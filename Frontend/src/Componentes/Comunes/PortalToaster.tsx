/**
 * @archivo   PortalToaster.tsx
 * @descripcion Monta el sistema de notificaciones global en el cliente.
 * @modulo    ComponentesComunes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { Toaster } from 'sonner';

/**
 * Renderiza portal de toasts con estilos de diseño del sistema.
 */
export function PortalToaster() {
  return (
    <Toaster
      richColors
      position="bottom-right"
      toastOptions={{
        style: {
          background: 'var(--fondo-elevado-3)',
          border: '1px solid var(--borde-fuerte)',
          color: 'var(--texto-primario)',
          borderRadius: 'var(--radio-lg)',
        },
      }}
    />
  );
}

