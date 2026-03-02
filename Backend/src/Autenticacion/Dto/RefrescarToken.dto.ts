/**
 * @archivo   RefrescarToken.dto.ts
 * @descripcion Solicita renovación de tokens mediante refresh token válido.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class RefrescarTokenDto {
  @ApiProperty({ description: 'Identificador del usuario autenticado', example: '6c2f4dca-1d58-45a1-a9fc-9322ad2a38ee' })
  @IsUUID()
  @IsNotEmpty()
  idUsuario!: string;

  @ApiProperty({ description: 'Refresh token emitido previamente', example: 'eyJhbGciOiJIUzI1NiIsInR...' })
  @IsString()
  @IsNotEmpty()
  tokenRefresh!: string;
}
