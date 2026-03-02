/**
 * @archivo   Usuarios.module.ts
 * @descripcion Agrupa controlador y servicio del dominio de usuarios.
 * @modulo    Usuarios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module } from '@nestjs/common';
import { UsuariosController } from './Usuarios.controller';
import { UsuariosService } from './Usuarios.service';

@Module({
  controllers: [UsuariosController],
  providers: [UsuariosService],
  exports: [UsuariosService],
})
export class UsuariosModule {}
