import { ApiProperty } from '@nestjs/swagger';
import { EstadoInstitucion } from '@prisma/client';
import { IsEnum, IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CambiarEstadoInstitucionDto {
  @ApiProperty({ enum: EstadoInstitucion, description: 'Nuevo estado de la institución' })
  @IsEnum(EstadoInstitucion)
  estado!: EstadoInstitucion;

  @ApiProperty({ description: 'Razón del cambio de estado' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  razon!: string;
}
