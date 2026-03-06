/**
 * @archivo   Telemetria.service.ts
 * @descripcion Registra eventos de telemetría y detecta patrones sospechosos de fraude.
 * @modulo    Telemetria
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ForbiddenException, Inject, Injectable, NotFoundException, forwardRef } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma, RolUsuario, SeveridadEvento, TipoEventoTelemetria } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { esEventoFraudeCritico, tiempoSospechoso } from '../Comun/Utilidades/ValidadorTelemetria.util';
import { RegistrarEventoDto } from './Dto/RegistrarEvento.dto';
import { SesionesExamenGateway } from '../SesionesExamen/SesionesExamen.gateway';

interface PoliticaAntifraudeRed {
  ventanaSegundos: number;
  maxReconexionesVentana: number;
  maxCambiosTipoRedVentana: number;
  maxTiempoOfflineSegundos: number;
  riesgoPorReconexion: number;
  riesgoPorCambioTipoRed: number;
  riesgoPorOfflineExtenso: number;
  umbralRiesgoSospechoso: number;
  umbralRiesgoCritico: number;
}

const POLITICA_RED_DEFAULT: PoliticaAntifraudeRed = {
  ventanaSegundos: 120,
  maxReconexionesVentana: 3,
  maxCambiosTipoRedVentana: 4,
  maxTiempoOfflineSegundos: 90,
  riesgoPorReconexion: 8,
  riesgoPorCambioTipoRed: 6,
  riesgoPorOfflineExtenso: 10,
  umbralRiesgoSospechoso: 30,
  umbralRiesgoCritico: 60,
};

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
   * @param idEstudiante - UUID del estudiante autenticado.
   */
  async registrar(dto: RegistrarEventoDto, idEstudiante: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: dto.idIntento },
      include: {
        institucion: {
          select: {
            id: true,
            configuracion: true,
          },
        },
      },
    });
    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }
    if (intento.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede registrar telemetría fuera de su institución');
    }
    if (intento.estudianteId !== idEstudiante) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }

    const evento = await this.prisma.eventoTelemetria.create({
      data: {
        intentoId: dto.idIntento,
        tipo: dto.tipo,
        descripcion: dto.descripcion,
        metadatos: dto.metadatos as Prisma.InputJsonValue | undefined,
        numeroPregunta: dto.numeroPregunta,
        tiempoTranscurrido: dto.tiempoTranscurrido,
        severidad: this.resolverSeveridadBaseEvento(dto.tipo),
      },
    });

    if (esEventoFraudeCritico(dto.tipo)) {
      this.sesionesGateway.emitirFraude(intento.sesionId, {
        idIntento: dto.idIntento,
        tipoEvento: dto.tipo,
      });

      const razonBase = intento.razonSospecha ? `${intento.razonSospecha}; ` : '';
      await this.prisma.intentoExamen.update({
        where: { id: dto.idIntento },
        data: {
          esSospechoso: true,
          indiceRiesgoFraude: { increment: 15 },
          requiereRevision: true,
          razonSospecha: `${razonBase}${dto.descripcion ?? dto.tipo}`,
        },
      });
    }

    if (this.esEventoRed(dto.tipo)) {
      const politica = this.construirPoliticaAntifraudeRed(intento.institucion?.configuracion ?? null);
      await this.evaluarReconexionesAnomalasEnTiempoReal(intento, politica);
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
        institucion: {
          select: {
            id: true,
            configuracion: true,
          },
        },
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
          indiceRiesgoFraude: { increment: 20 },
          requiereRevision: true,
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
  async listarPorIntento(idIntento: string, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: { sesion: true },
    });

    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }

    if (rol !== RolUsuario.SUPERADMINISTRADOR && intento.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede consultar telemetría fuera de su institución');
    }

    if (rol === RolUsuario.DOCENTE && intento.sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }

    return this.prisma.eventoTelemetria.findMany({
      where: { intentoId: idIntento },
      orderBy: { fechaEvento: 'asc' },
    });
  }

  private resolverSeveridadBaseEvento(tipo: TipoEventoTelemetria): SeveridadEvento {
    if (esEventoFraudeCritico(tipo)) {
      return SeveridadEvento.CRITICO;
    }
    if (tipo === TipoEventoTelemetria.CAMBIO_RED) {
      return SeveridadEvento.ADVERTENCIA;
    }
    if (tipo === TipoEventoTelemetria.SYNC_ANOMALA) {
      return SeveridadEvento.SOSPECHOSO;
    }
    return SeveridadEvento.INFO;
  }

  private esEventoRed(tipo: TipoEventoTelemetria): boolean {
    return tipo === TipoEventoTelemetria.CAMBIO_RED || tipo === TipoEventoTelemetria.SYNC_ANOMALA;
  }

  private async evaluarReconexionesAnomalasEnTiempoReal(
    intento: {
      id: string;
      sesionId: string;
      indiceRiesgoFraude: number;
      esSospechoso: boolean;
      requiereRevision: boolean;
      razonSospecha: string | null;
    },
    politica: PoliticaAntifraudeRed,
  ): Promise<void> {
    const fechaDesde = new Date(Date.now() - politica.ventanaSegundos * 1000);
    const descripcionEvento = 'RECONEXIONES_ANOMALAS_RED';
    const [eventosRed, ultimoEventoAnomalia] = await Promise.all([
      this.prisma.eventoTelemetria.findMany({
        where: {
          intentoId: intento.id,
          fechaEvento: { gte: fechaDesde },
          tipo: TipoEventoTelemetria.CAMBIO_RED,
        },
        orderBy: { fechaEvento: 'asc' },
      }),
      this.prisma.eventoTelemetria.findFirst({
        where: {
          intentoId: intento.id,
          tipo: TipoEventoTelemetria.SYNC_ANOMALA,
          descripcion: descripcionEvento,
        },
        orderBy: { fechaEvento: 'desc' },
      }),
    ]);

    if (eventosRed.length === 0) {
      return;
    }

    let reconexiones = 0;
    let cambiosTipoRed = 0;
    let offlineExtensos = 0;

    for (const evento of eventosRed) {
      if (evento.tipo !== TipoEventoTelemetria.CAMBIO_RED) {
        continue;
      }
      const metadatos = this.extraerObjeto(evento.metadatos);
      const tipoCambio = this.extraerTexto(metadatos?.evento);
      const reconectado = this.extraerBooleano(metadatos?.reconectado) ?? false;
      const duracionSinRedMs = this.extraerNumero(metadatos?.duracionSinRedMs) ?? 0;

      if (reconectado || tipoCambio === 'RECONECTADO' || tipoCambio === 'RECONECTADO_CON_SINCRONIZACION') {
        reconexiones += 1;
      }
      if (tipoCambio === 'CAMBIO_TIPO_RED') {
        cambiosTipoRed += 1;
      }
      if (duracionSinRedMs >= politica.maxTiempoOfflineSegundos * 1000) {
        offlineExtensos += 1;
      }
    }

    const metadatosEventoPrevio = this.extraerObjeto(ultimoEventoAnomalia?.metadatos);
    const excesoReconexionesPrevio = this.normalizarEnteroNoNegativo(metadatosEventoPrevio?.excesoReconexionesAplicado);
    const excesoCambiosTipoRedPrevio = this.normalizarEnteroNoNegativo(metadatosEventoPrevio?.excesoCambiosTipoRedAplicado);
    const excesoOfflinePrevio = this.normalizarEnteroNoNegativo(metadatosEventoPrevio?.excesoOfflineAplicado);

    const excesoReconexionesActual = Math.max(0, reconexiones - politica.maxReconexionesVentana);
    const excesoCambiosTipoRedActual = Math.max(0, cambiosTipoRed - politica.maxCambiosTipoRedVentana);
    const excesoOfflineActual = offlineExtensos;

    const deltaReconexiones = Math.max(0, excesoReconexionesActual - excesoReconexionesPrevio);
    const deltaCambiosTipoRed = Math.max(0, excesoCambiosTipoRedActual - excesoCambiosTipoRedPrevio);
    const deltaOffline = Math.max(0, excesoOfflineActual - excesoOfflinePrevio);

    const incrementoRiesgo =
      deltaReconexiones * politica.riesgoPorReconexion +
      deltaCambiosTipoRed * politica.riesgoPorCambioTipoRed +
      deltaOffline * politica.riesgoPorOfflineExtenso;

    if (incrementoRiesgo <= 0) {
      return;
    }

    const razones: string[] = [];
    if (deltaReconexiones > 0) {
      razones.push(`Reconexiones anómalas: ${reconexiones} (exceso ${excesoReconexionesActual})`);
    }
    if (deltaCambiosTipoRed > 0) {
      razones.push(`Cambios de red anómalos: ${cambiosTipoRed} (exceso ${excesoCambiosTipoRedActual})`);
    }
    if (deltaOffline > 0) {
      razones.push(`Desconexiones prolongadas: ${offlineExtensos} (umbral ${politica.maxTiempoOfflineSegundos}s)`);
    }

    const riesgoActual = intento.indiceRiesgoFraude ?? 0;
    const riesgoNuevo = Math.min(100, riesgoActual + incrementoRiesgo);
    const cruzaUmbralSospechoso = riesgoActual < politica.umbralRiesgoSospechoso && riesgoNuevo >= politica.umbralRiesgoSospechoso;
    const cruzaUmbralCritico = riesgoActual < politica.umbralRiesgoCritico && riesgoNuevo >= politica.umbralRiesgoCritico;

    const razonActual = intento.razonSospecha ? `${intento.razonSospecha}; ` : '';
    const razonActualizada = `${razonActual}${razones.join('; ')}`;
    await this.prisma.intentoExamen.update({
      where: { id: intento.id },
      data: {
        indiceRiesgoFraude: riesgoNuevo,
        esSospechoso: riesgoNuevo >= politica.umbralRiesgoSospechoso || intento.esSospechoso,
        requiereRevision: riesgoNuevo >= politica.umbralRiesgoSospechoso || intento.requiereRevision,
        razonSospecha: razonActualizada,
      },
    });

    await this.prisma.eventoTelemetria.create({
      data: {
        intentoId: intento.id,
        tipo: TipoEventoTelemetria.SYNC_ANOMALA,
        severidad: riesgoNuevo >= politica.umbralRiesgoCritico ? SeveridadEvento.CRITICO : SeveridadEvento.SOSPECHOSO,
        descripcion: descripcionEvento,
        metadatos: {
          reconexiones,
          cambiosTipoRed,
          offlineExtensos,
          ventanaSegundos: politica.ventanaSegundos,
          razonesRiesgo: razones,
          umbralRiesgoSospechoso: politica.umbralRiesgoSospechoso,
          umbralRiesgoCritico: politica.umbralRiesgoCritico,
          riesgoAntes: riesgoActual,
          riesgoDespues: riesgoNuevo,
          incrementoRiesgoAplicado: incrementoRiesgo,
          excesoReconexionesAplicado: excesoReconexionesActual,
          excesoCambiosTipoRedAplicado: excesoCambiosTipoRedActual,
          excesoOfflineAplicado: excesoOfflineActual,
          deltaReconexiones,
          deltaCambiosTipoRed,
          deltaOffline,
        } as Prisma.InputJsonValue,
      },
    });

    if (cruzaUmbralSospechoso || cruzaUmbralCritico) {
      this.sesionesGateway.emitirFraude(intento.sesionId, {
        idIntento: intento.id,
        tipoEvento: TipoEventoTelemetria.SYNC_ANOMALA,
      });
    }
  }

  private construirPoliticaAntifraudeRed(configuracionInstitucion: Prisma.JsonValue | null): PoliticaAntifraudeRed {
    const objetoConfiguracion = this.extraerObjeto(configuracionInstitucion);
    const antifraude = this.extraerObjeto(objetoConfiguracion?.antifraude);
    const red = this.extraerObjeto(antifraude?.red);

    const umbralRiesgoSospechoso = this.normalizarNumeroPolitica(
      red?.umbralRiesgoSospechoso,
      'TELEMETRIA_RED_UMBRAL_SOSPECHA',
      POLITICA_RED_DEFAULT.umbralRiesgoSospechoso,
      0,
      100,
    );
    const umbralRiesgoCritico = this.normalizarNumeroPolitica(
      red?.umbralRiesgoCritico,
      'TELEMETRIA_RED_UMBRAL_CRITICO',
      POLITICA_RED_DEFAULT.umbralRiesgoCritico,
      1,
      100,
    );

    return {
      ventanaSegundos: this.normalizarNumeroPolitica(
        red?.ventanaSegundos,
        'TELEMETRIA_RED_VENTANA_SEGUNDOS',
        POLITICA_RED_DEFAULT.ventanaSegundos,
        30,
        3600,
      ),
      maxReconexionesVentana: this.normalizarNumeroPolitica(
        red?.maxReconexionesVentana,
        'TELEMETRIA_RED_MAX_RECONECIONES_VENTANA',
        POLITICA_RED_DEFAULT.maxReconexionesVentana,
        1,
        30,
      ),
      maxCambiosTipoRedVentana: this.normalizarNumeroPolitica(
        red?.maxCambiosTipoRedVentana,
        'TELEMETRIA_RED_MAX_CAMBIOS_TIPO_VENTANA',
        POLITICA_RED_DEFAULT.maxCambiosTipoRedVentana,
        1,
        30,
      ),
      maxTiempoOfflineSegundos: this.normalizarNumeroPolitica(
        red?.maxTiempoOfflineSegundos,
        'TELEMETRIA_RED_MAX_OFFLINE_SEGUNDOS',
        POLITICA_RED_DEFAULT.maxTiempoOfflineSegundos,
        5,
        900,
      ),
      riesgoPorReconexion: this.normalizarNumeroPolitica(
        red?.riesgoPorReconexion,
        'TELEMETRIA_RED_RIESGO_RECONECION',
        POLITICA_RED_DEFAULT.riesgoPorReconexion,
        1,
        50,
      ),
      riesgoPorCambioTipoRed: this.normalizarNumeroPolitica(
        red?.riesgoPorCambioTipoRed,
        'TELEMETRIA_RED_RIESGO_CAMBIO_TIPO',
        POLITICA_RED_DEFAULT.riesgoPorCambioTipoRed,
        1,
        50,
      ),
      riesgoPorOfflineExtenso: this.normalizarNumeroPolitica(
        red?.riesgoPorOfflineExtenso,
        'TELEMETRIA_RED_RIESGO_OFFLINE',
        POLITICA_RED_DEFAULT.riesgoPorOfflineExtenso,
        1,
        50,
      ),
      umbralRiesgoSospechoso,
      umbralRiesgoCritico: Math.max(umbralRiesgoCritico, umbralRiesgoSospechoso),
    };
  }

  private normalizarNumeroPolitica(
    valorConfiguracion: unknown,
    claveEnv: string,
    valorDefecto: number,
    minimo: number,
    maximo: number,
  ): number {
    const desdeConfiguracion = this.extraerNumero(valorConfiguracion);
    if (desdeConfiguracion != null) {
      return Math.min(maximo, Math.max(minimo, Math.round(desdeConfiguracion)));
    }

    const desdeEnv = Number.parseInt(this.servicioConfiguracion.get<string>(claveEnv) ?? '', 10);
    if (Number.isFinite(desdeEnv)) {
      return Math.min(maximo, Math.max(minimo, desdeEnv));
    }

    return Math.min(maximo, Math.max(minimo, valorDefecto));
  }

  private extraerObjeto(valor: unknown): Record<string, unknown> | null {
    if (valor && typeof valor === 'object' && !Array.isArray(valor)) {
      return valor as Record<string, unknown>;
    }
    return null;
  }

  private extraerTexto(valor: unknown): string | null {
    return typeof valor === 'string' && valor.trim().length > 0 ? valor.trim().toUpperCase() : null;
  }

  private extraerNumero(valor: unknown): number | null {
    if (typeof valor === 'number' && Number.isFinite(valor)) {
      return valor;
    }
    if (typeof valor === 'string') {
      const numero = Number.parseFloat(valor);
      return Number.isFinite(numero) ? numero : null;
    }
    return null;
  }

  private extraerBooleano(valor: unknown): boolean | null {
    if (typeof valor === 'boolean') {
      return valor;
    }
    if (typeof valor === 'string') {
      const normalizado = valor.trim().toLowerCase();
      if (normalizado === 'true') {
        return true;
      }
      if (normalizado === 'false') {
        return false;
      }
    }
    return null;
  }

  private normalizarEnteroNoNegativo(valor: unknown): number {
    const numero = this.extraerNumero(valor);
    if (numero == null) {
      return 0;
    }
    return Math.max(0, Math.round(numero));
  }
}
