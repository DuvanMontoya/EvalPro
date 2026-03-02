/**
 * @archivo   page.tsx
 * @descripcion Presenta resultados agregados de una sesión finalizada con gráficas y tabla detallada.
 * @modulo    Sesiones
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useParams } from 'next/navigation';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { GraficaDistribucion } from '@/Componentes/Reportes/GraficaDistribucion';
import { GraficaDificultadPreguntas } from '@/Componentes/Reportes/GraficaDificultadPreguntas';
import { TablaResultadosDetallada } from '@/Componentes/Reportes/TablaResultadosDetallada';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { useReporteSesion } from '@/Hooks/useReportes';

/**
 * Renderiza reporte completo de resultados de la sesión.
 */
export default function PaginaResultadosSesion() {
  const parametros = useParams<{ idSesion: string }>();
  const idSesion = parametros.idSesion;
  const reporte = useReporteSesion(idSesion);

  if (reporte.isLoading || !reporte.data) {
    return <Cargando mensaje="Cargando reporte de sesión..." />;
  }

  const datos = reporte.data;

  return (
    <section className="space-y-6">
      <div className="grid gap-4 md:grid-cols-3">
        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo>Total estudiantes</TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido>
            <p className="font-mono text-3xl font-bold text-[var(--acento-primario-hover)]">
              {datos.totalEstudiantes}
            </p>
          </TarjetaContenido>
        </Tarjeta>
        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo>Entregaron</TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido>
            <p className="font-mono text-3xl font-bold text-[var(--estado-exito)]">
              {datos.estudiantesQueEnviaron}
            </p>
          </TarjetaContenido>
        </Tarjeta>
        <Tarjeta>
          <TarjetaEncabezado>
            <TarjetaTitulo>Sospechosos</TarjetaTitulo>
          </TarjetaEncabezado>
          <TarjetaContenido>
            <p className="font-mono text-3xl font-bold text-[var(--estado-peligro)]">
              {datos.estudiantesSospechosos}
            </p>
          </TarjetaContenido>
        </Tarjeta>
      </div>

      <Tarjeta>
        <TarjetaEncabezado><TarjetaTitulo>Distribución de puntajes</TarjetaTitulo></TarjetaEncabezado>
        <TarjetaContenido><GraficaDistribucion datos={datos.distribucionPuntajes} /></TarjetaContenido>
      </Tarjeta>

      <Tarjeta>
        <TarjetaEncabezado><TarjetaTitulo>Dificultad por pregunta</TarjetaTitulo></TarjetaEncabezado>
        <TarjetaContenido><GraficaDificultadPreguntas datos={datos.dificultadPorPregunta} /></TarjetaContenido>
      </Tarjeta>

      <Tarjeta>
        <TarjetaEncabezado><TarjetaTitulo>Resultados detallados</TarjetaTitulo></TarjetaEncabezado>
        <TarjetaContenido><TablaResultadosDetallada filas={datos.listaEstudiantes} /></TarjetaContenido>
      </Tarjeta>
    </section>
  );
}
