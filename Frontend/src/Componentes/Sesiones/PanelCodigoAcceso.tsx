/**
 * @archivo   PanelCodigoAcceso.tsx
 * @descripcion Destaca el código de acceso de la sesión para compartirlo con estudiantes.
 * @modulo    ComponentesSesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';

interface PropiedadesPanelCodigoAcceso {
  codigoAcceso: string | null;
}

/**
 * Renderiza tarjeta de código de acceso de sesión.
 */
export function PanelCodigoAcceso({ codigoAcceso }: PropiedadesPanelCodigoAcceso) {
  const codigoVisible = codigoAcceso ?? '------';

  return (
    <Tarjeta>
      <TarjetaEncabezado>
        <TarjetaTitulo>Código de Acceso</TarjetaTitulo>
      </TarjetaEncabezado>
      <TarjetaContenido>
        <div className="rounded-md border border-[var(--acento-primario-borde)] bg-[var(--acento-primario-sutil)] p-4 text-center font-mono text-3xl font-bold tracking-widest text-[var(--acento-primario-hover)]">
          {codigoVisible}
        </div>
        {!codigoAcceso ? (
          <p className="mt-2 text-center text-xs text-[var(--texto-secundario)]">
            Se genera automáticamente cuando la sesión se activa.
          </p>
        ) : null}
      </TarjetaContenido>
    </Tarjeta>
  );
}
