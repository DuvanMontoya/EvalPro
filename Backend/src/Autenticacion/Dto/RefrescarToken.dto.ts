/**
 * @archivo   RefrescarToken.dto.ts
 * @descripcion Define carga opcional para enviar refresh token por cuerpo en clientes sin header Bearer.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class RefrescarTokenDto {
  @ApiProperty({ description: 'Refresh token emitido previamente', example: 'eyJhbGciOiJIUzI1NiIsInR...' })
  @IsString()
  @IsNotEmpty()
  tokenRefresh!: string;
}
