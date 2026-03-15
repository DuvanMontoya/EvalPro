/**
 * @archivo   Telemetria.service.ts
 * @descripcion Consolida el registro de eventos del intento sobre el modelo canónico EventoIntento.
 * @modulo    Telemetria
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { ForbiddenException, Inject, Injectable, NotFoundException, forwardRef } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma, RolUsuario, SeveridadEvento, TipoEventoIntento } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { tiempoSospechoso } from '../Comun/Utilidades/ValidadorTelemetria.util';
import { RegistrarEventoDto } from './Dto/RegistrarEvento.dto';
import { SesionesExamenGateway } from '../SesionesExamen/SesionesExamen.gateway';

@Injectable()
export class TelemetriaService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
    @Inject(forwardRef(() => SesionesExamenGateway))
    private readonly sesionesGateway: SesionesExamenGateway,
  ) {}

  async registrar(dto: RegistrarEventoDto, idEstudiante: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: dto.idIntento } });
    if (!intento) throw new NotFoundException('Intento no encontrado');
    if (intento.idInstitucion !== idInstitucion) throw new ForbiddenException('No puede registrar eventos fuera de su institución');
    if (intento.estudianteId !== idEstudiante) throw new ForbiddenException('No tiene permisos sobre este intento');

    const evento = await this.registrarEventoIntento(this.prisma, {
      idIntento: dto.idIntento,
      tipo: dto.tipo,
      descripcion: dto.descripcion,
      numeroPregunta: dto.numeroPregunta,
      tiempoTranscurrido: dto.tiempoTranscurrido,
      metadatos: dto.metadatos,
      severidad: this.resolverSeveridadBase(dto.tipo),
    });

    if (dto.tipo === TipoEventoIntento.APP_EN_BACKGROUND || dto.tipo === TipoEventoIntento.INCIDENTE_REGISTRADO) {
      const razonEvento = dto.descripcion?.trim() || dto.tipo;
      const razonAcumulada = intento.razonSospecha ? `${intento.razonSospecha}; ${razonEvento}` : razonEvento;
      this.sesionesGateway.emitirFraude(intento.sesionId, { idIntento: dto.idIntento, tipoEvento: dto.tipo });
      await this.prisma.intentoExamen.update({
        where: { id: dto.idIntento },
        data: {
          esSospechoso: true,
          requiereRevision: true,
          indiceRiesgoFraude: { increment: 10 },
          razonSospecha: razonAcumulada,
        },
      });
    }

    return evento;
  }

  async detectarAnomalias(idIntento: string): Promise<void> {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: {
        eventosIntento: true,
        sesion: { include: { examen: true } },
      },
    });
    if (!intento) throw new NotFoundException('Intento no encontrado');

    const eventosFoco = intento.eventosIntento.filter((evento) => evento.tipo === TipoEventoIntento.APP_EN_BACKGROUND).length;
    const maxEventos = Number(this.configService.get<string>('TELEMETRIA_MAX_EVENTOS_SEGUNDO_PLANO', '0'));
    const segundosMinimos = Number(this.configService.get<string>('TELEMETRIA_SEGUNDOS_MINIMOS_POR_PREGUNTA', '3'));
    const referenciaFin = intento.fechaEnvio ?? new Date();
    const tiempoTotalSegundos = Math.max(0, Math.floor((referenciaFin.getTime() - intento.fechaInicio.getTime()) / 1000));

    const razones: string[] = [];
    if (eventosFoco > maxEventos) razones.push(`Exceso de eventos de segundo plano: ${eventosFoco}`);
    if (tiempoSospechoso(tiempoTotalSegundos, intento.sesion.examen.totalPreguntas, segundosMinimos)) {
      razones.push('Tiempo total inferior al umbral mínimo esperado');
    }
    if (razones.length === 0) return;

    const razonBase = intento.razonSospecha ? `${intento.razonSospecha}; ` : '';
    await this.prisma.intentoExamen.update({
      where: { id: idIntento },
      data: {
        esSospechoso: true,
        requiereRevision: true,
        indiceRiesgoFraude: { increment: 20 },
        razonSospecha: `${razonBase}${razones.join('; ')}`,
      },
    });
  }

  async listarPorIntento(idIntento: string, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: idIntento }, include: { sesion: true } });
    if (!intento) throw new NotFoundException('Intento no encontrado');
    if (rol !== RolUsuario.SUPERADMINISTRADOR && intento.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede consultar eventos fuera de su institución');
    }
    if (rol === RolUsuario.DOCENTE && intento.sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }
    return this.prisma.eventoIntento.findMany({ where: { intentoId: idIntento }, orderBy: { fechaEvento: 'asc' } });
  }

  private resolverSeveridadBase(tipo: TipoEventoIntento): SeveridadEvento {
    if (tipo === TipoEventoIntento.APP_EN_BACKGROUND || tipo === TipoEventoIntento.INCIDENTE_REGISTRADO) {
      return SeveridadEvento.CRITICO;
    }
    if (tipo === TipoEventoIntento.RECONCILIACION_FALLIDA) {
      return SeveridadEvento.SOSPECHOSO;
    }
    if (tipo === TipoEventoIntento.REINGRESO_AUTORIZADO || tipo === TipoEventoIntento.TOKEN_REINGRESO_CONSUMIDO) {
      return SeveridadEvento.ADVERTENCIA;
    }
    return SeveridadEvento.INFO;
  }

  private async registrarEventoIntento(
    tx: Prisma.TransactionClient | PrismaService,
    entrada: {
      idIntento: string;
      tipo: TipoEventoIntento;
      descripcion?: string;
      severidad?: SeveridadEvento;
      metadatos?: Record<string, unknown>;
      numeroPregunta?: number;
      tiempoTranscurrido?: number;
    },
  ) {
    const ultimo = await tx.eventoIntento.findFirst({
      where: { intentoId: entrada.idIntento },
      select: { numeroSecuencia: true },
      orderBy: { numeroSecuencia: 'desc' },
    });
    return tx.eventoIntento.create({
      data: {
        intentoId: entrada.idIntento,
        tipo: entrada.tipo,
        descripcion: entrada.descripcion,
        severidad: entrada.severidad ?? SeveridadEvento.INFO,
        metadatos: entrada.metadatos == null ? Prisma.JsonNull : (entrada.metadatos as Prisma.InputJsonValue),
        numeroPregunta: entrada.numeroPregunta,
        tiempoTranscurrido: entrada.tiempoTranscurrido,
        numeroSecuencia: (ultimo?.numeroSecuencia ?? 0) + 1,
      },
    });
  }
}
