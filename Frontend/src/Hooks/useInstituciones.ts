/**
 * @archivo   useInstituciones.ts
 * @descripcion Gestiona consultas y mutaciones de instituciones para superadministración.
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  cambiarEstadoInstitucion,
  CambiarEstadoInstitucionDto,
  crearInstitucion,
  CrearInstitucionDto,
  listarInstituciones,
} from '@/Servicios/Instituciones.servicio';

export function useInstituciones() {
  const cliente = useQueryClient();
  const invalidar = () => cliente.invalidateQueries({ queryKey: ['instituciones'] });

  const consultaInstituciones = useQuery({
    queryKey: ['instituciones'],
    queryFn: listarInstituciones,
    staleTime: 1000 * 60,
  });

  const mutacionCrearInstitucion = useMutation({
    mutationFn: (dto: CrearInstitucionDto) => crearInstitucion(dto),
    onSuccess: invalidar,
  });

  const mutacionCambiarEstadoInstitucion = useMutation({
    mutationFn: ({ idInstitucion, dto }: { idInstitucion: string; dto: CambiarEstadoInstitucionDto }) =>
      cambiarEstadoInstitucion(idInstitucion, dto),
    onSuccess: invalidar,
  });

  return {
    consultaInstituciones,
    mutacionCrearInstitucion,
    mutacionCambiarEstadoInstitucion,
  };
}

