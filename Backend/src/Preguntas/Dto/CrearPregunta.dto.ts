/**
 * @archivo   CrearPregunta.dto.ts
 * @descripcion Contiene validaciones para crear preguntas y sus opciones.
 * @modulo    Preguntas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { TipoPregunta } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { CrearOpcionDto } from './CrearOpcion.dto';

export class CrearPreguntaDto {
  @ApiProperty({ description: 'Enunciado de la pregunta' })
  @IsString()
  @IsNotEmpty()
  enunciado!: string;

  @ApiProperty({ description: 'Tipo de pregunta', enum: TipoPregunta })
  @IsEnum(TipoPregunta)
  tipo!: TipoPregunta;

  @ApiProperty({ description: 'Puntaje asignado a la pregunta', example: 1 })
  @IsNumber()
  @Min(0)
  puntaje!: number;

  @ApiPropertyOptional({ description: 'Tiempo sugerido para responder en segundos' })
  @IsOptional()
  @Min(1)
  tiempoSugerido?: number;

  @ApiPropertyOptional({ description: 'URL de imagen de apoyo' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  imagenUrl?: string;

  @ApiPropertyOptional({ description: 'Opciones de respuesta para preguntas cerradas', type: [CrearOpcionDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CrearOpcionDto)
  opciones?: CrearOpcionDto[];
}
