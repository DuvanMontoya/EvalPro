/**
 * @archivo   ReconciliarIntento.dto.ts
 * @descripcion Define el contrato mínimo de reconciliación del intento luego de trabajo offline.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsObject, IsOptional } from 'class-validator';

export class ReconciliarIntentoDto {
  @ApiPropertyOptional({ description: 'Evidencias o contexto del cierre offline a reconciliar' })
  @IsOptional()
  @IsObject()
  contexto?: Record<string, unknown>;
}
