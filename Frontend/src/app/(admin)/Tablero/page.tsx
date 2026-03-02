/**
 * @archivo   page.tsx
 * @descripcion Muestra métricas reales del sistema y actividad semanal en el tablero principal.
 * @modulo    Tablero
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { Line, LineChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { useTableroReportes } from '@/Hooks/useReportes';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';

function TarjetaMetrica({ titulo, valor }: { titulo: string; valor: number }) {
  return (
    <Tarjeta>
      <TarjetaEncabezado>
        <TarjetaTitulo className="text-sm text-[var(--texto-secundario)]">{titulo}</TarjetaTitulo>
      </TarjetaEncabezado>
      <TarjetaContenido>
        <p className="font-mono text-3xl font-bold text-[var(--acento-primario-hover)]">{valor}</p>
      </TarjetaContenido>
    </Tarjeta>
  );
}

/**
 * Renderiza vista de tablero con datos en vivo y resumen reciente.
 */
export default function PaginaTablero() {
  const {
    sesionesActivasHoy,
    sesionesActivasAhora,
    estudiantesConectados,
    ultimasSesiones,
    actividadSemanal,
  } = useTableroReportes();

  if (sesionesActivasHoy.isLoading || sesionesActivasAhora.isLoading || estudiantesConectados.isLoading) {
    return <Cargando mensaje="Cargando métricas del tablero..." />;
  }

  return (
    <section className="space-y-6">
      <div className="grid gap-4 md:grid-cols-3">
        <TarjetaMetrica titulo="Sesiones activas hoy" valor={sesionesActivasHoy.data ?? 0} />
        <TarjetaMetrica titulo="Sesiones activas ahora" valor={sesionesActivasAhora.data ?? 0} />
        <TarjetaMetrica titulo="Estudiantes conectados" valor={estudiantesConectados.data ?? 0} />
      </div>

      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Actividad semanal</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          <div className="h-72 w-full">
            <ResponsiveContainer>
              <LineChart data={actividadSemanal.data ?? []}>
                <CartesianGrid stroke="var(--borde-default)" strokeDasharray="3 3" />
                <XAxis dataKey="dia" stroke="var(--texto-terciario)" />
                <YAxis stroke="var(--texto-terciario)" />
                <Tooltip
                  contentStyle={{
                    background: 'var(--fondo-elevado-3)',
                    border: '1px solid var(--borde-default)',
                    borderRadius: 'var(--radio-md)',
                    color: 'var(--texto-primario)',
                  }}
                />
                <Line dataKey="cantidad" stroke="var(--acento-primario)" strokeWidth={3} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </TarjetaContenido>
      </Tarjeta>

      <Tarjeta>
        <TarjetaEncabezado>
          <TarjetaTitulo>Últimas sesiones</TarjetaTitulo>
        </TarjetaEncabezado>
        <TarjetaContenido>
          {(ultimasSesiones.data ?? []).length === 0 ? (
            <EstadoVacio
              titulo="Sin actividad reciente"
              descripcion="Aún no se han creado sesiones para mostrar en el tablero."
            />
          ) : (
            <ul className="space-y-2">
              {(ultimasSesiones.data ?? []).map((sesion) => (
                <li key={sesion.id} className="rounded-md border border-[var(--borde-sutil)] bg-fondo-elevado-3 p-3 text-sm">
                  <strong className="font-mono text-[var(--texto-primario)]">{sesion.codigoAcceso}</strong> - {sesion.estado}
                </li>
              ))}
            </ul>
          )}
        </TarjetaContenido>
      </Tarjeta>
    </section>
  );
}
