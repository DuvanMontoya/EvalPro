/**
 * @archivo   ConsumirTokenReingreso.dto.ts
 * @descripcion Recibe el código de reingreso emitido por el docente para desbloquear un intento.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { ApiProperty } from '@nestjs/swagger';
import { IsString, MaxLength, MinLength } from 'class-validator';

export class ConsumirTokenReingresoDto {
  @ApiProperty({ description: 'PIN o token visible del reingreso', minLength: 4, maxLength: 12 })
  @IsString()
  @MinLength(4)
  @MaxLength(12)
  codigo!: string;
}
