/**
 * @archivo   SincronizarRespuestas.dto.ts
 * @descripcion Agrupa respuestas para sincronización batch idempotente.
 * @modulo    Respuestas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsArray, IsNotEmpty, IsUUID, ValidateNested } from 'class-validator';
import { EntradaRespuestaDto } from './EntradaRespuesta.dto';

export class SincronizarRespuestasDto {
  @ApiProperty({ description: 'ID del intento al que pertenecen las respuestas' })
  @IsUUID()
  idIntento!: string;

  @ApiProperty({ description: 'Arreglo de respuestas a sincronizar', type: [EntradaRespuestaDto] })
  @IsArray()
  @IsNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => EntradaRespuestaDto)
  respuestas!: EntradaRespuestaDto[];
}
