/**
 * @archivo   Intentos.service.ts
 * @descripcion Gestiona intentos, incidentes, reingreso y exposición segura del examen.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  EstadoIntento,
  EstadoSesion,
  MetodoReingreso,
  Prisma,
  RolUsuario,
  SeveridadEvento,
  TipoEventoIntento,
  TipoIncidente,
} from '@prisma/client';
import { createHash, randomInt } from 'crypto';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { aleatorizarConSemilla } from '../Comun/Utilidades/AleatorizadorPreguntas.util';
import { CODIGOS_ERROR } from '../Comun/Constantes/Mensajes.constantes';
import { ordenarPreguntasSegunIntento } from '../Comun/Utilidades/OrdenPreguntasIntento.util';
import { sanitizarExamenParaEstudiante } from '../Comun/Utilidades/SanitizadorExamenEstudiante.util';
import { SesionesExamenGateway } from '../SesionesExamen/SesionesExamen.gateway';
import { AutorizarReingresoDto } from './Dto/AutorizarReingreso.dto';
import { ConsumirTokenReingresoDto } from './Dto/ConsumirTokenReingreso.dto';
import { FinalizarProvisionalIntentoDto } from './Dto/FinalizarProvisionalIntento.dto';
import { IniciarIntentoDto, IntegridadDispositivoIntentoDto } from './Dto/IniciarIntento.dto';
import { ReconciliarIntentoDto } from './Dto/ReconciliarIntento.dto';
import { RegistrarIncidenteIntentoDto } from './Dto/RegistrarIncidenteIntento.dto';
import {
  esEstadoTerminal,
  obtenerEstadosNoTerminalesIntento,
  permiteEditarIntento,
  validarTransicionIntento,
} from './MaquinaEstadosIntento.util';

const LIMITE_SEMILLA_PERSONAL = 999999;
const LONGITUD_PIN_REINGRESO = 6;

interface EvaluacionIntegridadInicio {
  puntaje: number;
  razones: string[];
  bloquearInicio: boolean;
  requiereRevision: boolean;
  plataforma: string;
  metadatos: Record<string, unknown>;
}

@Injectable()
export class IntentosService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly sesionesGateway: SesionesExamenGateway,
    private readonly configService: ConfigService,
  ) {}

  async iniciar(dto: IniciarIntentoDto, idEstudiante: string, idInstitucion: string | null) {
    const sesion = await this.prisma.sesionExamen.findUnique({
      where: { id: dto.idSesion },
      include: {
        examen: { include: { preguntas: { include: { opciones: true }, orderBy: { orden: 'asc' } } } },
        asignacion: true,
      },
    });
    if (!sesion) throw new NotFoundException('Sesión no encontrada');
    if (sesion.idInstitucion !== idInstitucion) throw new ForbiddenException('No puede iniciar intentos fuera de su institución');
    if (sesion.estado !== EstadoSesion.ACTIVA) {
      throw new BadRequestException({ message: 'La sesión no está activa', codigoError: CODIGOS_ERROR.SESION_NO_ACTIVA });
    }
    if (!sesion.codigoAcceso || sesion.codigoAcceso.trim().toUpperCase() !== dto.codigoAcceso.trim().toUpperCase()) {
      throw new ForbiddenException({
        message: 'Código de acceso inválido para la sesión',
        codigoError: CODIGOS_ERROR.CODIGO_SESION_INVALIDO,
      });
    }

    const evaluacionIntegridad = this.evaluarIntegridadInicio(dto);
    if (evaluacionIntegridad.bloquearInicio) {
      throw new ForbiddenException({
        message: 'El dispositivo no cumple la política de integridad para iniciar el intento',
        codigoError: CODIGOS_ERROR.DISPOSITIVO_NO_SEGURO,
        datos: { puntajeIntegridad: evaluacionIntegridad.puntaje, razonesRiesgo: evaluacionIntegridad.razones },
      });
    }

    await this.validarElegibilidadAsignacion(sesion.asignacion, idEstudiante);

    const intentoExistente = await this.prisma.intentoExamen.findFirst({
      where: { estudianteId: idEstudiante, sesionId: dto.idSesion, estado: { in: obtenerEstadosNoTerminalesIntento() } },
      select: { id: true, estado: true, semillaPersonal: true, sesionId: true },
    });
    if (intentoExistente) {
      throw new ConflictException({
        message: 'El estudiante ya tiene un intento en esta sesión',
        codigoError: CODIGOS_ERROR.INTENTO_DUPLICADO,
        datos: { intentoExistente },
      });
    }

    if (sesion.asignacion?.intentosMaximos && sesion.asignacion.intentosMaximos > 0) {
      const intentosPrevios = await this.prisma.intentoExamen.count({
        where: { sesionId: dto.idSesion, estudianteId: idEstudiante, estado: EstadoIntento.ENVIADO },
      });
      if (intentosPrevios >= sesion.asignacion.intentosMaximos) {
        throw new ForbiddenException({
          message: 'Se alcanzó el número máximo de intentos permitidos',
          codigoError: CODIGOS_ERROR.INTENTOS_AGOTADOS,
        });
      }
    }

    const semillaPersonal = Math.floor(Math.random() * LIMITE_SEMILLA_PERSONAL) + 1;
    const semillaDeterminista = this.generarSemillaDeterminista(sesion.examen.id, dto.idSesion, idEstudiante);
    const preguntasAleatorias = aleatorizarConSemilla(sesion.examen.preguntas, semillaDeterminista).map((pregunta) => ({
      idPregunta: pregunta.id,
      orden: pregunta.orden,
      opciones: aleatorizarConSemilla(pregunta.opciones, semillaDeterminista + pregunta.orden).map((opcion) => ({
        id: opcion.id,
        orden: opcion.orden,
      })),
    }));

    const intento = await this.prisma.$transaction(async (tx) => {
      const creado = await tx.intentoExamen.create({
        data: {
          idInstitucion: idInstitucion ?? null,
          semillaPersonal,
          estado: EstadoIntento.INICIADO,
          estudianteId: idEstudiante,
          sesionId: dto.idSesion,
          ordenPreguntasAplicado: { semilla: semillaDeterminista, preguntas: preguntasAleatorias },
          ultimaSincronizacion: new Date(),
          ipDispositivo: dto.ipDispositivo,
          modeloDispositivo: dto.modeloDispositivo,
          sistemaOperativo: dto.sistemaOperativo,
          versionApp: dto.versionApp,
          indiceRiesgoFraude: evaluacionIntegridad.puntaje,
          requiereRevision: evaluacionIntegridad.requiereRevision,
          esSospechoso: evaluacionIntegridad.requiereRevision,
          razonSospecha: evaluacionIntegridad.razones.length > 0 ? `Integridad dispositivo: ${evaluacionIntegridad.razones.join('; ')}` : null,
        },
        include: { estudiante: { select: { nombre: true, apellidos: true } } },
      });
      await this.registrarEventoIntento(tx, {
        idIntento: creado.id,
        tipo: TipoEventoIntento.INTENTO_INICIADO,
        descripcion: 'INTENTO_CREADO',
        metadatos: evaluacionIntegridad.metadatos,
      });
      return creado;
    });

    this.sesionesGateway.emitirProgreso(dto.idSesion, {
      idIntento: intento.id,
      idEstudiante,
      preguntasRespondidas: 0,
      preguntasRespondidasIndices: [],
      indicePreguntaActual: 1,
      totalPreguntas: sesion.examen.totalPreguntas,
      nombreCompleto: `${intento.estudiante.nombre} ${intento.estudiante.apellidos}`.trim(),
      modoKioscoActivo: true,
      eventosFraude: 0,
      estadoIntento: EstadoIntento.INICIADO,
    });
    return intento;
  }

  async obtenerExamen(idIntento: string, idEstudiante: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: {
        sesion: {
          include: {
            examen: { include: { preguntas: { include: { opciones: true }, orderBy: { orden: 'asc' } } } },
          },
        },
      },
    });
    if (!intento) throw new NotFoundException('Intento no encontrado');
    this.asegurarPropiedadEstudiante(intento, idEstudiante, idInstitucion);

    const preguntasOrdenadas = ordenarPreguntasSegunIntento(intento.sesion.examen.preguntas, intento.ordenPreguntasAplicado);
    const examen = sanitizarExamenParaEstudiante({
      id: intento.sesion.examen.id,
      titulo: intento.sesion.examen.titulo,
      descripcion: intento.sesion.examen.descripcion,
      instrucciones: intento.sesion.examen.instrucciones,
      modalidad: intento.sesion.examen.modalidad,
      duracionMinutos: intento.sesion.examen.duracionMinutos,
      permitirNavegacion: intento.sesion.examen.permitirNavegacion,
      mostrarPuntaje: intento.sesion.examen.mostrarPuntaje,
      version: intento.sesion.examen.version,
      preguntas: preguntasOrdenadas.map((pregunta) => ({
        ...pregunta,
        opciones: pregunta.opciones.map(({ esCorrecta: _esCorrecta, ...opcion }) => opcion),
      })),
    });

    await this.registrarEventoIntento(this.prisma, {
      idIntento,
      tipo: TipoEventoIntento.EVALUACION_ABIERTA,
      descripcion: 'EVALUACION_DESCARGADA',
    });

    return { idIntento: intento.id, estado: intento.estado, sesion: { id: intento.sesion.id, codigoAcceso: intento.sesion.codigoAcceso }, examen };
  }

  async registrarIncidente(idIntento: string, dto: RegistrarIncidenteIntentoDto, idEstudiante: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: {
        estudiante: { select: { nombre: true, apellidos: true } },
        sesion: { include: { examen: { select: { totalPreguntas: true } } } },
        _count: { select: { respuestas: true } },
      },
    });
    if (!intento) throw new NotFoundException('Intento no encontrado');
    this.asegurarPropiedadEstudiante(intento, idEstudiante, idInstitucion);

    const resultado = await this.prisma.$transaction((tx) =>
      this.aplicarIncidenteEnTransaccion(tx, intento, dto.tipo, dto.descripcion ?? dto.tipo, dto.contexto),
    );

    this.sesionesGateway.emitirFraude(intento.sesionId, { idIntento, tipoEvento: dto.tipo });
    this.sesionesGateway.emitirProgreso(intento.sesionId, {
      idIntento,
      idEstudiante: intento.estudianteId,
      preguntasRespondidas: intento._count.respuestas,
      totalPreguntas: intento.sesion.examen.totalPreguntas,
      nombreCompleto: `${intento.estudiante.nombre} ${intento.estudiante.apellidos}`.trim(),
      modoKioscoActivo: false,
      eventosFraude: resultado.incidentesAcumulados,
      estadoIntento: resultado.estado,
    });
    return resultado;
  }

  async autorizarReingreso(idIntento: string, dto: AutorizarReingresoDto, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: idIntento }, include: { sesion: true } });
    if (!intento) throw new NotFoundException('Intento no encontrado');
    this.asegurarPropiedadGestion(intento, rol, idUsuario, idInstitucion);
    if (intento.estado !== EstadoIntento.BLOQUEADO) throw new BadRequestException('Solo los intentos bloqueados pueden recibir reingreso');

    const metodo = dto.metodo === 'QR' ? MetodoReingreso.QR : MetodoReingreso.PIN;
    const codigoVisible = this.generarCodigoReingreso();
    const expiraEn = new Date(Date.now() + this.obtenerMinutosValidezReingreso() * 60_000);

    const token = await this.prisma.$transaction(async (tx) => {
      const creado = await tx.tokenReingreso.create({
        data: {
          intentoId: intento.id,
          estudianteId: intento.estudianteId,
          autorizadoPorId: idUsuario,
          metodo,
          codigoVisible,
          codigoHash: this.hashTexto(codigoVisible),
          expiraEn,
          dispositivoAutoriza: dto.dispositivoAutoriza,
        },
      });
      await this.registrarEventoIntento(tx, {
        idIntento: intento.id,
        tipo: TipoEventoIntento.REINGRESO_AUTORIZADO,
        descripcion: `${metodo}_GENERADO`,
        severidad: SeveridadEvento.ADVERTENCIA,
        metadatos: { tokenReingresoId: creado.id, metodo, expiraEn: expiraEn.toISOString(), dispositivoAutoriza: dto.dispositivoAutoriza ?? null },
      });
      return creado;
    });

    return { idToken: token.id, metodo: token.metodo, codigoVisible, expiraEn };
  }

  async reanudar(idIntento: string, dto: ConsumirTokenReingresoDto, idEstudiante: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: {
        estudiante: { select: { nombre: true, apellidos: true } },
        sesion: { include: { examen: { select: { totalPreguntas: true } } } },
        _count: { select: { respuestas: true } },
      },
    });
    if (!intento) throw new NotFoundException('Intento no encontrado');
    this.asegurarPropiedadEstudiante(intento, idEstudiante, idInstitucion);
    if (intento.estado !== EstadoIntento.BLOQUEADO) throw new BadRequestException('Solo los intentos bloqueados pueden reanudarse');

    const codigoNormalizado = dto.codigo.trim().toUpperCase();
    const token = await this.prisma.tokenReingreso.findFirst({
      where: { intentoId: idIntento, estudianteId: idEstudiante, usado: false, expiraEn: { gt: new Date() }, codigoVisible: codigoNormalizado },
      orderBy: { fechaCreacion: 'desc' },
    });

    if (!token || token.codigoHash !== this.hashTexto(codigoNormalizado)) {
      await this.prisma.$transaction((tx) =>
        this.aplicarIncidenteEnTransaccion(tx, intento, TipoIncidente.TOKEN_REINGRESO_INVALIDO, 'TOKEN_REINGRESO_INVALIDO', { codigoIntentado: codigoNormalizado }),
      );
      throw new ForbiddenException({ message: 'El token de reingreso es inválido, expiró o ya fue usado', codigoError: 'TOKEN_REINGRESO_INVALIDO' });
    }

    await this.prisma.$transaction(async (tx) => {
      validarTransicionIntento(intento.estado, EstadoIntento.REANUDADO);
      await tx.tokenReingreso.update({ where: { id: token.id }, data: { usado: true, usadoEn: new Date() } });
      await tx.intentoExamen.update({
        where: { id: idIntento },
        data: { estado: EstadoIntento.REANUDADO, fechaReanudacion: new Date(), ultimaSincronizacion: new Date() },
      });
      await this.registrarEventoIntento(tx, {
        idIntento,
        tipo: TipoEventoIntento.TOKEN_REINGRESO_CONSUMIDO,
        descripcion: `${token.metodo}_CONSUMIDO`,
        severidad: SeveridadEvento.ADVERTENCIA,
        metadatos: { tokenReingresoId: token.id, metodo: token.metodo },
      });
    });

    this.sesionesGateway.emitirProgreso(intento.sesionId, {
      idIntento,
      idEstudiante,
      preguntasRespondidas: intento._count.respuestas,
      totalPreguntas: intento.sesion.examen.totalPreguntas,
      nombreCompleto: `${intento.estudiante.nombre} ${intento.estudiante.apellidos}`.trim(),
      modoKioscoActivo: true,
      eventosFraude: intento.incidentesAcumulados,
      estadoIntento: EstadoIntento.REANUDADO,
    });
    return { id: idIntento, estado: EstadoIntento.REANUDADO };
  }

  async finalizarProvisional(idIntento: string, dto: FinalizarProvisionalIntentoDto, idEstudiante: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: idIntento } });
    if (!intento) throw new NotFoundException('Intento no encontrado');
    this.asegurarPropiedadEstudiante(intento, idEstudiante, idInstitucion);
    if (!permiteEditarIntento(intento.estado)) throw new BadRequestException('El intento no permite finalización provisional en su estado actual');

    await this.prisma.$transaction(async (tx) => {
      validarTransicionIntento(intento.estado, EstadoIntento.FINALIZADO_PROVISIONAL);
      await tx.intentoExamen.update({
        where: { id: idIntento },
        data: { estado: EstadoIntento.FINALIZADO_PROVISIONAL, fechaFinalizacionProv: new Date(), ultimaSincronizacion: new Date() },
      });
      await this.registrarEventoIntento(tx, {
        idIntento,
        tipo: TipoEventoIntento.FINALIZACION_PROVISIONAL,
        descripcion: 'CIERRE_OFFLINE',
        severidad: SeveridadEvento.ADVERTENCIA,
        metadatos: dto.contexto,
      });
    });
    return { id: idIntento, estado: EstadoIntento.FINALIZADO_PROVISIONAL };
  }

  async reconciliar(idIntento: string, dto: ReconciliarIntentoDto, idEstudiante: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: idIntento } });
    if (!intento) throw new NotFoundException('Intento no encontrado');
    this.asegurarPropiedadEstudiante(intento, idEstudiante, idInstitucion);
    if (intento.estado !== EstadoIntento.FINALIZADO_PROVISIONAL) {
      throw new BadRequestException('Solo los intentos provisionalmente finalizados pueden reconciliarse');
    }

    await this.prisma.$transaction(async (tx) => {
      validarTransicionIntento(intento.estado, EstadoIntento.ENVIADO);
      await tx.intentoExamen.update({
        where: { id: idIntento },
        data: { estado: EstadoIntento.ENVIADO, fechaEnvio: new Date(), ultimaSincronizacion: new Date() },
      });
      await this.registrarEventoIntento(tx, {
        idIntento,
        tipo: TipoEventoIntento.RECONCILIACION_EXITOSA,
        descripcion: 'RECONCILIACION_OFFLINE_OK',
        metadatos: dto.contexto,
      });
    });
    return { id: idIntento, estado: EstadoIntento.ENVIADO };
  }

  async listarIncidentes(idIntento: string, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: idIntento }, include: { sesion: true } });
    if (!intento) throw new NotFoundException('Intento no encontrado');
    this.asegurarPropiedadGestion(intento, rol, idUsuario, idInstitucion);
    return this.prisma.incidente.findMany({ where: { intentoId: idIntento }, orderBy: { fechaRegistro: 'asc' } });
  }

  async anular(idIntento: string, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: idIntento }, include: { sesion: true } });
    if (!intento) throw new NotFoundException('Intento no encontrado');
    this.asegurarPropiedadGestion(intento, rol, idUsuario, idInstitucion);
    if (intento.estado === EstadoIntento.ANULADO) throw new BadRequestException('El intento ya fue anulado');
    if (esEstadoTerminal(intento.estado) && intento.estado !== EstadoIntento.ENVIADO) {
      throw new BadRequestException('Solo se pueden anular intentos no terminales o intentos enviados');
    }

    await this.prisma.$transaction(async (tx) => {
      validarTransicionIntento(intento.estado, EstadoIntento.ANULADO);
      await tx.intentoExamen.update({
        where: { id: idIntento },
        data: { estado: EstadoIntento.ANULADO, razonAnulacion: 'ANULACION_ADMINISTRATIVA', anuladoPorId: idUsuario, anuladoEn: new Date() },
      });
      await this.registrarEventoIntento(tx, {
        idIntento,
        tipo: TipoEventoIntento.ANULACION,
        descripcion: 'ANULACION_ADMINISTRATIVA',
        severidad: SeveridadEvento.CRITICO,
        metadatos: { actorId: idUsuario, rol },
      });
    });
    return this.prisma.intentoExamen.findUnique({ where: { id: idIntento } });
  }

  private asegurarPropiedadEstudiante(intento: { idInstitucion: string | null; estudianteId: string }, idEstudiante: string, idInstitucion: string | null) {
    if (intento.idInstitucion !== idInstitucion) throw new ForbiddenException('No puede operar intentos fuera de su institución');
    if (intento.estudianteId !== idEstudiante) throw new ForbiddenException('No tiene permisos sobre este intento');
  }

  private asegurarPropiedadGestion(intento: { idInstitucion: string | null; sesion: { creadaPorId: string } }, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    if (rol !== RolUsuario.SUPERADMINISTRADOR && intento.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede operar sobre intentos fuera de su institución');
    }
    if (rol === RolUsuario.DOCENTE && intento.sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }
  }

  private async aplicarIncidenteEnTransaccion(
    tx: Prisma.TransactionClient,
    intento: { id: string; estado: EstadoIntento; incidentesAcumulados: number; indiceRiesgoFraude: number; sesionId: string; estudianteId: string },
    tipo: TipoIncidente,
    descripcion: string,
    contexto?: Record<string, unknown>,
  ) {
    const incidentesAcumulados = intento.incidentesAcumulados + 1;
    const estadoDestino = incidentesAcumulados >= 3 || intento.estado === EstadoIntento.BLOQUEADO ? EstadoIntento.SUSPENDIDO : EstadoIntento.BLOQUEADO;
    validarTransicionIntento(intento.estado, estadoDestino);

    const incidente = await tx.incidente.create({
      data: {
        intentoId: intento.id,
        tipo,
        descripcion,
        contexto: contexto == null ? Prisma.JsonNull : (contexto as Prisma.InputJsonValue),
        contadorAcumulado: incidentesAcumulados,
        altoRiesgo: incidentesAcumulados >= 2,
        severidad: incidentesAcumulados >= 3 ? SeveridadEvento.CRITICO : SeveridadEvento.SOSPECHOSO,
      },
    });
    const evento = await this.registrarEventoIntento(tx, {
      idIntento: intento.id,
      tipo: TipoEventoIntento.INCIDENTE_REGISTRADO,
      descripcion,
      severidad: incidentesAcumulados >= 3 ? SeveridadEvento.CRITICO : SeveridadEvento.SOSPECHOSO,
      metadatos: { incidenteId: incidente.id, tipoIncidente: tipo, contadorAcumulado: incidentesAcumulados, altoRiesgo: incidentesAcumulados >= 2, contexto: contexto ?? null },
    });
    await tx.incidente.update({ where: { id: incidente.id }, data: { eventoId: evento.id } });

    return tx.intentoExamen.update({
      where: { id: intento.id },
      data: {
        estado: estadoDestino,
        incidentesAcumulados,
        altoRiesgo: incidentesAcumulados >= 2,
        requiereRevision: true,
        esSospechoso: true,
        indiceRiesgoFraude: Math.min(100, (intento.indiceRiesgoFraude ?? 0) + (incidentesAcumulados >= 3 ? 35 : 15)),
        fechaBloqueo: estadoDestino === EstadoIntento.BLOQUEADO ? new Date() : null,
      },
      select: { id: true, estado: true, incidentesAcumulados: true, altoRiesgo: true },
    });
  }

  private async registrarEventoIntento(
    tx: Prisma.TransactionClient | PrismaService,
    entrada: { idIntento: string; tipo: TipoEventoIntento; descripcion?: string; severidad?: SeveridadEvento; metadatos?: Record<string, unknown> | null },
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
        numeroSecuencia: (ultimo?.numeroSecuencia ?? 0) + 1,
      },
    });
  }

  private generarCodigoReingreso(): string {
    return randomInt(0, 10 ** LONGITUD_PIN_REINGRESO).toString().padStart(LONGITUD_PIN_REINGRESO, '0');
  }

  private obtenerMinutosValidezReingreso(): number {
    const valor = Number.parseInt(this.configService.get<string>('TOKEN_REINGRESO_MINUTOS_VALIDEZ') ?? '', 10);
    return Number.isFinite(valor) && valor > 0 ? valor : 5;
  }

  private hashTexto(valor: string): string {
    return createHash('sha256').update(valor.trim().toUpperCase()).digest('hex');
  }

  private generarSemillaDeterminista(idExamen: string, idSesion: string, idEstudiante: string): number {
    const hash = createHash('sha256').update(`${idExamen}:${idSesion}:${idEstudiante}`).digest('hex');
    return Number.parseInt(hash.slice(0, 8), 16);
  }

  private async validarElegibilidadAsignacion(
    asignacion: { fechaInicio: Date; fechaFin: Date; idGrupo: string | null; idEstudiante: string | null } | null,
    idEstudiante: string,
  ) {
    if (!asignacion) return;
    const ahora = new Date();
    if (ahora < asignacion.fechaInicio || ahora > asignacion.fechaFin) {
      throw new ForbiddenException({ message: 'La sesión está fuera de la ventana de la asignación', codigoError: CODIGOS_ERROR.SESION_NO_ACTIVA });
    }
    if (asignacion.idEstudiante && asignacion.idEstudiante !== idEstudiante) {
      throw new ForbiddenException('La asignación es individual y no corresponde al estudiante autenticado');
    }
    if (asignacion.idGrupo) {
      const membresia = await this.prisma.grupoEstudiante.findFirst({
        where: { idGrupo: asignacion.idGrupo, idEstudiante, activo: true },
        select: { id: true },
      });
      if (!membresia) throw new ForbiddenException('El estudiante no pertenece activamente al grupo de la asignación');
    }
  }

  private evaluarIntegridadInicio(dto: IniciarIntentoDto): EvaluacionIntegridadInicio {
    const plataforma = this.resolverPlataforma(dto.integridadDispositivo, dto.sistemaOperativo);
    const esAndroid = plataforma === 'ANDROID';
    const reporte = dto.integridadDispositivo;
    const razones = new Set<string>();
    let puntaje = 0;
    const requiereReporteAndroid = this.obtenerFlagBooleano('INTEGRIDAD_REQUERIR_REPORTE_ANDROID', true);
    const requiereBloqueoEstrictoAndroid = this.obtenerFlagBooleano('INTEGRIDAD_REQUERIR_BLOQUEO_ESTRICTO_ANDROID', true);
    const permitirEmulador = this.obtenerFlagBooleano('INTEGRIDAD_PERMITIR_EMULADOR', process.env.NODE_ENV !== 'production');
    const permitirCompilacionDebug = this.obtenerFlagBooleano('INTEGRIDAD_PERMITIR_COMPILACION_DEBUG', process.env.NODE_ENV !== 'production');
    const permitirOpcionesDesarrollador = this.obtenerFlagBooleano('INTEGRIDAD_PERMITIR_OPCIONES_DESARROLLADOR', process.env.NODE_ENV !== 'production');
    const permitirAdb = this.obtenerFlagBooleano('INTEGRIDAD_PERMITIR_ADB', process.env.NODE_ENV !== 'production');
    const umbralBloqueo = this.obtenerNumeroEnRango('INTEGRIDAD_RIESGO_BLOQUEO_UMBRAL', 60, 0, 100);

    if (esAndroid && requiereReporteAndroid && !reporte) {
      razones.add('REPORTE_INTEGRIDAD_AUSENTE');
      puntaje = 100;
      return this.construirResultadoIntegridad(plataforma, puntaje, Array.from(razones), true, reporte);
    }
    if (!reporte) return this.construirResultadoIntegridad(plataforma, 0, [], false, undefined);

    if (reporte.rootDetectado === true) { puntaje += 45; razones.add('ROOT_O_JAILBREAK_DETECTADO'); }
    if (reporte.appDepurable === true && !permitirCompilacionDebug) { puntaje += 35; razones.add('APP_DEPURABLE_NO_PERMITIDA'); }
    if (reporte.opcionesDesarrolladorActivas === true && !permitirOpcionesDesarrollador) { puntaje += 25; razones.add('OPCIONES_DESARROLLADOR_ACTIVAS'); }
    if (reporte.adbActivo === true && !permitirAdb) { puntaje += 25; razones.add('ADB_ACTIVO'); }
    if (reporte.emuladorDetectado === true && !permitirEmulador) { puntaje += 25; razones.add('EMULADOR_NO_PERMITIDO'); }

    if (esAndroid && requiereBloqueoEstrictoAndroid) {
      if (reporte.bloqueoEstrictoDisponible !== true) { puntaje += 30; razones.add('BLOQUEO_ESTRICTO_NO_DISPONIBLE'); }
      if (reporte.bloqueoEstrictoActivo !== true) { puntaje += 40; razones.add('BLOQUEO_ESTRICTO_NO_ACTIVO'); }
      if (reporte.lockTaskActivo === false) { puntaje += 20; razones.add('LOCK_TASK_INACTIVO'); }
      if (reporte.dispositivoPropietario === false) { puntaje += 20; razones.add('DEVICE_OWNER_INACTIVO'); }
    }

    puntaje = Math.min(100, Math.max(0, puntaje));
    const bloquearPorCriticos = razones.has('ROOT_O_JAILBREAK_DETECTADO') || razones.has('BLOQUEO_ESTRICTO_NO_ACTIVO') || razones.has('REPORTE_INTEGRIDAD_AUSENTE');
    return this.construirResultadoIntegridad(plataforma, puntaje, Array.from(razones), bloquearPorCriticos || puntaje >= umbralBloqueo, reporte);
  }

  private construirResultadoIntegridad(plataforma: string, puntaje: number, razones: string[], bloquearInicio: boolean, reporte?: IntegridadDispositivoIntentoDto): EvaluacionIntegridadInicio {
    return {
      plataforma,
      puntaje,
      razones,
      bloquearInicio,
      requiereRevision: puntaje > 0 || razones.length > 0,
      metadatos: { plataforma, puntajeIntegridad: puntaje, razonesRiesgo: razones, reporteOriginal: reporte ?? null },
    };
  }

  private resolverPlataforma(reporte: IntegridadDispositivoIntentoDto | undefined, sistemaOperativo: string | undefined): string {
    const desdeReporte = reporte?.plataforma?.trim().toUpperCase();
    if (desdeReporte) return desdeReporte;
    const so = sistemaOperativo?.trim().toUpperCase() ?? '';
    if (so.includes('ANDROID')) return 'ANDROID';
    if (so.includes('IOS')) return 'IOS';
    return 'DESCONOCIDA';
  }

  private obtenerFlagBooleano(clave: string, valorPorDefecto: boolean): boolean {
    const valor = this.configService.get<string>(clave);
    if (valor == null) return valorPorDefecto;
    const normalizado = valor.trim().toLowerCase();
    if (normalizado === 'true') return true;
    if (normalizado === 'false') return false;
    return valorPorDefecto;
  }

  private obtenerNumeroEnRango(clave: string, valorPorDefecto: number, minimo: number, maximo: number): number {
    const valor = Number.parseInt(this.configService.get<string>(clave) ?? '', 10);
    if (!Number.isFinite(valor)) return valorPorDefecto;
    return Math.min(maximo, Math.max(minimo, valor));
  }
}
