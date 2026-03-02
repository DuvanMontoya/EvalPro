import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsObject, IsOptional, IsString, MaxLength } from 'class-validator';

export class CrearInstitucionDto {
  @ApiProperty({ description: 'Nombre único de la institución' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  nombre!: string;

  @ApiPropertyOptional({ description: 'Dominio institucional opcional (para SSO)' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  dominio?: string;

  @ApiPropertyOptional({ description: 'Configuración JSON de políticas de la institución' })
  @IsOptional()
  @IsObject()
  configuracion?: Record<string, unknown>;
}
