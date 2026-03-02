/**
 * @archivo   Examenes.module.ts
 * @descripcion Declara el módulo de exámenes y exporta su servicio para otros dominios.
 * @modulo    Examenes
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module } from '@nestjs/common';
import { ExamenesController } from './Examenes.controller';
import { ExamenesService } from './Examenes.service';

@Module({
  controllers: [ExamenesController],
  providers: [ExamenesService],
  exports: [ExamenesService],
})
export class ExamenesModule {}
