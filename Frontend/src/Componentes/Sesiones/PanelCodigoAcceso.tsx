/**
 * @archivo   PanelCodigoAcceso.tsx
 * @descripcion Destaca el código de acceso de la sesión para compartirlo con estudiantes.
 * @modulo    ComponentesSesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';

interface PropiedadesPanelCodigoAcceso {
  codigoAcceso: string;
}

/**
 * Renderiza tarjeta de código de acceso de sesión.
 */
export function PanelCodigoAcceso({ codigoAcceso }: PropiedadesPanelCodigoAcceso) {
  return (
    <Tarjeta>
      <TarjetaEncabezado>
        <TarjetaTitulo>Código de Acceso</TarjetaTitulo>
      </TarjetaEncabezado>
      <TarjetaContenido>
        <div className="rounded-md bg-slate-100 p-4 text-center text-3xl font-bold tracking-widest text-primario">
          {codigoAcceso}
        </div>
      </TarjetaContenido>
    </Tarjeta>
  );
}
