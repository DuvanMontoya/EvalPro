/**
 * @archivo   ActualizarPregunta.dto.ts
 * @descripcion Permite actualizar parcialmente una pregunta existente.
 * @modulo    Preguntas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { PartialType } from '@nestjs/swagger';
import { CrearPreguntaDto } from './CrearPregunta.dto';

export class ActualizarPreguntaDto extends PartialType(CrearPreguntaDto) {}
