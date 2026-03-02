/**
 * @archivo   ReporteEstudiante.dto.ts
 * @descripcion Define el contrato de salida para el resumen histórico de un estudiante.
 * @modulo    Reportes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { EstadoIntento } from '@prisma/client';

class SesionEstudianteDto {
  @ApiProperty()
  idSesion!: string;

  @ApiProperty()
  codigoAcceso!: string;

  @ApiProperty()
  tituloExamen!: string;

  @ApiProperty({ enum: EstadoIntento })
  estado!: EstadoIntento;

  @ApiProperty({ nullable: true })
  puntajeObtenido!: number | null;

  @ApiProperty({ nullable: true })
  porcentaje!: number | null;

  @ApiProperty()
  esSospechoso!: boolean;
}

export class ReporteEstudianteDto {
  @ApiProperty()
  idEstudiante!: string;

  @ApiProperty()
  nombreCompleto!: string;

  @ApiProperty({ type: [SesionEstudianteDto] })
  intentos!: SesionEstudianteDto[];
}
