/**
 * @archivo   useReportes.ts
 * @descripcion Centraliza consultas de reportes de sesión/estudiante y métricas para tablero.
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useQuery } from '@tanstack/react-query';
import { EstadoSesion, RolUsuario, SesionExamen, Usuario } from '@/Tipos';
import {
  obtenerActividadSemanal,
  obtenerReporteEstudiante,
  obtenerReporteSesion,
  obtenerSesionesActivasHoy,
} from '@/Servicios/Reportes.servicio';
import { listarSesiones } from '@/Servicios/Sesiones.servicio';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';
import { API } from '@/Constantes/Api.constantes';
import { RespuestaApi } from '@/Tipos';

/**
 * Obtiene métricas reales para la vista de tablero.
 */
export function useTableroReportes() {
  const sesionesActivasHoy = useQuery({
    queryKey: ['reportes', 'sesion', 'activas-hoy'],
    queryFn: async () => {
      try {
        return await obtenerSesionesActivasHoy();
      } catch {
        return 0;
      }
    },
    refetchInterval: 30000,
  });

  const sesionesActivasAhora = useQuery({
    queryKey: ['sesiones', 'activas'],
    queryFn: async () => {
      const sesiones = await listarSesiones({ estado: EstadoSesion.ACTIVA });
      return sesiones.filter((sesion) => sesion.estado === EstadoSesion.ACTIVA).length;
    },
    refetchInterval: 30000,
  });

  const estudiantesConectados = useQuery({
    queryKey: ['usuarios', 'estudiantes', 'conectados'],
    queryFn: async () => {
      const respuesta = await apiCliente.get<RespuestaApi<Usuario[]>>(API.USUARIOS, {
        params: { rol: RolUsuario.ESTUDIANTE, conectadosAhora: true },
      });
      return extraerDatos(respuesta).filter((usuario) => usuario.rol === RolUsuario.ESTUDIANTE).length;
    },
    refetchInterval: 30000,
  });

  const ultimasSesiones = useQuery({
    queryKey: ['sesiones', 'ultimas'],
    queryFn: async () => {
      const sesiones = await listarSesiones({ limite: 5, orden: 'fechaCreacion_desc' });
      return sesiones.slice(0, 5) as SesionExamen[];
    },
    refetchInterval: 30000,
  });

  const actividadSemanal = useQuery({
    queryKey: ['reportes', 'actividad-semanal'],
    queryFn: async () => {
      try {
        return await obtenerActividadSemanal();
      } catch {
        return [];
      }
    },
    refetchInterval: 30000,
  });

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
