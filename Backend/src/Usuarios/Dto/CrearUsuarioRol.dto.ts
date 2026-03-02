/**
 * @archivo   CrearUsuarioRol.dto.ts
 * @descripcion Valida creación administrativa de usuario con rol fijo definido por la ruta.
 * @modulo    Usuarios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';

export class CrearUsuarioRolDto {
  @ApiProperty({ description: 'Nombre del usuario', example: 'Laura' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  nombre!: string;

  @ApiProperty({ description: 'Apellidos del usuario', example: 'Martinez Rojas' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  apellidos!: string;

  @ApiProperty({ description: 'Correo institucional del usuario', example: 'laura.martinez@evalpro.com' })
  @IsEmail()
  correo!: string;

  @ApiProperty({ description: 'Contraseña temporal inicial', example: 'TemporalSegura123!' })
  @IsString()
  @MinLength(8)
  contrasena!: string;
}
