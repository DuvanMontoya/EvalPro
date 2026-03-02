/**
 * @archivo   CrearUsuario.dto.ts
 * @descripcion Declara validaciones para crear usuarios desde el panel administrativo.
 * @modulo    Usuarios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { RolUsuario } from '@prisma/client';
import { IsEmail, IsEnum, IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';

export class CrearUsuarioDto {
  @ApiProperty({ description: 'Nombre del usuario', example: 'Juan' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nombre!: string;

  @ApiProperty({ description: 'Apellidos del usuario', example: 'Pérez Gómez' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  apellidos!: string;

  @ApiProperty({ description: 'Correo del usuario', example: 'juan.perez@evalpro.com' })
  @IsEmail()
  correo!: string;

  @ApiProperty({ description: 'Contraseña temporal', example: 'ContrasenaSegura123!' })
  @IsString()
  @MinLength(8)
  contrasena!: string;

  @ApiProperty({ description: 'Rol del usuario en la plataforma', enum: RolUsuario, example: RolUsuario.ESTUDIANTE })
  @IsEnum(RolUsuario)
  rol!: RolUsuario;
}
