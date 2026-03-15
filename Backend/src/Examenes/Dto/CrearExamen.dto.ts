/**
 * @archivo   CrearExamen.dto.ts
 * @descripcion Define validaciones para crear un examen nuevo.
 * @modulo    Examenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ModalidadExamen } from '@prisma/client';
import { IsBoolean, IsEnum, IsInt, IsNotEmpty, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class CrearExamenDto {
  @ApiProperty({ description: 'Título del examen', example: 'Parcial de Matemáticas' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  titulo!: string;

  @ApiPropertyOptional({ description: 'Descripción breve del examen' })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiPropertyOptional({ description: 'Instrucciones para los estudiantes' })
  @IsOptional()
  @IsString()
  instrucciones?: string;

  @ApiProperty({ description: 'Modalidad del examen', enum: ModalidadExamen, example: ModalidadExamen.CONTENIDO_COMPLETO })
  @IsEnum(ModalidadExamen)
  modalidad!: ModalidadExamen;

  @ApiProperty({ description: 'Duración en minutos', example: 60 })
  @IsInt()
  @Min(1)
  duracionMinutos!: number;

  @ApiProperty({ description: 'Permite navegar entre preguntas', example: true })
  @IsBoolean()
  permitirNavegacion!: boolean;

  @ApiProperty({ description: 'Muestra puntaje al estudiante al finalizar', example: false })
  @IsBoolean()
  mostrarPuntaje!: boolean;
}
