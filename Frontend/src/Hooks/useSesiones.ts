/**
 * @archivo   useSesiones.ts
 * @descripcion Provee queries y mutaciones para administración de sesiones de examen.
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  activarSesion,
  crearSesion,
  CrearSesionDto,
  finalizarSesion,
  listarSesiones,
  obtenerSesionPorId,
} from '@/Servicios/Sesiones.servicio';

/**
 * Gestiona lista de sesiones de examen.
 */
export function useSesiones() {
  const cliente = useQueryClient();
  const invalidarDominioSesiones = (idSesion?: string) => {
    cliente.invalidateQueries({ queryKey: ['sesiones'] });
    if (idSesion) {
      cliente.invalidateQueries({ queryKey: ['sesiones', idSesion] });
      cliente.invalidateQueries({ queryKey: ['reportes', 'sesion', idSesion] });
    }
  };

  const consultaSesiones = useQuery({
    queryKey: ['sesiones'],
    queryFn: () => listarSesiones(),
    staleTime: 1000 * 60 * 2,
  });

  const mutacionCrearSesion = useMutation({
    mutationFn: (dto: CrearSesionDto) => crearSesion(dto),
    onSuccess: (sesion) => invalidarDominioSesiones(sesion.id),
  });

  const mutacionActivarSesion = useMutation({
    mutationFn: (idSesion: string) => activarSesion(idSesion),
    onSuccess: (sesion) => invalidarDominioSesiones(sesion.id),
  });

  const mutacionFinalizarSesion = useMutation({
    mutationFn: (idSesion: string) => finalizarSesion(idSesion),
    onSuccess: (sesion) => invalidarDominioSesiones(sesion.id),
  });

  return {
    consultaSesiones,
    mutacionCrearSesion,
    mutacionActivarSesion,
    mutacionFinalizarSesion,
  };
}

/**
 * Consulta detalle de una sesión específica.
 * @param idSesion - UUID de sesión.
 */
export function useDetalleSesion(idSesion: string) {
  return useQuery({
    queryKey: ['sesiones', idSesion],
    queryFn: () => obtenerSesionPorId(idSesion),
    enabled: Boolean(idSesion),
  });
}
