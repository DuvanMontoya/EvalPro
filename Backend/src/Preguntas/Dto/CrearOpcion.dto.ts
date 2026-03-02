/**
 * @archivo   CrearOpcion.dto.ts
 * @descripcion Valida una opción de respuesta asociada a una pregunta.
 * @modulo    Preguntas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsNotEmpty, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class CrearOpcionDto {
  @ApiProperty({ description: 'Letra identificadora de la opción', example: 'A' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(1)
  letra!: string;

  @ApiProperty({ description: 'Contenido de la opción', example: '42' })
  @IsString()
  @IsNotEmpty()
  contenido!: string;

  @ApiProperty({ description: 'Marca si la opción es correcta', example: false })
  @IsBoolean()
  esCorrecta!: boolean;

  @ApiProperty({ description: 'Orden visual de la opción', example: 1, required: false })
  @IsOptional()
  @Min(1)
  orden?: number;
}
