/**
 * @archivo   ResultadoFinal.dto.ts
 * @descripcion Estructura resultado final de un intento después de calificarlo.
 * @modulo    Respuestas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';

export class ResultadoFinalDto {
  @ApiProperty({ description: 'ID del intento finalizado' })
  idIntento!: string;

  @ApiProperty({ description: 'Indica si el examen permite mostrar puntaje al estudiante' })
  mostrarPuntaje!: boolean;

  @ApiProperty({ description: 'Puntaje obtenido', nullable: true })
  puntajeObtenido!: number | null;

  @ApiProperty({ description: 'Porcentaje alcanzado', nullable: true })
  porcentaje!: number | null;
}
