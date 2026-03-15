/**
 * @archivo   FinalizarProvisionalIntento.dto.ts
 * @descripcion Recibe metadatos opcionales del cierre offline provisional del intento.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsObject, IsOptional } from 'class-validator';

export class FinalizarProvisionalIntentoDto {
  @ApiPropertyOptional({ description: 'Resumen local del cierre provisional' })
  @IsOptional()
  @IsObject()
  contexto?: Record<string, unknown>;
}
