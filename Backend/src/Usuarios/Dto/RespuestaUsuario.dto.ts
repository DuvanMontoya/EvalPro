/**
 * @archivo   RespuestaUsuario.dto.ts
 * @descripcion Representa un usuario para respuestas API sin datos sensibles.
 * @modulo    Usuarios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';

export class RespuestaUsuarioDto {
  @ApiProperty({ description: 'Identificador único del usuario' })
  id!: string;

  @ApiProperty({ description: 'Nombre del usuario' })
  nombre!: string;

  @ApiProperty({ description: 'Apellidos del usuario' })
  apellidos!: string;

  @ApiProperty({ description: 'Correo del usuario' })
  correo!: string;

  @ApiProperty({ description: 'Rol asignado', enum: RolUsuario })
  rol!: RolUsuario;

  @ApiProperty({ description: 'Indica si el usuario está activo' })
  activo!: boolean;

  @ApiProperty({ description: 'Fecha de creación del usuario' })
  fechaCreacion!: Date;

  @ApiProperty({ description: 'Fecha de última actualización del usuario' })
  fechaActualizacion!: Date;
}
