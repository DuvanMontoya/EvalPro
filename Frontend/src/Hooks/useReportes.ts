/**
 * @archivo   useReportes.ts
 * @descripcion Centraliza consultas de reportes de sesión/estudiante y métricas para tablero.
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import { EstadoIntento, EstadoSesion, SesionExamen } from '@/Tipos';
import { obtenerReporteEstudiante, obtenerReporteSesion } from '@/Servicios/Reportes.servicio';
import { listarSesiones } from '@/Servicios/Sesiones.servicio';

interface SerieActividadDia {
  dia: string;
  cantidad: number;
}

function obtenerClaveDia(fecha: Date): string {
  return fecha.toISOString().slice(0, 10);
}

function construirActividadSemanal(sesiones: SesionExamen[]): SerieActividadDia[] {
  const dias: Date[] = [];
  const contador = new Map<string, number>();

  for (let desplazamiento = 6; desplazamiento >= 0; desplazamiento -= 1) {
    const fecha = new Date();
    fecha.setHours(0, 0, 0, 0);
    fecha.setDate(fecha.getDate() - desplazamiento);
    const clave = obtenerClaveDia(fecha);
    dias.push(fecha);
    contador.set(clave, 0);
  }

  for (const sesion of sesiones) {
    const fechaSesion = new Date(sesion.fechaCreacion);
    fechaSesion.setHours(0, 0, 0, 0);
    const clave = obtenerClaveDia(fechaSesion);
    if (contador.has(clave)) {
      contador.set(clave, (contador.get(clave) ?? 0) + 1);
    }
  }

  return dias.map((fecha) => {
    const clave = obtenerClaveDia(fecha);
    return {
      dia: fecha.toLocaleDateString('es-CO', { weekday: 'short' }),
      cantidad: contador.get(clave) ?? 0,
    };
  });
}

/**
 * Obtiene métricas reales para la vista de tablero.
 */
export function useTableroReportes() {
  const consultaSesionesTablero = useQuery({
    queryKey: ['sesiones', 'tablero'],
    queryFn: () => listarSesiones(),
    refetchInterval: 30000,
  });

  const idsSesionesActivas = useMemo(
    () =>
      (consultaSesionesTablero.data ?? [])
        .filter((sesion) => sesion.estado === EstadoSesion.ACTIVA)
        .map((sesion) => sesion.id),
    [consultaSesionesTablero.data],
  );

  const estudiantesConectados = useQuery({
    queryKey: ['tablero', 'estudiantes-conectados', idsSesionesActivas],
    queryFn: async () => {
      if (idsSesionesActivas.length === 0) {
        return 0;
      }

      const reportes = await Promise.all(
        idsSesionesActivas.map(async (idSesion) => {
          try {
            return await obtenerReporteSesion(idSesion);
          } catch {
            return null;
          }
        }),
      );

      return reportes.reduce((total, reporte) => {
        if (!reporte) {
          return total;
        }
        const conectadosSesion = reporte.listaEstudiantes.filter(
          (estudiante) =>
            estudiante.estado === EstadoIntento.EN_PROGRESO ||
            estudiante.estado === EstadoIntento.SINCRONIZACION_PENDIENTE,
        ).length;
        return total + conectadosSesion;
      }, 0);
    },
    staleTime: 1000 * 30,
    refetchInterval: 30000,
    enabled: !consultaSesionesTablero.isLoading,
  });

  const sesionesActivasHoy = useMemo(() => {
    const hoy = new Date();
    hoy.setHours(0, 0, 0, 0);
    const sesiones = consultaSesionesTablero.data ?? [];
    const total = sesiones.filter((sesion) => {
      if (sesion.estado !== EstadoSesion.ACTIVA) {
        return false;
      }

      const fechaReferencia = sesion.fechaInicio ? new Date(sesion.fechaInicio) : new Date(sesion.fechaCreacion);
      fechaReferencia.setHours(0, 0, 0, 0);
      return fechaReferencia.getTime() === hoy.getTime();
    }).length;

    return {
      data: total,
      isLoading: consultaSesionesTablero.isLoading,
      isError: consultaSesionesTablero.isError,
      error: consultaSesionesTablero.error,
    };
  }, [
    consultaSesionesTablero.data,
    consultaSesionesTablero.error,
    consultaSesionesTablero.isError,
    consultaSesionesTablero.isLoading,
  ]);

  const sesionesActivasAhora = useMemo(() => {
    const sesiones = consultaSesionesTablero.data ?? [];
    return {
      data: sesiones.filter((sesion) => sesion.estado === EstadoSesion.ACTIVA).length,
      isLoading: consultaSesionesTablero.isLoading,
      isError: consultaSesionesTablero.isError,
      error: consultaSesionesTablero.error,
    };
  }, [
    consultaSesionesTablero.data,
    consultaSesionesTablero.error,
    consultaSesionesTablero.isError,
    consultaSesionesTablero.isLoading,
  ]);

  const ultimasSesiones = useMemo(() => {
    const sesiones = [...(consultaSesionesTablero.data ?? [])].sort(
      (a, b) => new Date(b.fechaCreacion).getTime() - new Date(a.fechaCreacion).getTime(),
    );
    return {
      data: sesiones.slice(0, 5) as SesionExamen[],
      isLoading: consultaSesionesTablero.isLoading,
      isError: consultaSesionesTablero.isError,
      error: consultaSesionesTablero.error,
    };
  }, [
    consultaSesionesTablero.data,
    consultaSesionesTablero.error,
    consultaSesionesTablero.isError,
    consultaSesionesTablero.isLoading,
  ]);

  const actividadSemanal = useMemo(() => {
    const sesiones = consultaSesionesTablero.data ?? [];
    return {
      data: construirActividadSemanal(sesiones),
      isLoading: consultaSesionesTablero.isLoading,
      isError: consultaSesionesTablero.isError,
      error: consultaSesionesTablero.error,
    };
  }, [
    consultaSesionesTablero.data,
    consultaSesionesTablero.error,
    consultaSesionesTablero.isError,
    consultaSesionesTablero.isLoading,
  ]);

  return {
    sesionesActivasHoy,
    sesionesActivasAhora,
    estudiantesConectados,
    ultimasSesiones,
    actividadSemanal,
  };
}

/**
 * Obtiene reporte detallado de sesión.
 * @param idSesion - UUID de sesión.
 */
export function useReporteSesion(idSesion: string) {
  return useQuery({
    queryKey: ['reportes', 'sesion', idSesion],
    queryFn: () => obtenerReporteSesion(idSesion),
    staleTime: 2000,
    refetchInterval: 3000,
    enabled: Boolean(idSesion),
  });
}

/**
 * Obtiene reporte detallado de un estudiante.
 * @param idEstudiante - UUID de estudiante.
 */
export function useReporteEstudiante(idEstudiante: string) {
  return useQuery({
    queryKey: ['reportes', 'estudiante', idEstudiante],
    queryFn: () => obtenerReporteEstudiante(idEstudiante),
    enabled: Boolean(idEstudiante),
  });
}
