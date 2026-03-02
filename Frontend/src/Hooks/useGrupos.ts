/**
 * @archivo   useGrupos.ts
 * @descripcion Gestiona consultas y mutaciones para grupos académicos y periodos.
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  asignarDocenteGrupo,
  cambiarEstadoGrupo,
  crearGrupo,
  CrearGrupoDto,
  EstadoGrupo,
  inscribirEstudianteGrupo,
  listarGrupos,
} from '@/Servicios/Grupos.servicio';
import { crearPeriodo, CrearPeriodoAcademicoDto, listarPeriodos } from '@/Servicios/Periodos.servicio';

export function useGrupos(idInstitucion?: string, habilitado = true) {
  const cliente = useQueryClient();
  const invalidar = () => {
    cliente.invalidateQueries({ queryKey: ['grupos', idInstitucion ?? 'tenant'] });
  };

  const consultaGrupos = useQuery({
    queryKey: ['grupos', idInstitucion ?? 'tenant'],
    queryFn: () => listarGrupos(idInstitucion),
    staleTime: 1000 * 30,
    enabled: habilitado,
  });

  const mutacionCrearGrupo = useMutation({
    mutationFn: (dto: CrearGrupoDto) => crearGrupo(dto),
    onSuccess: invalidar,
  });

  const mutacionAsignarDocente = useMutation({
    mutationFn: ({ idGrupo, idDocente }: { idGrupo: string; idDocente: string }) => asignarDocenteGrupo(idGrupo, idDocente),
    onSuccess: invalidar,
  });

  const mutacionInscribirEstudiante = useMutation({
    mutationFn: ({ idGrupo, idEstudiante }: { idGrupo: string; idEstudiante: string }) =>
      inscribirEstudianteGrupo(idGrupo, idEstudiante),
    onSuccess: invalidar,
  });

  const mutacionCambiarEstado = useMutation({
    mutationFn: ({ idGrupo, estado }: { idGrupo: string; estado: EstadoGrupo }) => cambiarEstadoGrupo(idGrupo, estado),
    onSuccess: invalidar,
  });

  return {
    consultaGrupos,
    mutacionCrearGrupo,
    mutacionAsignarDocente,
    mutacionInscribirEstudiante,
    mutacionCambiarEstado,
  };
}

export function usePeriodos(idInstitucion?: string, habilitado = true) {
  const cliente = useQueryClient();
  const invalidar = () => cliente.invalidateQueries({ queryKey: ['periodos', idInstitucion ?? 'tenant'] });

  const consultaPeriodos = useQuery({
    queryKey: ['periodos', idInstitucion ?? 'tenant'],
    queryFn: () => listarPeriodos(idInstitucion),
    staleTime: 1000 * 30,
    enabled: habilitado,
  });

  const mutacionCrearPeriodo = useMutation({
    mutationFn: (dto: CrearPeriodoAcademicoDto) => crearPeriodo(dto),
    onSuccess: invalidar,
  });

  return {
    consultaPeriodos,
    mutacionCrearPeriodo,
  };
}
