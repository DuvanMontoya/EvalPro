import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsNumber, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class ResolverReclamoDto {
  @ApiProperty({ description: 'Indica si el reclamo fue aprobado' })
  @IsBoolean()
  aprobar!: boolean;

  @ApiProperty({ description: 'Resolución argumentada del reclamo' })
  @IsString()
  @MaxLength(1000)
  resolucion!: string;

  @ApiPropertyOptional({ description: 'Nuevo puntaje total si el reclamo se aprueba' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  puntajeNuevo?: number;
}
