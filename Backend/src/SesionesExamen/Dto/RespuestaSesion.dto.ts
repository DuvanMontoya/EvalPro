/**
 * @archivo   RespuestaSesion.dto.ts
 * @descripcion Estructura datos de sesión devueltos por el backend.
 * @modulo    SesionesExamen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { EstadoSesion } from '@prisma/client';

export class RespuestaSesionDto {
  @ApiProperty({ description: 'ID de la sesión' })
  id!: string;

  @ApiProperty({ description: 'Código de acceso de la sesión' })
  codigoAcceso!: string;

  @ApiProperty({ description: 'Estado operativo de la sesión', enum: EstadoSesion })
  estado!: EstadoSesion;

  @ApiProperty({ description: 'Fecha de inicio de la sesión', nullable: true })
  fechaInicio!: Date | null;

  @ApiProperty({ description: 'Fecha de cierre de la sesión', nullable: true })
  fechaFin!: Date | null;

  @ApiProperty({ description: 'ID del examen asociado' })
  examenId!: string;
}
