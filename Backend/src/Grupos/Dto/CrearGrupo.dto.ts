import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class CrearGrupoDto {
  @ApiProperty({ description: 'Nombre del grupo académico' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(150)
  nombre!: string;

  @ApiPropertyOptional({ description: 'Descripción opcional del grupo' })
  @IsOptional()
  @IsString()
  descripcion?: string;

  @ApiProperty({ description: 'Periodo académico asociado' })
  @IsUUID()
  idPeriodo!: string;

  @ApiPropertyOptional({ description: 'Institución objetivo (solo SUPERADMINISTRADOR)' })
  @IsOptional()
  @IsUUID()
  idInstitucion?: string;
}
