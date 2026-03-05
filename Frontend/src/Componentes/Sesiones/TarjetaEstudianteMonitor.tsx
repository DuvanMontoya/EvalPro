/**
 * @archivo   TarjetaEstudianteMonitor.tsx
 * @descripcion Muestra estado de progreso y riesgo por estudiante dentro del monitor de sesión.
 * @modulo    ComponentesSesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { memo, useMemo } from 'react';
import { ShieldAlert, ShieldCheck, TimerReset } from 'lucide-react';
import { EstadoIntento } from '@/Tipos';
import { Avatar, AvatarFallback } from '@/Componentes/Ui/Avatar';
import { Insignia } from '@/Componentes/Ui/Insignia';
import { Progreso } from '@/Componentes/Ui/Progreso';
import { obtenerIniciales } from '@/Lib/utils';

interface PropiedadesTarjetaEstudianteMonitor {
  nombreCompleto: string;
  preguntasRespondidas: number;
  preguntasRespondidasIndices: number[];
  indicePreguntaActual?: number;
  totalPreguntas: number;
  modoKioscoActivo: boolean;
  eventosFraude: number;
  estadoIntento: EstadoIntento;
}

function renderEstadoIntento(estado: EstadoIntento) {
  if (estado === EstadoIntento.ENVIADO) {
    return <Insignia variante="exito">Enviado</Insignia>;
  }
  if (estado === EstadoIntento.ANULADO) {
    return <Insignia variante="peligro">Anulado</Insignia>;
  }
  if (estado === EstadoIntento.SINCRONIZACION_PENDIENTE) {
    return <Insignia variante="alerta">Sincronización pendiente</Insignia>;
  }
  return <Insignia variante="primario">En progreso</Insignia>;
}

/**
 * Renderiza tarjeta individual del monitor en tiempo real.
 */
export const TarjetaEstudianteMonitor = memo(function TarjetaEstudianteMonitor({
  nombreCompleto,
  preguntasRespondidas,
  preguntasRespondidasIndices,
  indicePreguntaActual,
  totalPreguntas,
  modoKioscoActivo,
  eventosFraude,
  estadoIntento,
}: PropiedadesTarjetaEstudianteMonitor) {
  const preguntasRespondidasSet = useMemo(() => new Set(preguntasRespondidasIndices), [preguntasRespondidasIndices]);
  const respondidasTotales = Math.max(preguntasRespondidas, preguntasRespondidasSet.size);
  const porcentaje = totalPreguntas > 0 ? (respondidasTotales / totalPreguntas) * 100 : 0;
  const preguntasPendientes = Math.max(0, totalPreguntas - respondidasTotales);
  const secuenciaPreguntas = useMemo(
    () => Array.from({ length: Math.max(0, totalPreguntas) }, (_, indice) => indice + 1),
    [totalPreguntas],
  );

  return (
    <article className="rounded-xl border border-[var(--borde-sutil)] bg-fondo-elevado-2 p-4 shadow-sombra-sm transicion-normal">
      <div className="mb-3 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <Avatar>
            <AvatarFallback>{obtenerIniciales(nombreCompleto)}</AvatarFallback>
          </Avatar>
          <div>
            <h4 className="font-semibold text-[var(--texto-primario)]">{nombreCompleto}</h4>
            <p className="text-sm text-[var(--texto-secundario)]">
              <span className="font-mono">{respondidasTotales}/{totalPreguntas}</span> respondidas
            </p>
          </div>
        </div>
        {modoKioscoActivo ? (
          <ShieldCheck className="h-5 w-5 text-[var(--estado-exito)]" strokeWidth={1.5} />
        ) : (
          <ShieldAlert className="h-5 w-5 text-[var(--estado-peligro)]" strokeWidth={1.5} />
        )}
      </div>

      <div className="space-y-3">
        <Progreso valor={porcentaje} />

        <div className="flex flex-wrap items-center gap-2 text-xs">
          <Insignia variante="primario">Respondidas: {respondidasTotales}</Insignia>
          <Insignia variante="neutro">Pendientes: {preguntasPendientes}</Insignia>
          {typeof indicePreguntaActual === 'number' ? (
            <Insignia variante="alerta">Actual: #{indicePreguntaActual}</Insignia>
          ) : null}
          <Insignia variante={eventosFraude > 0 ? 'peligro' : 'neutro'}>Fraude: {eventosFraude}</Insignia>
        </div>

        {secuenciaPreguntas.length > 0 ? (
          <div className="rounded-lg border border-[var(--borde-sutil)] bg-fondo-elevado-3 p-2">
            <div className="mb-2 flex items-center justify-between text-xs text-[var(--texto-secundario)]">
              <span>Mapa por pregunta</span>
              <span className="inline-flex items-center gap-1">
                <TimerReset className="h-3.5 w-3.5" />
                Actualización en vivo
              </span>
            </div>
            <div className="mb-2 flex flex-wrap items-center gap-2 text-[11px] text-[var(--texto-secundario)]">
              <span className="inline-flex items-center gap-1">
                <span className="h-2.5 w-2.5 rounded-full bg-[var(--estado-exito-sutil)] ring-1 ring-[var(--estado-exito)]" />
                Respondida
              </span>
              <span className="inline-flex items-center gap-1">
                <span className="h-2.5 w-2.5 rounded-full bg-fondo-elevado-2 ring-1 ring-[var(--borde-sutil)]" />
                Pendiente
              </span>
              <span className="inline-flex items-center gap-1">
                <span className="h-2.5 w-2.5 rounded-full bg-fondo-elevado-2 ring-2 ring-[var(--estado-info)]" />
                Actual
              </span>
            </div>
            <div className="max-h-28 overflow-y-auto pr-1">
              <div className="grid gap-1.5" style={{ gridTemplateColumns: 'repeat(10, minmax(0, 1fr))' }}>
                {secuenciaPreguntas.map((numeroPregunta) => {
                  const respondida = preguntasRespondidasSet.has(numeroPregunta);
                  const esActual = indicePreguntaActual === numeroPregunta;
                  return (
                    <span
                      key={numeroPregunta}
                      title={`Pregunta ${numeroPregunta}`}
                      className={[
                        'inline-flex h-6 w-6 items-center justify-center rounded-full border text-[11px] font-semibold transition-all',
                        respondida
                          ? 'border-[var(--estado-exito)] bg-[var(--estado-exito-sutil)] text-[var(--estado-exito)]'
                          : 'border-[var(--borde-sutil)] bg-fondo-elevado-2 text-[var(--texto-secundario)]',
                        esActual ? 'ring-2 ring-[var(--estado-info)] ring-offset-1 ring-offset-transparent' : '',
                      ].join(' ')}
                    >
                      {numeroPregunta}
                    </span>
                  );
                })}
              </div>
            </div>
          </div>
        ) : null}

        <div className="flex items-center justify-between text-sm">
          {renderEstadoIntento(estadoIntento)}
          <span className="text-xs text-[var(--texto-secundario)]">Control granular activo</span>
        </div>
      </div>
    </article>
  );
});
