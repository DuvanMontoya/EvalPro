import { Module } from '@nestjs/common';
import { GruposController } from './Grupos.controller';
import { GruposService } from './Grupos.service';

@Module({
  controllers: [GruposController],
  providers: [GruposService],
  exports: [GruposService],
})
export class GruposModule {}
