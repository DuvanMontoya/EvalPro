/**
 * @archivo   TablaResultadosDetallada.tsx
 * @descripcion Presenta tabla de resultados por estudiante dentro del reporte de sesión.
 * @modulo    ComponentesReportes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { EstadoIntento } from '@/Tipos';
import { Insignia } from '@/Componentes/Ui/Insignia';
import {
  Tabla,
  TablaCabeza,
  TablaCelda,
  TablaCuerpo,
  TablaEncabezado,
  TablaFila,
} from '@/Componentes/Ui/Tabla';

interface FilaResultado {
  nombre: string;
  apellidos: string;
  puntaje: number | null;
  porcentaje: number | null;
  estado: EstadoIntento;
  esSospechoso: boolean;
}

interface PropiedadesTablaResultadosDetallada {
  filas: FilaResultado[];
}

/**
 * Renderiza tabla consolidada de resultados por estudiante.
 */
export function TablaResultadosDetallada({ filas }: PropiedadesTablaResultadosDetallada) {
  return (
    <Tabla>
      <TablaEncabezado>
        <TablaFila>
          <TablaCabeza>Estudiante</TablaCabeza>
          <TablaCabeza>Puntaje</TablaCabeza>
          <TablaCabeza>Porcentaje</TablaCabeza>
          <TablaCabeza>Estado</TablaCabeza>
          <TablaCabeza>Fraude</TablaCabeza>
        </TablaFila>
      </TablaEncabezado>
      <TablaCuerpo>
        {filas.map((fila) => (
          <TablaFila key={`${fila.nombre}-${fila.apellidos}`}>
            <TablaCelda>{fila.nombre} {fila.apellidos}</TablaCelda>
            <TablaCelda>{fila.puntaje ?? 'N/A'}</TablaCelda>
            <TablaCelda>{fila.porcentaje !== null ? `${fila.porcentaje}%` : 'N/A'}</TablaCelda>
            <TablaCelda>{fila.estado}</TablaCelda>
            <TablaCelda>
              <Insignia variante={fila.esSospechoso ? 'peligro' : 'exito'}>
                {fila.esSospechoso ? 'Sospechoso' : 'Normal'}
              </Insignia>
            </TablaCelda>
          </TablaFila>
        ))}
      </TablaCuerpo>
    </Tabla>
  );
}
