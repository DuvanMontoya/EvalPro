import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsDateString, IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class CrearPeriodoAcademicoDto {
  @ApiProperty({ description: 'Nombre del periodo académico', example: '2026-1' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  nombre!: string;

  @ApiProperty({ description: 'Fecha de inicio en formato ISO' })
  @IsDateString()
  fechaInicio!: string;

  @ApiProperty({ description: 'Fecha de fin en formato ISO' })
  @IsDateString()
  fechaFin!: string;

  @ApiPropertyOptional({ description: 'Marca si el periodo queda activo al crearse', default: true })
  @IsOptional()
  @IsBoolean()
  activo?: boolean;

  @ApiPropertyOptional({ description: 'Institución objetivo (solo SUPERADMINISTRADOR)' })
  @IsOptional()
  @IsUUID()
  idInstitucion?: string;
}

