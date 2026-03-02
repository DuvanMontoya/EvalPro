import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { EstadoGrupo } from '@prisma/client';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class CambiarEstadoGrupoDto {
  @ApiProperty({ enum: EstadoGrupo, description: 'Nuevo estado del grupo académico' })
  @IsEnum(EstadoGrupo)
  estado!: EstadoGrupo;

  @ApiPropertyOptional({ description: 'Razón del cambio de estado' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  razon?: string;
}
