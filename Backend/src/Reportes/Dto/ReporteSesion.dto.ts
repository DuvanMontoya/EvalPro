/**
 * @archivo   ReporteSesion.dto.ts
 * @descripcion Define el contrato de salida para reportes agregados por sesión.
 * @modulo    Reportes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { EstadoIntento } from '@prisma/client';

class DistribucionPuntajeDto {
  @ApiProperty()
  rango!: string;

  @ApiProperty()
  cantidad!: number;
}

class DificultadPreguntaDto {
  @ApiProperty()
  idPregunta!: string;

  @ApiProperty()
  enunciado!: string;

  @ApiProperty()
  porcentajeAcierto!: number;
}

class EstudianteSesionDto {
  @ApiProperty()
  nombre!: string;

  @ApiProperty()
  apellidos!: string;

  @ApiProperty({ nullable: true })
  puntaje!: number | null;

  @ApiProperty({ nullable: true })
  porcentaje!: number | null;

  @ApiProperty({ enum: EstadoIntento })
  estado!: EstadoIntento;

  @ApiProperty()
  esSospechoso!: boolean;
}

export class ReporteSesionDto {
  @ApiProperty()
  sesion!: Record<string, unknown>;

  @ApiProperty()
  totalEstudiantes!: number;

  @ApiProperty()
  estudiantesQueEnviaron!: number;

  @ApiProperty()
  estudiantesSospechosos!: number;

  @ApiProperty({ nullable: true })
  puntajePromedio!: number | null;

  @ApiProperty({ nullable: true })
  puntajeMaximo!: number | null;

  @ApiProperty({ nullable: true })
  puntajeMinimo!: number | null;

  @ApiProperty({ type: [DistribucionPuntajeDto] })
  distribucionPuntajes!: DistribucionPuntajeDto[];

  @ApiProperty({ type: [DificultadPreguntaDto] })
  dificultadPorPregunta!: DificultadPreguntaDto[];

  @ApiProperty({ type: [EstudianteSesionDto] })
  listaEstudiantes!: EstudianteSesionDto[];
}
