/**
 * @archivo   Autenticacion.module.ts
 * @descripcion Configura proveedores de autenticación, estrategias JWT y endpoints asociados.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigService } from '@nestjs/config';
import { AutenticacionController } from './Autenticacion.controller';
import { AutenticacionService } from './Autenticacion.service';
import { JwtAccesoEstrategia } from './Estrategias/JwtAcceso.estrategia';
import { JwtRefreshEstrategia } from './Estrategias/JwtRefresh.estrategia';

@Module({
  imports: [
    PassportModule,
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (servicioConfiguracion: ConfigService) => ({
        secret: servicioConfiguracion.get<string>('JWT_SECRETO_ACCESO', ''),
        signOptions: { expiresIn: servicioConfiguracion.get<string>('JWT_EXPIRACION_ACCESO', '15m') },
      }),
    }),
  ],
  controllers: [AutenticacionController],
  providers: [AutenticacionService, JwtAccesoEstrategia, JwtRefreshEstrategia],
  exports: [AutenticacionService],
})
export class AutenticacionModule {}
