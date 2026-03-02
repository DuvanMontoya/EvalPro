/**
 * @archivo   GraficaDificultadPreguntas.tsx
 * @descripcion Muestra porcentaje de acierto por pregunta para detectar ítems complejos.
 * @modulo    ComponentesReportes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';

interface PropiedadesGraficaDificultadPreguntas {
  datos: { idPregunta: string; enunciado: string; porcentajeAcierto: number }[];
}

/**
 * Renderiza gráfica horizontal de acierto por pregunta.
 */
export function GraficaDificultadPreguntas({ datos }: PropiedadesGraficaDificultadPreguntas) {
  return (
    <div className="h-80 w-full">
      <ResponsiveContainer>
        <BarChart data={datos} layout="vertical" margin={{ left: 40 }}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis type="number" domain={[0, 100]} />
          <YAxis type="category" dataKey="idPregunta" width={70} />
          <Tooltip />
          <Bar dataKey="porcentajeAcierto" fill="hsl(var(--secundario))" radius={[0, 6, 6, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}
