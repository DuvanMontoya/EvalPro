import { Injectable, Logger } from '@nestjs/common';
import { RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';

export interface RegistroAuditoriaEntrada {
  idInstitucion?: string | null;
  idActor?: string | null;
  rolActor?: RolUsuario | null;
  accion: string;
  recurso: string;
  idRecurso?: string | null;
  snapshotAntes?: unknown;
  snapshotDespues?: unknown;
  ip?: string | null;
  userAgent?: string | null;
  resultado?: 'EXITO' | 'FALLO';
  razonFallo?: string | null;
  timestamp?: Date;
}

@Injectable()
export class AuditoriaService {
  private readonly logger = new Logger(AuditoriaService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Persiste un registro de auditoría append-only para trazabilidad forense.
   * Si el almacenamiento falla se propaga excepción para mantener el sistema fail-closed.
   */
  async registrar(entrada: RegistroAuditoriaEntrada): Promise<void> {
    try {
      await this.prisma.auditoriaAccion.create({
        data: {
          idInstitucion: entrada.idInstitucion ?? null,
          idActor: entrada.idActor ?? null,
          rolActor: entrada.rolActor ?? null,
          accion: entrada.accion,
          recurso: entrada.recurso,
          idRecurso: entrada.idRecurso ?? null,
          snapshotAntes: entrada.snapshotAntes as object | undefined,
          snapshotDespues: entrada.snapshotDespues as object | undefined,
          ip: entrada.ip ?? null,
          userAgent: entrada.userAgent ?? null,
          resultado: entrada.resultado ?? 'EXITO',
          razonFallo: entrada.razonFallo ?? null,
          timestamp: entrada.timestamp ?? new Date(),
        },
      });
    } catch (error) {
      this.logger.error('No fue posible persistir registro de auditoria', error as Error);
      throw error;
    }
  }
}
