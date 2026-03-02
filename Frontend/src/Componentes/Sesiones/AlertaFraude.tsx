/**
 * @archivo   AlertaFraude.tsx
 * @descripcion Presenta historial visual de alertas de fraude detectadas en una sesión.
 * @modulo    ComponentesSesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { AlertTriangle } from 'lucide-react';
import { formatearFecha } from '@/Lib/utils';

interface PropiedadesAlertaFraude {
  nombreEstudiante: string;
  tipoEvento: string;
  fecha: string;
}

/**
 * Renderiza una entrada de alerta de fraude.
 */
export function AlertaFraude({ nombreEstudiante, tipoEvento, fecha }: PropiedadesAlertaFraude) {
  return (
    <div className="rounded-md border border-red-300 bg-red-50 p-3 text-sm">
      <p className="flex items-center gap-2 font-semibold text-red-700">
        <AlertTriangle className="h-4 w-4" />
        {nombreEstudiante}
      </p>
      <p className="mt-1 text-red-800">Evento: {tipoEvento}</p>
      <p className="text-red-700/80">{formatearFecha(fecha)}</p>
    </div>
  );
}
