import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean } from 'class-validator';

export class ActualizarEstadoPeriodoDto {
  @ApiProperty({ description: 'Estado activo del periodo académico' })
  @IsBoolean()
  activo!: boolean;
}

