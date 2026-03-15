/**
 * @archivo   IniciarSesion.dto.ts
 * @descripcion Valida las credenciales requeridas para autenticar un usuario.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';

export class IniciarSesionDto {
  @ApiProperty({ description: 'Correo institucional del usuario', example: 'usuario@institucion.edu' })
  @IsEmail()
  @IsNotEmpty()
  correo!: string;

  @ApiProperty({ description: 'Contraseña del usuario', example: 'ContrasenaSegura123!' })
  @IsString()
  @MinLength(8)
  contrasena!: string;
}
