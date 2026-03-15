/**
 * @archivo   RegistrarUsuario.dto.ts
 * @descripcion Define los datos mínimos para registro administrativo de un usuario.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { IsEmail, IsEnum, IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength, MinLength } from 'class-validator';

export class RegistrarUsuarioDto {
  @ApiProperty({ description: 'Nombres del usuario', example: 'Laura' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nombre!: string;

  @ApiProperty({ description: 'Apellidos del usuario', example: 'Pineda Rojas' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  apellidos!: string;

  @ApiProperty({ description: 'Correo del usuario', example: 'laura.pineda@institucion.edu' })
  @IsEmail()
  correo!: string;

  @ApiProperty({ description: 'Contraseña inicial', example: 'ContrasenaSegura123!' })
  @IsString()
  @MinLength(8)
  contrasena!: string;

  @ApiProperty({ description: 'Rol asignado al usuario', enum: RolUsuario, example: RolUsuario.ESTUDIANTE })
  @IsEnum(RolUsuario)
  rol!: RolUsuario;

  @ApiProperty({
    description: 'ID de institución del usuario (obligatorio para roles distintos de SUPERADMINISTRADOR)',
    required: false,
  })
  @IsOptional()
  @IsUUID()
  idInstitucion?: string;
}
