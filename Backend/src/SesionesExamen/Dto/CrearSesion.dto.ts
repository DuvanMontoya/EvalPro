/**
 * @archivo   CrearSesion.dto.ts
 * @descripcion Valida datos requeridos para crear una sesión de examen.
 * @modulo    SesionesExamen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class CrearSesionDto {
  @ApiProperty({ description: 'ID del examen publicado para la sesión' })
  @IsUUID()
  @IsNotEmpty()
  idExamen!: string;

  @ApiPropertyOptional({ description: 'Descripción breve de la sesión' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  descripcion?: string;
}
