/**
 * @archivo   Telemetria.service.ts
 * @descripcion Registra eventos de telemetría y detecta patrones sospechosos de fraude.
 * @modulo    Telemetria
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ForbiddenException, Inject, Injectable, NotFoundException, forwardRef } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma, RolUsuario, TipoEventoTelemetria } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { esEventoFraudeCritico, tiempoSospechoso } from '../Comun/Utilidades/ValidadorTelemetria.util';
import { RegistrarEventoDto } from './Dto/RegistrarEvento.dto';
import { SesionesExamenGateway } from '../SesionesExamen/SesionesExamen.gateway';

@Injectable()
export class TelemetriaService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly servicioConfiguracion: ConfigService,
    @Inject(forwardRef(() => SesionesExamenGateway))
    private readonly sesionesGateway: SesionesExamenGateway,
  ) {}

  /**
   * Registra un evento de telemetría y marca fraude inmediato cuando corresponde.
   * @param dto - Datos del evento a persistir.
   * @param idIntento - UUID del intento propietario.
   */
  async registrar(dto: RegistrarEventoDto, idIntento: string) {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: idIntento } });
    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }

    const evento = await this.prisma.eventoTelemetria.create({
      data: {
        intentoId: idIntento,
        tipo: dto.tipo,
        descripcion: dto.descripcion,
        metadatos: dto.metadatos as Prisma.InputJsonValue | undefined,
        numeroPregunta: dto.numeroPregunta,
        tiempoTranscurrido: dto.tiempoTranscurrido,
      },
    });

    if (esEventoFraudeCritico(dto.tipo)) {
      this.sesionesGateway.emitirFraude(intento.sesionId, {
        idIntento,
        tipoEvento: dto.tipo,
      });

      const razonBase = intento.razonSospecha ? `${intento.razonSospecha}; ` : '';
      await this.prisma.intentoExamen.update({
        where: { id: idIntento },
        data: {
          esSospechoso: true,
          razonSospecha: `${razonBase}${dto.descripcion ?? dto.tipo}`,
        },
      });
    }

    return evento;
  }

  /**
   * Detecta anomalías por exceso de eventos y tiempo total anómalo del intento.
   * @param idIntento - UUID del intento a evaluar.
   */
  async detectarAnomalias(idIntento: string): Promise<void> {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: {
        eventosTelemetria: true,
        sesion: { include: { examen: true } },
      },
    });

    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }

    const eventosFoco = intento.eventosTelemetria.filter(
      (evento) =>
        evento.tipo === TipoEventoTelemetria.APLICACION_EN_SEGUNDO_PLANO ||
        evento.tipo === TipoEventoTelemetria.PANTALLA_ABANDONADA,
    ).length;

    const maxEventos = Number(this.servicioConfiguracion.get<string>('TELEMETRIA_MAX_EVENTOS_SEGUNDO_PLANO', '0'));
    const segundosMinimos = Number(this.servicioConfiguracion.get<string>('TELEMETRIA_SEGUNDOS_MINIMOS_POR_PREGUNTA', '3'));

    const referenciaFin = intento.fechaEnvio ?? new Date();
    const tiempoTotalSegundos = Math.max(0, Math.floor((referenciaFin.getTime() - intento.fechaInicio.getTime()) / 1000));

    const razones: string[] = [];
    if (eventosFoco > maxEventos) {
      razones.push(`Exceso de eventos de segundo plano/abandono: ${eventosFoco}`);
    }

    if (tiempoSospechoso(tiempoTotalSegundos, intento.sesion.examen.totalPreguntas, segundosMinimos)) {
      razones.push('Tiempo total inferior al umbral mínimo esperado');
    }

    if (razones.length > 0) {
      const razonActual = intento.razonSospecha ? `${intento.razonSospecha}; ` : '';
      await this.prisma.intentoExamen.update({
        where: { id: idIntento },
        data: {
          esSospechoso: true,
          razonSospecha: `${razonActual}${razones.join('; ')}`,
        },
      });
    }
  }

  /**
   * Lista eventos de telemetría con validación de acceso por rol.
   * @param idIntento - UUID del intento consultado.
   * @param rol - Rol del usuario solicitante.
   * @param idUsuario - UUID del usuario solicitante.
   */
  async listarPorIntento(idIntento: string, rol: RolUsuario, idUsuario: string) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: { sesion: true },
    });

    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }

    if (rol === RolUsuario.DOCENTE && intento.sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }

    return this.prisma.eventoTelemetria.findMany({
      where: { intentoId: idIntento },
      orderBy: { fechaEvento: 'asc' },
    });
  }
}
