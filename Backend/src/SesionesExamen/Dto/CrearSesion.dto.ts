/**
 * @archivo   CrearSesion.dto.ts
 * @descripcion Valida datos requeridos para crear una sesión de examen.
 * @modulo    SesionesExamen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class CrearSesionDto {
  @ApiPropertyOptional({ description: 'ID del examen publicado para la sesión (legacy)' })
  @IsOptional()
  @IsUUID()
  idExamen?: string;

  @ApiPropertyOptional({ description: 'ID de asignación de examen (canónico)' })
  @IsOptional()
  @IsUUID()
  idAsignacion?: string;

  @ApiPropertyOptional({ description: 'Descripción breve de la sesión' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  descripcion?: string;
}
