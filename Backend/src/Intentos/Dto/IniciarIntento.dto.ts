/**
 * @archivo   IniciarIntento.dto.ts
 * @descripcion Valida la solicitud de creación de intento para un estudiante.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class IniciarIntentoDto {
  @ApiProperty({ description: 'ID de la sesión de examen a la que se unirá el estudiante' })
  @IsUUID()
  @IsNotEmpty()
  idSesion!: string;

  @ApiPropertyOptional({ description: 'Dirección IP del dispositivo' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  ipDispositivo?: string;

  @ApiPropertyOptional({ description: 'Modelo del dispositivo del estudiante' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  modeloDispositivo?: string;

  @ApiPropertyOptional({ description: 'Sistema operativo del dispositivo' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  sistemaOperativo?: string;

  @ApiPropertyOptional({ description: 'Versión de la aplicación móvil' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  versionApp?: string;
}
