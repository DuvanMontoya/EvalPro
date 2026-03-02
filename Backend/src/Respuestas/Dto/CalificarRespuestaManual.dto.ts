/**
 * @archivo   CalificarRespuestaManual.dto.ts
 * @descripcion Valida el puntaje asignado manualmente a una respuesta de tipo abierta.
 * @modulo    Respuestas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class CalificarRespuestaManualDto {
  @ApiProperty({ description: 'Puntaje otorgado por el docente para la respuesta abierta', example: 0.75 })
  @IsNumber()
  @Min(0)
  @IsNotEmpty()
  puntajeObtenido!: number;

  @ApiPropertyOptional({ description: 'Observación opcional del docente sobre la calificación' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  observacion?: string;
}
