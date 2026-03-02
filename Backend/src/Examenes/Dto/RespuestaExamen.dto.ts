/**
 * @archivo   RespuestaExamen.dto.ts
 * @descripcion Estructura los datos de examen que se retornan al cliente.
 * @modulo    Examenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { EstadoExamen, ModalidadExamen } from '@prisma/client';

export class RespuestaExamenDto {
  @ApiProperty({ description: 'Identificador del examen' })
  id!: string;

  @ApiProperty({ description: 'Título del examen' })
  titulo!: string;

  @ApiProperty({ description: 'Estado actual del examen', enum: EstadoExamen })
  estado!: EstadoExamen;

  @ApiProperty({ description: 'Modalidad del examen', enum: ModalidadExamen })
  modalidad!: ModalidadExamen;

  @ApiProperty({ description: 'Total de preguntas configuradas' })
  totalPreguntas!: number;

  @ApiProperty({ description: 'Puntaje máximo acumulado' })
  puntajeMaximo!: number;

  @ApiProperty({ description: 'Identificador del docente propietario' })
  creadoPorId!: string;
}
