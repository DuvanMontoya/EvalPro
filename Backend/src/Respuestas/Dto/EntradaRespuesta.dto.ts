/**
 * @archivo   EntradaRespuesta.dto.ts
 * @descripcion Valida una respuesta individual enviada por el estudiante.
 * @modulo    Respuestas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsArray, IsInt, IsOptional, IsString, IsUUID } from 'class-validator';

export class EntradaRespuestaDto {
  @ApiProperty({ description: 'ID de la pregunta respondida' })
  @IsUUID()
  idPregunta!: string;

  @ApiPropertyOptional({ description: 'Texto libre para preguntas abiertas' })
  @IsOptional()
  @IsString()
  valorTexto?: string;

  @ApiProperty({ description: 'Opciones seleccionadas por el estudiante', type: [String] })
  @IsArray()
  @IsString({ each: true })
  opcionesSeleccionadas!: string[];

  @ApiPropertyOptional({ description: 'Tiempo de respuesta en segundos', example: 12 })
  @IsOptional()
  @IsInt()
  tiempoRespuesta?: number;

  @ApiPropertyOptional({ description: 'Marca si la respuesta fue enviada offline', example: false })
  @IsOptional()
  esSincronizada?: boolean;
}
