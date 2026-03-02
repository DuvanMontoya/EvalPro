/**
 * @archivo   page.tsx
 * @descripcion Consolida visualización de reportes de sesión con selección dinámica.
 * @modulo    Reportes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useEffect, useState } from 'react';
import { useSesiones } from '@/Hooks/useSesiones';
import { useReporteSesion } from '@/Hooks/useReportes';
import { Cargando } from '@/Componentes/Comunes/Cargando';
import { EstadoVacio } from '@/Componentes/Comunes/EstadoVacio';
import {
  Seleccion,
  SeleccionContenido,
  SeleccionDisparador,
  SeleccionItem,
  SeleccionValor,
} from '@/Componentes/Ui/Seleccion';
import { GraficaDistribucion } from '@/Componentes/Reportes/GraficaDistribucion';
import { GraficaDificultadPreguntas } from '@/Componentes/Reportes/GraficaDificultadPreguntas';
import { TablaResultadosDetallada } from '@/Componentes/Reportes/TablaResultadosDetallada';
import { Tarjeta, TarjetaContenido, TarjetaEncabezado, TarjetaTitulo } from '@/Componentes/Ui/Tarjeta';
import { obtenerMensajeError } from '@/Lib/ErroresApi';

/**
 * Renderiza módulo principal de reportes.
 */
export default function PaginaReportes() {
  const { consultaSesiones } = useSesiones();
  const [idSesionSeleccionada, setIdSesionSeleccionada] = useState('');

  useEffect(() => {
    if (!idSesionSeleccionada && (consultaSesiones.data?.length ?? 0) > 0) {
      setIdSesionSeleccionada(consultaSesiones.data![0]!.id);
    }
  }, [consultaSesiones.data, idSesionSeleccionada]);

  const reporte = useReporteSesion(idSesionSeleccionada);

  if (consultaSesiones.isLoading) {
    return <Cargando mensaje="Cargando sesiones para reportes..." />;
  }

  if (consultaSesiones.isError) {
    return (
      <EstadoVacio
        titulo="No fue posible cargar sesiones"
        descripcion={obtenerMensajeError(consultaSesiones.error, 'Intenta nuevamente en unos segundos.')}
      />
    );
  }

  const sesiones = consultaSesiones.data ?? [];
  if (sesiones.length === 0) {
    return <EstadoVacio titulo="Sin sesiones" descripcion="No hay sesiones disponibles para reportar." />;
  }

  return (
    <section className="space-y-6">
      <div className="max-w-sm">
        <Seleccion value={idSesionSeleccionada} onValueChange={setIdSesionSeleccionada}>
          <SeleccionDisparador>
            <SeleccionValor placeholder="Selecciona una sesión" />
          </SeleccionDisparador>
          <SeleccionContenido>
            {sesiones.map((sesion) => (
              <SeleccionItem key={sesion.id} value={sesion.id}>
                {sesion.codigoAcceso} - {sesion.estado}
              </SeleccionItem>
            ))}
          </SeleccionContenido>
        </Seleccion>
      </div>

      {reporte.isLoading ? (
        <Cargando mensaje="Cargando reporte seleccionado..." />
      ) : reporte.isError ? (
        <EstadoVacio
          titulo="No fue posible cargar el reporte"
          descripcion={obtenerMensajeError(reporte.error, 'Intenta nuevamente en unos segundos.')}
        />
      ) : !reporte.data ? (
        <EstadoVacio
          titulo="Sin datos para mostrar"
          descripcion="No existe información disponible para la sesión seleccionada."
        />
      ) : (
        <>
          <Tarjeta>
            <TarjetaEncabezado><TarjetaTitulo>Distribución de puntajes</TarjetaTitulo></TarjetaEncabezado>
            <TarjetaContenido><GraficaDistribucion datos={reporte.data.distribucionPuntajes} /></TarjetaContenido>
          </Tarjeta>

          <Tarjeta>
            <TarjetaEncabezado><TarjetaTitulo>Dificultad de preguntas</TarjetaTitulo></TarjetaEncabezado>
            <TarjetaContenido><GraficaDificultadPreguntas datos={reporte.data.dificultadPorPregunta} /></TarjetaContenido>
          </Tarjeta>

          <Tarjeta>
            <TarjetaEncabezado><TarjetaTitulo>Resultados detallados</TarjetaTitulo></TarjetaEncabezado>
            <TarjetaContenido><TablaResultadosDetallada filas={reporte.data.listaEstudiantes} /></TarjetaContenido>
          </Tarjeta>
        </>
      )}
    </section>
  );
}
