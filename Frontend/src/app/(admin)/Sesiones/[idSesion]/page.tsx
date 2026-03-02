/**
 * @archivo   page.tsx
 * @descripcion Muestra el monitor en tiempo real para una sesión específica.
 * @modulo    Sesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useParams } from 'next/navigation';
import { EstadoSesion } from '@/Tipos';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { MonitorTiempoReal } from '@/Componentes/Sesiones/MonitorTiempoReal';
import { PanelCodigoAcceso } from '@/Componentes/Sesiones/PanelCodigoAcceso';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { useDetalleSesion } from '@/Hooks/useSesiones';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { obtenerMensajeError } from '@/Lib/ErroresApi';

/**
 * Renderiza vista de monitor WebSocket por sesión.
 */
export default function PaginaDetalleSesion() {
  const parametros = useParams<{ idSesion: string }>();
  const idSesion = parametros.idSesion;
  const consultaSesion = useDetalleSesion(idSesion);

  if (consultaSesion.isLoading) {
    return <Cargando mensaje="Cargando sesión..." />;
  }

  if (consultaSesion.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar la sesión"
        descripcion={obtenerMensajeError(consultaSesion.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  if (!consultaSesion.data) {
    return (
      <EstadoVacio
        titulo="Sesión no disponible"
        descripcion="No fue posible encontrar la sesión solicitada."
      />
    );
  }

  const sesion = consultaSesion.data as typeof consultaSesion.data & {
    examen?: { totalPreguntas: number; titulo: string };
  };
  const monitorDisponible = sesion.estado === EstadoSesion.ACTIVA;

  return (
    <section className="space-y-6">
      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>
            Sesión <span className="font-mono">{sesion.codigoAcceso}</span>
          </TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido className="grid gap-4 md:grid-cols-2">
          <PanelCodigoAcceso codigoAcceso={sesion.codigoAcceso} />
          <div className="rounded-lg border border-[var(--borde-sutil)] bg-fondo-elevado-3 p-4">
            <p className="text-sm text-[var(--texto-secundario)]">Estado actual</p>
            <p className="text-lg font-semibold text-[var(--texto-primario)]">{sesion.estado}</p>
            <p className="texto-muted mt-2">Examen: {sesion.examen?.titulo ?? 'No disponible'}</p>
          </div>
        </TarjetaContenido>
      </Tarjeta>
      {monitorDisponible ? (
        <MonitorTiempoReal idSesion={idSesion} totalPreguntas={sesion.examen?.totalPreguntas ?? 0} />
      ) : (
        <EstadoVacio
          titulo="Monitor no disponible"
          descripcion="El monitor en tiempo real solo está disponible cuando la sesión está activa."
          etiquetaAccion={sesion.estado === EstadoSesion.FINALIZADA ? 'Ver resultados' : undefined}
          hrefAccion={sesion.estado === EstadoSesion.FINALIZADA ? RUTAS.SESION_RESULTADOS(idSesion) : undefined}
        />
      )}
    </section>
  );
}
