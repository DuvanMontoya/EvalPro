/**
 * @archivo   RespuestaIntento.dto.ts
 * @descripcion Estructura la respuesta pública de un intento de examen.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { EstadoIntento } from '@prisma/client';

export class RespuestaIntentoDto {
  @ApiProperty({ description: 'ID del intento' })
  id!: string;

  @ApiProperty({ description: 'Estado actual del intento', enum: EstadoIntento })
  estado!: EstadoIntento;

  @ApiProperty({ description: 'ID de la sesión asociada' })
  sesionId!: string;

  @ApiProperty({ description: 'ID del estudiante propietario' })
  estudianteId!: string;

  @ApiProperty({ description: 'Fecha de inicio del intento' })
  fechaInicio!: Date;
}
