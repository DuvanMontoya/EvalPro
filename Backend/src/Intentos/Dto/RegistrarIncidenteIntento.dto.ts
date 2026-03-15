/**
 * @archivo   RegistrarIncidenteIntento.dto.ts
 * @descripcion Define el contrato para registrar incidentes y aplicar bloqueo/suspensión del intento.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { TipoIncidente } from '@prisma/client';
import { IsEnum, IsObject, IsOptional, IsString, MaxLength } from 'class-validator';

export class RegistrarIncidenteIntentoDto {
  @ApiProperty({ description: 'Tipo de incidente detectado', enum: TipoIncidente })
  @IsEnum(TipoIncidente)
  tipo!: TipoIncidente;

  @ApiPropertyOptional({ description: 'Descripción legible del incidente', maxLength: 500 })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  descripcion?: string;

  @ApiPropertyOptional({ description: 'Contexto serializable del incidente' })
  @IsOptional()
  @IsObject()
  contexto?: Record<string, unknown>;
}
