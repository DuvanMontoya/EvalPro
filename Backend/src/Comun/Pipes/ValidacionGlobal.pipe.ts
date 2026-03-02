/**
 * @archivo   ValidacionGlobal.pipe.ts
 * @descripcion Aplica validación estricta de DTOs con transformación automática de tipos.
 * @modulo    Comun
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Injectable, ValidationPipe } from '@nestjs/common';

@Injectable()
export class ValidacionGlobalPipe extends ValidationPipe {
  constructor() {
    super({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    });
  }
}
