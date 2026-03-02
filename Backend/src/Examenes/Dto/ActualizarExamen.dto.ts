/**
 * @archivo   ActualizarExamen.dto.ts
 * @descripcion Permite actualizar de forma parcial los datos de un examen.
 * @modulo    Examenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { PartialType } from '@nestjs/swagger';
import { CrearExamenDto } from './CrearExamen.dto';

export class ActualizarExamenDto extends PartialType(CrearExamenDto) {}
