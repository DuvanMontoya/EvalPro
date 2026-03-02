/**
 * @archivo   useExamenes.ts
 * @descripcion Implementa queries y mutaciones React Query para dominio de exámenes y preguntas.
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  actualizarExamen,
  archivarExamen,
  crearExamen,
  CrearExamenDto,
  listarExamenes,
  obtenerExamenPorId,
  publicarExamen,
} from '@/Servicios/Examenes.servicio';
import {
  crearPregunta,
  CrearPreguntaDto,
  eliminarPregunta,
  listarPreguntas,
  reordenarPreguntas,
} from '@/Servicios/Preguntas.servicio';

/**
 * Gestiona catálogo general de exámenes.
 */
export function useExamenes() {
  const cliente = useQueryClient();

  const consultaExamenes = useQuery({
    queryKey: ['examenes'],
    queryFn: listarExamenes,
    staleTime: 1000 * 60 * 2,
    refetchOnWindowFocus: false,
  });

  const mutacionCrearExamen = useMutation({
    mutationFn: (dto: CrearExamenDto) => crearExamen(dto),
    onSuccess: () => cliente.invalidateQueries({ queryKey: ['examenes'] }),
  });

  const mutacionPublicarExamen = useMutation({
    mutationFn: (idExamen: string) => publicarExamen(idExamen),
    onSuccess: () => cliente.invalidateQueries({ queryKey: ['examenes'] }),
  });

  const mutacionArchivarExamen = useMutation({
    mutationFn: (idExamen: string) => archivarExamen(idExamen),
    onSuccess: () => cliente.invalidateQueries({ queryKey: ['examenes'] }),
  });

  return {
    consultaExamenes,
    mutacionCrearExamen,
    mutacionPublicarExamen,
    mutacionArchivarExamen,
    actualizarExamen,
  };
}

/**
 * Gestiona detalle de examen y CRUD de preguntas.
 * @param idExamen - UUID del examen objetivo.
 */
export function useExamenDetalle(idExamen: string) {
  const cliente = useQueryClient();

  const consultaExamen = useQuery({
    queryKey: ['examenes', idExamen],
    queryFn: () => obtenerExamenPorId(idExamen),
    enabled: Boolean(idExamen),
  });

  const consultaPreguntas = useQuery({
    queryKey: ['preguntas', idExamen],
    queryFn: () => listarPreguntas(idExamen),
    enabled: Boolean(idExamen),
  });

  const mutacionAgregarPregunta = useMutation({
    mutationFn: (dto: CrearPreguntaDto) => crearPregunta(idExamen, dto),
    onSuccess: () => {
      cliente.invalidateQueries({ queryKey: ['preguntas', idExamen] });
      cliente.invalidateQueries({ queryKey: ['examenes', idExamen] });
      cliente.invalidateQueries({ queryKey: ['examenes'] });
    },
  });

  const mutacionEliminarPregunta = useMutation({
    mutationFn: (idPregunta: string) => eliminarPregunta(idExamen, idPregunta),
    onSuccess: () => {
      cliente.invalidateQueries({ queryKey: ['preguntas', idExamen] });
      cliente.invalidateQueries({ queryKey: ['examenes', idExamen] });
    },
  });

  const mutacionReordenarPreguntas = useMutation({
    mutationFn: (preguntas: { idPregunta: string; orden: number }[]) => reordenarPreguntas(idExamen, preguntas),
    onSuccess: () => cliente.invalidateQueries({ queryKey: ['preguntas', idExamen] }),
  });

  return {
    consultaExamen,
    consultaPreguntas,
    mutacionAgregarPregunta,
    mutacionEliminarPregunta,
    mutacionReordenarPreguntas,
  };
}
