/**
 * @archivo   GraficaDistribucion.tsx
 * @descripcion Dibuja distribución de puntajes por rangos para reporte de sesión.
 * @modulo    ComponentesReportes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';

interface PropiedadesGraficaDistribucion {
  datos: { rango: string; cantidad: number }[];
}

/**
 * Renderiza gráfica de barras con distribución de puntajes.
 */
export function GraficaDistribucion({ datos }: PropiedadesGraficaDistribucion) {
  return (
    <div className="h-72 w-full">
      <ResponsiveContainer>
        <BarChart data={datos}>
          <CartesianGrid stroke="var(--borde-default)" strokeDasharray="3 3" />
          <XAxis dataKey="rango" stroke="var(--texto-terciario)" />
          <YAxis allowDecimals={false} stroke="var(--texto-terciario)" />
          <Tooltip
            contentStyle={{
              background: 'var(--fondo-elevado-3)',
              border: '1px solid var(--borde-default)',
              borderRadius: 'var(--radio-md)',
              color: 'var(--texto-primario)',
            }}
          />
          <Bar dataKey="cantidad" fill="var(--acento-primario)" radius={[6, 6, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
