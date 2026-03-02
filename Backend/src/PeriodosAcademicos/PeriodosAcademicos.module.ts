import { Module } from '@nestjs/common';
import { PeriodosAcademicosController } from './PeriodosAcademicos.controller';
import { PeriodosAcademicosService } from './PeriodosAcademicos.service';

@Module({
  controllers: [PeriodosAcademicosController],
  providers: [PeriodosAcademicosService],
  exports: [PeriodosAcademicosService],
})
export class PeriodosAcademicosModule {}

