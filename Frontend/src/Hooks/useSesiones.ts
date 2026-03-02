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

  const consultaSesiones = useQuery({
    queryKey: ['sesiones'],
    queryFn: () => listarSesiones(),
  });

  const mutacionCrearSesion = useMutation({
    mutationFn: (dto: CrearSesionDto) => crearSesion(dto),
    onSuccess: () => cliente.invalidateQueries({ queryKey: ['sesiones'] }),
  });

  const mutacionActivarSesion = useMutation({
    mutationFn: (idSesion: string) => activarSesion(idSesion),
    onSuccess: () => cliente.invalidateQueries({ queryKey: ['sesiones'] }),
  });

  const mutacionFinalizarSesion = useMutation({
    mutationFn: (idSesion: string) => finalizarSesion(idSesion),
    onSuccess: () => cliente.invalidateQueries({ queryKey: ['sesiones'] }),
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
