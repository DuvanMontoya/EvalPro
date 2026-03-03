/**
 * @archivo   useAsignaciones.ts
 * @descripcion Expone mutaciones de asignaciones para flujos de creación canónicos.
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-03
 */
'use client';

import { useMutation } from '@tanstack/react-query';
import { crearAsignacion, CrearAsignacionDto } from '@/Servicios/Asignaciones.servicio';

/**
 * Gestiona operaciones de asignación de examen.
 */
export function useAsignaciones() {
  const mutacionCrearAsignacion = useMutation({
    mutationFn: (dto: CrearAsignacionDto) => crearAsignacion(dto),
  });

  return {
    mutacionCrearAsignacion,
  };
}

