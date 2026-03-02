/**
 * @archivo   BaseDatos.config.ts
 * @descripcion Implementa el servicio de Prisma para acceso transaccional a PostgreSQL.
 * @modulo    Configuracion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { INestApplication, Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  /**
   * Establece conexión de Prisma al iniciar el módulo.
   */
  async onModuleInit(): Promise<void> {
    await this.$connect();
  }

  /**
   * Cierra conexión de Prisma al destruir el módulo.
   */
  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }

  /**
   * Registra cierre limpio de Prisma cuando la aplicación termina.
   * @param aplicacion - Instancia principal de NestJS
   */
  async habilitarApagado(aplicacion: INestApplication): Promise<void> {
    process.on('beforeExit', async () => {
      await aplicacion.close();
    });
  }
}
