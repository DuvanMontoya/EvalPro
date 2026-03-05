/**
 * @archivo   page.tsx
 * @descripcion Muestra el monitor en tiempo real para una sesión específica.
 * @modulo    Sesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useParams } from 'next/navigation';
import { toast } from 'sonner';
import { EstadoSesion } from '@/Tipos';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EncabezadoPagina } from '@/Componentes/Comunes/EncabezadoPagina';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { MonitorTiempoReal } from '@/Componentes/Sesiones/MonitorTiempoReal';
import { PanelCodigoAcceso } from '@/Componentes/Sesiones/PanelCodigoAcceso';
import { Boton } from '@/Componentes/Ui/Boton';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { useAutenticacion } from '@/Hooks/useAutenticacion';
import { useReporteSesion } from '@/Hooks/useReportes';
import { useDetalleSesion, useSesiones } from '@/Hooks/useSesiones';
import { RUTAS } from '@/Constantes/Rutas.constantes';
import { obtenerMensajeError } from '@/Lib/ErroresApi';
import { puedeActivarSesion, puedeCancelarSesion, puedeFinalizarSesion } from '@/Lib/Permisos';

/**
 * Renderiza vista de monitor WebSocket por sesión.
 */
export default function PaginaDetalleSesion() {
  const parametros = useParams<{ idSesion: string }>();
  const idSesion = parametros.idSesion;
  const { usuario } = useAutenticacion();
  const { mutacionActivarSesion, mutacionFinalizarSesion, mutacionCancelarSesion } = useSesiones();
  const consultaSesion = useDetalleSesion(idSesion);
  const consultaReporteSesion = useReporteSesion(idSesion);

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
  const activarHabilitado = puedeActivarSesion(usuario?.rol, sesion.estado);
  const finalizarHabilitado = puedeFinalizarSesion(usuario?.rol, sesion.estado);
  const cancelarHabilitado = puedeCancelarSesion(usuario?.rol, sesion.estado);

  return (
    <section className="space-y-6">
      <EncabezadoPagina
        etiqueta="Monitoreo"
        titulo={`Sesión ${sesion.codigoAcceso ?? 'pendiente'}`}
        descripcion="Supervisa estado en tiempo real y ejecuta acciones operativas de ciclo de sesión."
      />
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
        {activarHabilitado || finalizarHabilitado || cancelarHabilitado ? (
          <TarjetaContenido className="flex flex-wrap gap-2">
            {activarHabilitado ? (
              <Boton
                onClick={async () => {
                  try {
                    await mutacionActivarSesion.mutateAsync(idSesion);
                    toast.success('Sesión activada correctamente.');
                  } catch (error) {
                    toast.error(obtenerMensajeError(error, 'No se pudo activar la sesión.'));
                  }
                }}
                disabled={mutacionActivarSesion.isPending}
              >
                {mutacionActivarSesion.isPending ? 'Activando...' : 'Activar sesión'}
              </Boton>
            ) : null}
            {finalizarHabilitado ? (
              <Boton
                variante="peligro"
                onClick={async () => {
                  try {
                    await mutacionFinalizarSesion.mutateAsync(idSesion);
                    toast.success('Sesión finalizada correctamente.');
                  } catch (error) {
                    toast.error(obtenerMensajeError(error, 'No se pudo finalizar la sesión.'));
                  }
                }}
                disabled={mutacionFinalizarSesion.isPending}
              >
                {mutacionFinalizarSesion.isPending ? 'Finalizando...' : 'Finalizar sesión'}
              </Boton>
            ) : null}
            {cancelarHabilitado ? (
              <Boton
                variante="contorno"
                onClick={async () => {
                  try {
                    await mutacionCancelarSesion.mutateAsync(idSesion);
                    toast.success('Sesión cancelada correctamente.');
                  } catch (error) {
                    toast.error(obtenerMensajeError(error, 'No se pudo cancelar la sesión.'));
                  }
                }}
                disabled={mutacionCancelarSesion.isPending}
              >
                {mutacionCancelarSesion.isPending ? 'Cancelando...' : 'Cancelar sesión'}
              </Boton>
            ) : null}
          </TarjetaContenido>
        ) : null}
      </Tarjeta>
      {monitorDisponible ? (
        <MonitorTiempoReal
          idSesion={idSesion}
          totalPreguntas={sesion.examen?.totalPreguntas ?? 0}
          intentosRegistrados={consultaReporteSesion.data?.totalEstudiantes ?? 0}
          estudiantesReporte={consultaReporteSesion.data?.listaEstudiantes ?? []}
        />
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
