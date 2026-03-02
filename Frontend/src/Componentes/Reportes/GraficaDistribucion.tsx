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
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="rango" />
          <YAxis allowDecimals={false} />
          <Tooltip />
          <Bar dataKey="cantidad" fill="hsl(var(--primario))" radius={[6, 6, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
