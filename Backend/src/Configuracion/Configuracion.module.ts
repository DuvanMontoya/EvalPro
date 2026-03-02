/**
 * @archivo   Configuracion.module.ts
 * @descripcion Declara configuración global de entorno y proveedores compartidos de infraestructura.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Global, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaService } from './BaseDatos.config';

@Global()
@Module({
  imports: [ConfigModule.forRoot({ isGlobal: true })],
  providers: [PrismaService],
  exports: [ConfigModule, PrismaService],
})
export class ConfiguracionModule {}
