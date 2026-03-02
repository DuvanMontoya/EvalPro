/**
 * @archivo   RegistrarEvento.dto.ts
 * @descripcion Valida la carga útil para registrar eventos de telemetría del examen.
 * @modulo    Telemetria
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { TipoEventoTelemetria } from '@prisma/client';
import { IsEnum, IsInt, IsObject, IsOptional, IsString, IsUUID, MaxLength, Min } from 'class-validator';

export class RegistrarEventoDto {
  @ApiProperty({ description: 'ID del intento asociado al evento' })
  @IsUUID()
  idIntento!: string;

  @ApiProperty({ description: 'Tipo de evento de telemetría', enum: TipoEventoTelemetria })
  @IsEnum(TipoEventoTelemetria)
  tipo!: TipoEventoTelemetria;

  @ApiPropertyOptional({ description: 'Descripción corta del evento' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  descripcion?: string;

  @ApiPropertyOptional({ description: 'Metadatos JSON del evento' })
  @IsOptional()
  @IsObject()
  metadatos?: Record<string, unknown>;

  @ApiPropertyOptional({ description: 'Número de pregunta relacionada' })
  @IsOptional()
  @IsInt()
  @Min(1)
  numeroPregunta?: number;

  @ApiPropertyOptional({ description: 'Tiempo transcurrido en segundos al momento del evento' })
  @IsOptional()
  @IsInt()
  @Min(0)
  tiempoTranscurrido?: number;
}
