import { Module } from '@nestjs/common';
import { AsignacionesController } from './Asignaciones.controller';
import { AsignacionesService } from './Asignaciones.service';

@Module({
  controllers: [AsignacionesController],
  providers: [AsignacionesService],
  exports: [AsignacionesService],
})
export class AsignacionesModule {}
