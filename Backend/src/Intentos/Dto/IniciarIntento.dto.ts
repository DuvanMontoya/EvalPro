/**
 * @archivo   IniciarIntento.dto.ts
 * @descripcion Valida la solicitud de creación de intento para un estudiante.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';

export class IntegridadDispositivoIntentoDto {
  @ApiProperty({ description: 'Plataforma del dispositivo (ANDROID, IOS, etc.)' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(20)
  plataforma!: string;

  @ApiPropertyOptional({ description: 'Indica si se detectó root/jailbreak' })
  @IsOptional()
  @IsBoolean()
  rootDetectado?: boolean;

  @ApiPropertyOptional({ description: 'Indica si la app corre en modo depurable' })
  @IsOptional()
  @IsBoolean()
  appDepurable?: boolean;

  @ApiPropertyOptional({ description: 'Indica si opciones de desarrollador están activas' })
  @IsOptional()
  @IsBoolean()
  opcionesDesarrolladorActivas?: boolean;

  @ApiPropertyOptional({ description: 'Indica si ADB/depuración USB está activo' })
  @IsOptional()
  @IsBoolean()
  adbActivo?: boolean;

  @ApiPropertyOptional({ description: 'Indica si el dispositivo es emulador' })
  @IsOptional()
  @IsBoolean()
  emuladorDetectado?: boolean;

  @ApiPropertyOptional({ description: 'Indica si lock task está permitido para la app' })
  @IsOptional()
  @IsBoolean()
  lockTaskPermitido?: boolean;

  @ApiPropertyOptional({ description: 'Indica si lock task está activo al iniciar el intento' })
  @IsOptional()
  @IsBoolean()
  lockTaskActivo?: boolean;

  @ApiPropertyOptional({ description: 'Indica si la app es Device Owner' })
  @IsOptional()
  @IsBoolean()
  dispositivoPropietario?: boolean;

  @ApiPropertyOptional({ description: 'Indica disponibilidad de bloqueo estricto en el dispositivo' })
  @IsOptional()
  @IsBoolean()
  bloqueoEstrictoDisponible?: boolean;

  @ApiPropertyOptional({ description: 'Indica si el bloqueo estricto estaba activo al iniciar' })
  @IsOptional()
  @IsBoolean()
  bloqueoEstrictoActivo?: boolean;

  @ApiPropertyOptional({ description: 'Puntaje local de integridad calculado por cliente (0-100)' })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  puntajeIntegridad?: number;

  @ApiPropertyOptional({ description: 'Razones de riesgo detectadas localmente' })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20)
  @IsString({ each: true })
  razonesRiesgo?: string[];

  @ApiPropertyOptional({ description: 'Marca de tiempo ISO del reporte de integridad' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  timestamp?: string;
}

export class IniciarIntentoDto {
  @ApiProperty({ description: 'ID de la sesión de examen a la que se unirá el estudiante' })
  @IsUUID()
  @IsNotEmpty()
  idSesion!: string;

  @ApiProperty({ description: 'Código de acceso vigente de la sesión' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(9)
  codigoAcceso!: string;

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

  @ApiPropertyOptional({ description: 'Reporte de integridad del dispositivo al iniciar intento', type: IntegridadDispositivoIntentoDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => IntegridadDispositivoIntentoDto)
  integridadDispositivo?: IntegridadDispositivoIntentoDto;
}
