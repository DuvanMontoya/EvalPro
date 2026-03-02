import { Module } from '@nestjs/common';
import { InstitucionesController } from './Instituciones.controller';
import { InstitucionesService } from './Instituciones.service';

@Module({
  controllers: [InstitucionesController],
  providers: [InstitucionesService],
  exports: [InstitucionesService],
})
export class InstitucionesModule {}
