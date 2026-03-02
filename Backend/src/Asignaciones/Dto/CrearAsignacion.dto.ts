import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsDateString, IsInt, IsOptional, IsUUID, Max, Min } from 'class-validator';

export class CrearAsignacionDto {
  @ApiProperty({ description: 'Examen publicado y propiedad del docente' })
  @IsUUID()
  idExamen!: string;

  @ApiPropertyOptional({ description: 'Grupo objetivo (XOR con idEstudiante)' })
  @IsOptional()
  @IsUUID()
  idGrupo?: string;

  @ApiPropertyOptional({ description: 'Estudiante objetivo individual (XOR con idGrupo)' })
  @IsOptional()
  @IsUUID()
  idEstudiante?: string;

  @ApiProperty({ description: 'Fecha/hora de inicio en UTC' })
  @IsDateString()
  fechaInicio!: string;

  @ApiProperty({ description: 'Fecha/hora de cierre en UTC (debe ser mayor a inicio)' })
  @IsDateString()
  fechaFin!: string;

  @ApiProperty({ description: 'Máximo de intentos permitidos. 0 = ilimitado' })
  @IsInt()
  @Min(0)
  @Max(20)
  intentosMaximos!: number;

  @ApiProperty({ description: 'Si se muestra puntaje inmediatamente al enviar' })
  @IsBoolean()
  mostrarPuntajeInmediato!: boolean;

  @ApiProperty({ description: 'Si se muestran respuestas correctas tras cierre' })
  @IsBoolean()
  mostrarRespuestasCorrectas!: boolean;

  @ApiPropertyOptional({ description: 'Fecha de publicación de resultados' })
  @IsOptional()
  @IsDateString()
  publicarResultadosEn?: string;
}
