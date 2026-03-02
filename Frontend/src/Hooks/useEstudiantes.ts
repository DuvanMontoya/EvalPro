/**
 * @archivo   useEstudiantes.ts
 * @descripcion Administra consultas y creación de usuarios académicos (docentes y estudiantes).
 * @modulo    Hooks
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { API } from '@/Constantes/Api.constantes';
import { RespuestaApi, RolUsuario, Usuario } from '@/Tipos';
import { apiCliente, extraerDatos } from '@/Servicios/ApiCliente';

type RolUsuarioAcademico = RolUsuario.ESTUDIANTE | RolUsuario.DOCENTE;

interface CrearUsuarioAcademicoDto {
  nombre: string;
  apellidos: string;
  correo: string;
  contrasena: string;
  rol: RolUsuarioAcademico;
}

/**
 * Consulta y muta el catálogo de usuarios académicos.
 */
export function useEstudiantes() {
  const cliente = useQueryClient();

  const consultaUsuariosAcademicos = useQuery({
    queryKey: ['usuarios', 'academicos'],
    queryFn: async () => {
      const respuesta = await apiCliente.get<RespuestaApi<Usuario[]>>(API.USUARIOS);
      return extraerDatos(respuesta).filter(
        (usuario) => usuario.rol === RolUsuario.ESTUDIANTE || usuario.rol === RolUsuario.DOCENTE,
      );
    },
  });

  const mutacionCrearUsuarioAcademico = useMutation({
    mutationFn: async (dto: CrearUsuarioAcademicoDto) => {
      const respuesta = await apiCliente.post<RespuestaApi<Usuario>>(API.USUARIOS, dto);
      return extraerDatos(respuesta);
    },
    onSuccess: () => cliente.invalidateQueries({ queryKey: ['usuarios', 'academicos'] }),
  });

  const obtenerPorId = async (idEstudiante: string): Promise<Usuario> => {
    const respuesta = await apiCliente.get<RespuestaApi<Usuario>>(`${API.USUARIOS}/${idEstudiante}`);
    return extraerDatos(respuesta);
  };

  return {
    consultaUsuariosAcademicos,
    mutacionCrearUsuarioAcademico,
    obtenerPorId,
  };
}
