/**
 * @archivo   useEstudiantes.ts
 * @descripcion Administra consultas y creación de estudiantes desde módulo de usuarios.
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { API } from '@/Constantes/Api.constantes';
import { RespuestaApi, RolUsuario, Usuario } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

interface CrearEstudianteDto {
  nombre: string;
  apellidos: string;
  correo: string;
  contrasena: string;
  rol: RolUsuario.ESTUDIANTE;
}

/**
 * Consulta y muta el catálogo de estudiantes.
 */
export function useEstudiantes() {
  const cliente = useQueryClient();

  const consultaEstudiantes = useQuery({
    queryKey: ['estudiantes'],
    queryFn: async () => {
      const respuesta = await apiCliente.get<RespuestaApi<Usuario[]>>(API.USUARIOS, {
        params: { rol: RolUsuario.ESTUDIANTE },
      });
      return extraerDatos(respuesta).filter((usuario) => usuario.rol === RolUsuario.ESTUDIANTE);
    },
  });

  const mutacionCrearEstudiante = useMutation({
    mutationFn: async (dto: CrearEstudianteDto) => {
      const respuesta = await apiCliente.post<RespuestaApi<Usuario>>(API.USUARIOS, dto);
      return extraerDatos(respuesta);
    },
    onSuccess: () => cliente.invalidateQueries({ queryKey: ['estudiantes'] }),
  });

  const obtenerPorId = async (idEstudiante: string): Promise<Usuario> => {
    const respuesta = await apiCliente.get<RespuestaApi<Usuario>>(`${API.USUARIOS}/${idEstudiante}`);
    return extraerDatos(respuesta);
  };

  return {
    consultaEstudiantes,
    mutacionCrearEstudiante,
    obtenerPorId,
  };
}
