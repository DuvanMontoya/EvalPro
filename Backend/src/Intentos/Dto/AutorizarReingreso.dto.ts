/**
 * @archivo   AutorizarReingreso.dto.ts
 * @descripcion Permite al docente definir el mecanismo y contexto del token de reingreso.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export class AutorizarReingresoDto {
  @ApiPropertyOptional({ description: 'Método de autorización de reingreso', enum: ['PIN', 'QR'] })
  @IsOptional()
  @IsIn(['PIN', 'QR'])
  metodo?: 'PIN' | 'QR';

  @ApiPropertyOptional({ description: 'Identificador del dispositivo autorizado', maxLength: 120 })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  dispositivoAutoriza?: string;
}
