import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, Max, Min, ValidateNested } from 'class-validator';

class ConfiguracionAntifraudeRedDto {
  @ApiProperty({ description: 'Ventana temporal para análisis de red (segundos)', minimum: 30, maximum: 3600 })
  @IsInt()
  @Min(30)
  @Max(3600)
  ventanaSegundos!: number;

  @ApiProperty({ description: 'Máximo de reconexiones permitidas en la ventana', minimum: 1, maximum: 30 })
  @IsInt()
  @Min(1)
  @Max(30)
  maxReconexionesVentana!: number;

  @ApiProperty({ description: 'Máximo de cambios de tipo de red permitidos en la ventana', minimum: 1, maximum: 30 })
  @IsInt()
  @Min(1)
  @Max(30)
  maxCambiosTipoRedVentana!: number;

  @ApiProperty({ description: 'Duración máxima de desconexión tolerada (segundos)', minimum: 5, maximum: 900 })
  @IsInt()
  @Min(5)
  @Max(900)
  maxTiempoOfflineSegundos!: number;

  @ApiProperty({ description: 'Incremento de riesgo por reconexiones anómalas', minimum: 1, maximum: 50 })
  @IsInt()
  @Min(1)
  @Max(50)
  riesgoPorReconexion!: number;

  @ApiProperty({ description: 'Incremento de riesgo por cambios de tipo de red anómalos', minimum: 1, maximum: 50 })
  @IsInt()
  @Min(1)
  @Max(50)
  riesgoPorCambioTipoRed!: number;

  @ApiProperty({ description: 'Incremento de riesgo por desconexiones prolongadas', minimum: 1, maximum: 50 })
  @IsInt()
  @Min(1)
  @Max(50)
  riesgoPorOfflineExtenso!: number;

  @ApiProperty({ description: 'Umbral de riesgo para marcar intento sospechoso', minimum: 0, maximum: 100 })
  @IsInt()
  @Min(0)
  @Max(100)
  umbralRiesgoSospechoso!: number;

  @ApiProperty({ description: 'Umbral de riesgo para alerta crítica', minimum: 1, maximum: 100 })
  @IsInt()
  @Min(1)
  @Max(100)
  umbralRiesgoCritico!: number;
}

export class ActualizarConfiguracionAntifraudeDto {
  @ApiProperty({ type: ConfiguracionAntifraudeRedDto })
  @ValidateNested()
  @Type(() => ConfiguracionAntifraudeRedDto)
  red!: ConfiguracionAntifraudeRedDto;
}
