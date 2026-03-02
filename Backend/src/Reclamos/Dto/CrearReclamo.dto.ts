import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class CrearReclamoDto {
  @ApiPropertyOptional({ description: 'Pregunta específica del reclamo (opcional)' })
  @IsOptional()
  @IsUUID()
  idPregunta?: string;

  @ApiProperty({ description: 'Motivo detallado del reclamo' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(1000)
  motivo!: string;
}
