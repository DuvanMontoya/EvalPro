/**
 * @archivo   TarjetaEstudianteMonitor.tsx
 * @descripcion Muestra estado de progreso y riesgo por estudiante dentro del monitor de sesión.
 * @modulo    ComponentesSesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ShieldAlert, ShieldCheck } from 'lucide-react';
import { EstadoIntento } from '@/Tipos';
import { Avatar, AvatarFallback } from '@/Componentes/Ui/Avatar';
import { Insignia } from '@/Componentes/Ui/Insignia';
import { Progreso } from '@/Componentes/Ui/Progreso';
import { obtenerIniciales } from '@/Lib/utils';

interface PropiedadesTarjetaEstudianteMonitor {
  nombreCompleto: string;
  preguntasRespondidas: number;
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
export function TarjetaEstudianteMonitor({
  nombreCompleto,
  preguntasRespondidas,
  totalPreguntas,
  modoKioscoActivo,
  eventosFraude,
  estadoIntento,
}: PropiedadesTarjetaEstudianteMonitor) {
  const porcentaje = totalPreguntas > 0 ? (preguntasRespondidas / totalPreguntas) * 100 : 0;

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
              <span className="font-mono">{preguntasRespondidas}/{totalPreguntas}</span> respondidas
            </p>
          </div>
        </div>
        {modoKioscoActivo ? (
          <ShieldCheck className="h-5 w-5 text-[var(--estado-exito)]" strokeWidth={1.5} />
        ) : (
          <ShieldAlert className="h-5 w-5 text-[var(--estado-peligro)]" strokeWidth={1.5} />
        )}
      </div>

      <div className="space-y-2">
        <Progreso valor={porcentaje} />
        <div className="flex items-center justify-between text-sm">
          {renderEstadoIntento(estadoIntento)}
          <Insignia variante={eventosFraude > 0 ? 'peligro' : 'neutro'}>
            Fraude: {eventosFraude}
          </Insignia>
        </div>
      </div>
    </article>
  );
}
