/**
 * @archivo   Preguntas.module.ts
 * @descripcion Declara componentes del módulo de preguntas.
 * @modulo    Preguntas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module } from '@nestjs/common';
import { PreguntasController } from './Preguntas.controller';
import { PreguntasService } from './Preguntas.service';

@Module({
  controllers: [PreguntasController],
  providers: [PreguntasService],
  exports: [PreguntasService],
})
export class PreguntasModule {}
