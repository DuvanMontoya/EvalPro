import { Module } from '@nestjs/common';
import { AuditoriaService } from './Auditoria.service';

@Module({
  providers: [AuditoriaService],
  exports: [AuditoriaService],
})
export class AuditoriaModule {}
