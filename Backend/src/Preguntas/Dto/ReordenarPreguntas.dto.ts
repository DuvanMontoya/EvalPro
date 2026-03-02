/**
 * @archivo   ReordenarPreguntas.dto.ts
 * @descripcion Define la carga útil para reordenar preguntas dentro de un examen.
 * @modulo    Preguntas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsArray, IsInt, IsNotEmpty, IsUUID, Min, ValidateNested } from 'class-validator';

class EntradaReordenamientoDto {
  @ApiProperty({ description: 'ID de la pregunta' })
  @IsUUID()
  idPregunta!: string;

  @ApiProperty({ description: 'Nuevo orden de la pregunta', example: 1 })
  @IsInt()
  @Min(1)
  orden!: number;
}

export class ReordenarPreguntasDto {
  @ApiProperty({ description: 'Lista de preguntas con su nuevo orden', type: [EntradaReordenamientoDto] })
  @IsArray()
  @IsNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => EntradaReordenamientoDto)
  preguntas!: EntradaReordenamientoDto[];
}
