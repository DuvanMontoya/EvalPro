/**
 * @archivo   ReconciliacionIntentos.service.ts
 * @descripcion Reconcilia intentos vencidos por tiempo para mantener estados y monitoreo en tiempo real consistentes.
 * @modulo    Respuestas
 * @autor     EvalPro
 * @fecha     2026-03-05
 */
import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { EstadoIntento, Prisma } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { SesionesExamenGateway } from '../SesionesExamen/SesionesExamen.gateway';
import { CalificacionRespuestasService } from './CalificacionRespuestas.service';

const INTERVALO_CONCILIACION_MS_DEFECTO = 15_000;
const LIMITE_BATCH_CONCILIACION_DEFECTO = 50;

interface IntentoExpiradoPendiente {
  idIntento: string;
  idSesion: string;
  idEstudiante: string;
  preguntasRespondidas: number;
  totalPreguntas: number;
  nombreCompleto: string;
}

@Injectable()
export class ReconciliacionIntentosService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(ReconciliacionIntentosService.name);
  private temporizadorConciliacion: NodeJS.Timeout | null = null;
  private conciliacionEnCurso = false;

  constructor(
    private readonly prisma: PrismaService,
    private readonly calificacionRespuestasService: CalificacionRespuestasService,
    private readonly sesionesGateway: SesionesExamenGateway,
  ) {}

  onModuleInit(): void {
    if (process.env.NODE_ENV === 'test') {
      return;
    }

    const intervaloMs = this.obtenerIntervaloConciliacion();
    this.temporizadorConciliacion = setInterval(() => {
      void this.ejecutarConciliacionProgramada().catch((error) => {
        this.registrarErrorCiclo(error);
      });
    }, intervaloMs);
    this.temporizadorConciliacion.unref?.();

    void this.ejecutarConciliacionProgramada().catch((error) => {
      this.registrarErrorCiclo(error);
    });
  }

  onModuleDestroy(): void {
    if (this.temporizadorConciliacion) {
      clearInterval(this.temporizadorConciliacion);
      this.temporizadorConciliacion = null;
    }
  }

  /**
   * Reconcilia intentos expirados de una sesión concreta.
   * @param idSesion - UUID de sesión a reconciliar.
   * @returns Cantidad de intentos reconciliados.
   */
  async conciliarSesion(idSesion: string): Promise<number> {
    return this.conciliarIntentosExpirados({ idSesion });
  }

  /**
   * Reconcilia intentos expirados globalmente en sesiones activas.
   * @returns Cantidad de intentos reconciliados.
   */
  async conciliarGlobal(): Promise<number> {
    return this.conciliarIntentosExpirados();
  }

  private async ejecutarConciliacionProgramada(): Promise<void> {
    if (this.conciliacionEnCurso) {
      return;
    }

    this.conciliacionEnCurso = true;
    try {
      const limiteBatch = this.obtenerLimiteBatch();
      let totalConciliados = 0;

      while (true) {
        const conciliados = await this.conciliarIntentosExpirados({ limite: limiteBatch });
        totalConciliados += conciliados;
        if (conciliados < limiteBatch) {
          break;
        }
      }

      if (totalConciliados > 0) {
        this.logger.log(`Intentos expirados reconciliados: ${totalConciliados}`);
      }
    } catch (error) {
      this.registrarErrorCiclo(error);
    } finally {
      this.conciliacionEnCurso = false;
    }
  }

  private async conciliarIntentosExpirados({
    idSesion,
    limite,
  }: {
    idSesion?: string;
    limite?: number;
  } = {}): Promise<number> {
    const intentosExpirados = await this.obtenerIntentosExpirados({
      idSesion,
      limite: limite ?? this.obtenerLimiteBatch(),
    });
    if (intentosExpirados.length === 0) {
      return 0;
    }

    let conciliados = 0;
    for (const intento of intentosExpirados) {
      try {
        await this.calificacionRespuestasService.calificarIntento(intento.idIntento);
        this.sesionesGateway.emitirProgreso(intento.idSesion, {
          idIntento: intento.idIntento,
          idEstudiante: intento.idEstudiante,
          preguntasRespondidas: intento.preguntasRespondidas,
          totalPreguntas: intento.totalPreguntas,
          nombreCompleto: intento.nombreCompleto,
          modoKioscoActivo: true,
          eventosFraude: 0,
          estadoIntento: EstadoIntento.ENVIADO,
        });
        conciliados += 1;
      } catch (error) {
        const mensaje = error instanceof Error ? error.message : 'Error desconocido';
        this.logger.warn(`No se pudo reconciliar intento expirado ${intento.idIntento}: ${mensaje}`);
      }
    }

    return conciliados;
  }

  private async obtenerIntentosExpirados({
    idSesion,
    limite,
  }: {
    idSesion?: string;
    limite: number;
  }): Promise<IntentoExpiradoPendiente[]> {
    const filtroSesion = idSesion
      ? Prisma.sql` AND i."sesionId" = ${idSesion}`
      : Prisma.empty;

    const registros = await this.prisma.$queryRaw<IntentoExpiradoPendiente[]>(Prisma.sql`
      SELECT
        i.id AS "idIntento",
        i."sesionId" AS "idSesion",
        i."estudianteId" AS "idEstudiante",
        COALESCE(COUNT(r.id), 0)::int AS "preguntasRespondidas",
        e."totalPreguntas"::int AS "totalPreguntas",
        TRIM(CONCAT(u.nombre, ' ', u.apellidos)) AS "nombreCompleto"
      FROM "intentos_examen" i
      INNER JOIN "sesiones_examen" s
        ON s.id = i."sesionId"
      INNER JOIN "examenes" e
        ON e.id = s."examenId"
      INNER JOIN "usuarios" u
        ON u.id = i."estudianteId"
      LEFT JOIN "respuestas" r
        ON r."intentoId" = i.id
      WHERE s.estado::text = 'ACTIVA'
        AND i.estado::text IN ('INICIADO', 'REANUDADO')
        AND e."duracionMinutos" > 0
        AND i."fechaInicio" + (e."duracionMinutos" * INTERVAL '1 minute') <= NOW()
        ${filtroSesion}
      GROUP BY i.id, i."sesionId", i."estudianteId", e."totalPreguntas", u.nombre, u.apellidos, i."fechaInicio"
      ORDER BY i."fechaInicio" ASC
      LIMIT ${limite}
    `);

    return registros;
  }

  private obtenerIntervaloConciliacion(): number {
    const valor = Number.parseInt(process.env.INTERVALO_CONCILIACION_INTENTOS_MS ?? '', 10);
    if (Number.isFinite(valor) && valor >= 5_000) {
      return valor;
    }
    return INTERVALO_CONCILIACION_MS_DEFECTO;
  }

  private obtenerLimiteBatch(): number {
    const valor = Number.parseInt(process.env.LIMITE_BATCH_CONCILIACION_INTENTOS ?? '', 10);
    if (Number.isFinite(valor) && valor > 0) {
      return valor;
    }
    return LIMITE_BATCH_CONCILIACION_DEFECTO;
  }

  private registrarErrorCiclo(error: unknown): void {
    if (error instanceof Error) {
      this.logger.error(`Error en ciclo de reconciliación: ${error.message}`, error.stack);
      return;
    }
    this.logger.error('Error en ciclo de reconciliación: desconocido');
  }
}
