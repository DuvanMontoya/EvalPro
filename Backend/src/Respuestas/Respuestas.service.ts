/**
 * @archivo   Respuestas.service.ts
 * @descripcion Orquesta sincronización de respuestas y delega calificación de intentos.
 * @modulo    Respuestas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  NotFoundException,
  forwardRef,
} from '@nestjs/common';
import { EstadoIntento, RolUsuario, TipoPregunta } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { TelemetriaService } from '../Telemetria/Telemetria.service';
import { CalificacionRespuestasService } from './CalificacionRespuestas.service';
import { CalificarRespuestaManualDto } from './Dto/CalificarRespuestaManual.dto';
import { SincronizarRespuestasDto } from './Dto/SincronizarRespuestas.dto';
import { ResultadoFinalDto } from './Dto/ResultadoFinal.dto';
import { SesionesExamenGateway } from '../SesionesExamen/SesionesExamen.gateway';

@Injectable()
export class RespuestasService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly calificacionRespuestasService: CalificacionRespuestasService,
    @Inject(forwardRef(() => TelemetriaService))
    private readonly telemetriaService: TelemetriaService,
    @Inject(forwardRef(() => SesionesExamenGateway))
    private readonly sesionesGateway: SesionesExamenGateway,
  ) {}

  /**
   * Sincroniza un lote de respuestas mediante upsert para evitar duplicados.
   * @param dto - Lote de respuestas por intento.
   * @param idEstudiante - UUID del estudiante autenticado.
   */
  async sincronizarLote(dto: SincronizarRespuestasDto, idEstudiante: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: dto.idIntento },
      include: {
        estudiante: {
          select: {
            nombre: true,
            apellidos: true,
          },
        },
        sesion: {
          include: {
            examen: {
              include: { preguntas: { select: { id: true } } },
            },
          },
        },
      },
    });
    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }
    if (intento.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede sincronizar intentos fuera de su institución');
    }
    if (intento.estudianteId !== idEstudiante) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }
    if (intento.estado !== EstadoIntento.EN_PROGRESO) {
      throw new BadRequestException('Solo se pueden sincronizar respuestas en intentos en progreso');
    }

    const preguntasValidas = new Set(intento.sesion.examen.preguntas.map((pregunta) => pregunta.id));
    for (const respuesta of dto.respuestas) {
      if (!preguntasValidas.has(respuesta.idPregunta)) {
        throw new BadRequestException('El lote contiene preguntas que no pertenecen al examen');
      }
    }

    await this.prisma.$transaction(async (prismaTransaccional) => {
      for (const respuesta of dto.respuestas) {
        await prismaTransaccional.respuesta.upsert({
          where: {
            intentoId_preguntaId: {
              intentoId: dto.idIntento,
              preguntaId: respuesta.idPregunta,
            },
          },
          create: {
            intentoId: dto.idIntento,
            preguntaId: respuesta.idPregunta,
            valorTexto: respuesta.valorTexto,
            opcionesSeleccionadas: this.normalizarOpcionesSeleccionadas(respuesta.opcionesSeleccionadas),
            tiempoRespuesta: respuesta.tiempoRespuesta,
            esSincronizada: true,
          },
          update: {
            valorTexto: respuesta.valorTexto,
            opcionesSeleccionadas: this.normalizarOpcionesSeleccionadas(respuesta.opcionesSeleccionadas),
            tiempoRespuesta: respuesta.tiempoRespuesta,
            esSincronizada: true,
          },
        });
      }

      await prismaTransaccional.intentoExamen.update({
        where: { id: dto.idIntento },
        data: { ultimaSincronizacion: new Date() },
      });
    });

    const preguntasRespondidas = await this.prisma.respuesta.count({
      where: { intentoId: dto.idIntento },
    });

    this.sesionesGateway.emitirProgreso(intento.sesionId, {
      idIntento: dto.idIntento,
      preguntasRespondidas,
      totalPreguntas: intento.sesion.examen.preguntas.length,
      nombreCompleto: `${intento.estudiante.nombre} ${intento.estudiante.apellidos}`.trim(),
      modoKioscoActivo: true,
      eventosFraude: 0,
      estadoIntento: intento.estado,
    });

    return { sincronizadas: dto.respuestas.length };
  }

  /**
   * Finaliza un intento y calcula su puntaje según reglas por tipo de pregunta.
   * @param idIntento - UUID del intento.
   * @param idEstudiante - UUID del estudiante autenticado.
   */
  async finalizar(idIntento: string, idEstudiante: string, idInstitucion: string | null): Promise<ResultadoFinalDto> {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: {
        respuestas: true,
        estudiante: {
          select: {
            nombre: true,
            apellidos: true,
          },
        },
        sesion: {
          include: {
            examen: {
              include: {
                preguntas: {
                  include: { opciones: true },
                },
              },
            },
          },
        },
      },
    });

    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }
    if (intento.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede finalizar intentos fuera de su institución');
    }
    if (intento.estudianteId !== idEstudiante) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }
    if (intento.estado !== EstadoIntento.EN_PROGRESO) {
      throw new BadRequestException('El intento no se encuentra en progreso');
    }
    const { puntajeObtenido, porcentaje } = await this.calificacionRespuestasService.calificarIntento(intento.id);
    await this.telemetriaService.detectarAnomalias(intento.id);
    const mostrarPuntaje = intento.sesion.examen.mostrarPuntaje;
    this.sesionesGateway.emitirProgreso(intento.sesionId, {
      idIntento,
      preguntasRespondidas: intento.respuestas.length,
      totalPreguntas: intento.sesion.examen.preguntas.length,
      nombreCompleto: `${intento.estudiante.nombre} ${intento.estudiante.apellidos}`.trim(),
      modoKioscoActivo: true,
      eventosFraude: 0,
      estadoIntento: EstadoIntento.ENVIADO,
    });

    return {
      idIntento,
      mostrarPuntaje,
      puntajeObtenido: mostrarPuntaje ? puntajeObtenido : null,
      porcentaje: mostrarPuntaje ? porcentaje : null,
    };
  }

  /**
   * Lista respuestas abiertas pendientes de calificación manual para panel de gestión.
   */
  async listarPendientesCalificacion(rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const condiciones: Record<string, unknown>[] = [
      {
        pregunta: {
          tipo: {
            in: [TipoPregunta.RESPUESTA_ABIERTA, TipoPregunta.ABIERTA],
          },
        },
      },
      {
        intento: {
          estado: EstadoIntento.ENVIADO,
        },
      },
      {
        puntajeObtenido: null,
      },
    ];

    if (rol !== RolUsuario.SUPERADMINISTRADOR) {
      if (!idInstitucion) {
        throw new ForbiddenException('Actor sin institución asociada');
      }
      condiciones.push({
        intento: {
          idInstitucion,
        },
      });
    }

    if (rol === RolUsuario.DOCENTE) {
      condiciones.push({
        intento: {
          sesion: {
            creadaPorId: idUsuario,
          },
        },
      });
    }

    const respuestas = await this.prisma.respuesta.findMany({
      where: {
        AND: condiciones,
      },
      include: {
        pregunta: {
          select: {
            id: true,
            enunciado: true,
            puntaje: true,
            tipo: true,
          },
        },
        intento: {
          include: {
            estudiante: {
              select: {
                id: true,
                nombre: true,
                apellidos: true,
                correo: true,
              },
            },
            sesion: {
              include: {
                examen: {
                  select: {
                    id: true,
                    titulo: true,
                  },
                },
              },
            },
          },
        },
      },
      orderBy: { guardadoEn: 'asc' },
    });

    return respuestas.map((respuesta) => ({
      id: respuesta.id,
      idIntento: respuesta.intentoId,
      idPregunta: respuesta.preguntaId,
      valorTexto: respuesta.valorTexto,
      opcionesSeleccionadas: respuesta.opcionesSeleccionadas,
      guardadoEn: respuesta.guardadoEn,
      tiempoRespuesta: respuesta.tiempoRespuesta,
      pregunta: respuesta.pregunta,
      estudiante: respuesta.intento.estudiante,
      sesion: {
        id: respuesta.intento.sesion.id,
        codigoAcceso: respuesta.intento.sesion.codigoAcceso,
        examen: respuesta.intento.sesion.examen,
      },
    }));
  }

  /**
   * Calcula puntajes de todos los intentos en progreso de una sesión finalizada.
   * @param idSesion - UUID de la sesión.
   */
  async calcularPuntajesTodosIntentos(idSesion: string): Promise<void> {
    const intentos = await this.prisma.intentoExamen.findMany({
      where: {
        sesionId: idSesion,
        estado: { in: [EstadoIntento.EN_PROGRESO, EstadoIntento.SINCRONIZACION_PENDIENTE, EstadoIntento.ENVIADO] },
      },
      select: { id: true },
    });
    for (const intento of intentos) {
      await this.calificacionRespuestasService.calificarIntento(intento.id);
      await this.telemetriaService.detectarAnomalias(intento.id);
    }
  }

  /**
   * Califica manualmente una respuesta abierta y recalcúla el puntaje consolidado del intento.
   * @param idRespuesta - UUID de la respuesta abierta.
   * @param dto - Puntaje y observación del docente.
   * @param rol - Rol del usuario autenticado.
   * @param idUsuario - UUID del usuario autenticado.
   */
  async calificarManual(
    idRespuesta: string,
    dto: CalificarRespuestaManualDto,
    rol: RolUsuario,
    idUsuario: string,
    idInstitucion: string | null,
  ) {
    return this.calificacionRespuestasService.calificarManual(idRespuesta, dto, rol, idUsuario, idInstitucion);
  }

  private normalizarOpcionesSeleccionadas(opcionesSeleccionadas: string[]): string[] {
    const vistas = new Set<string>();
    const normalizadas: string[] = [];
    for (const opcion of opcionesSeleccionadas) {
      const valor = opcion.trim().toUpperCase();
      if (!valor || vistas.has(valor)) {
        continue;
      }
      vistas.add(valor);
      normalizadas.push(valor);
    }
    return normalizadas;
  }
}
