import { Module } from '@nestjs/common';
import { ReclamosController } from './Reclamos.controller';
import { ReclamosService } from './Reclamos.service';

@Module({
  controllers: [ReclamosController],
  providers: [ReclamosService],
  exports: [ReclamosService],
})
export class ReclamosModule {}
