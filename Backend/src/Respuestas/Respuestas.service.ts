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
import { EstadoIntento, RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { TelemetriaService } from '../Telemetria/Telemetria.service';
import { CalificacionRespuestasService } from './CalificacionRespuestas.service';
import { CalificarRespuestaManualDto } from './Dto/CalificarRespuestaManual.dto';
import { SincronizarRespuestasDto } from './Dto/SincronizarRespuestas.dto';
import { ResultadoFinalDto } from './Dto/ResultadoFinal.dto';

@Injectable()
export class RespuestasService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly calificacionRespuestasService: CalificacionRespuestasService,
    @Inject(forwardRef(() => TelemetriaService))
    private readonly telemetriaService: TelemetriaService,
  ) {}

  /**
   * Sincroniza un lote de respuestas mediante upsert para evitar duplicados.
   * @param dto - Lote de respuestas por intento.
   * @param idEstudiante - UUID del estudiante autenticado.
   */
  async sincronizarLote(dto: SincronizarRespuestasDto, idEstudiante: string) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: dto.idIntento },
      include: {
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
    });

    return { sincronizadas: dto.respuestas.length };
  }

  /**
   * Finaliza un intento y calcula su puntaje según reglas por tipo de pregunta.
   * @param idIntento - UUID del intento.
   * @param idEstudiante - UUID del estudiante autenticado.
   */
  async finalizar(idIntento: string, idEstudiante: string): Promise<ResultadoFinalDto> {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: {
        respuestas: true,
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
    if (intento.estudianteId !== idEstudiante) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }
    if (intento.estado !== EstadoIntento.EN_PROGRESO) {
      throw new BadRequestException('El intento no se encuentra en progreso');
    }
    const { puntajeObtenido, porcentaje } = await this.calificacionRespuestasService.calificarIntento(intento.id);
    await this.telemetriaService.detectarAnomalias(intento.id);
    const mostrarPuntaje = intento.sesion.examen.mostrarPuntaje;
    return {
      idIntento,
      mostrarPuntaje,
      puntajeObtenido: mostrarPuntaje ? puntajeObtenido : null,
      porcentaje: mostrarPuntaje ? porcentaje : null,
    };
  }

  /**
   * Calcula puntajes de todos los intentos en progreso de una sesión finalizada.
   * @param idSesion - UUID de la sesión.
   */
  async calcularPuntajesTodosIntentos(idSesion: string): Promise<void> {
    const intentos = await this.prisma.intentoExamen.findMany({
      where: { sesionId: idSesion, estado: EstadoIntento.EN_PROGRESO },
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
  async calificarManual(idRespuesta: string, dto: CalificarRespuestaManualDto, rol: RolUsuario, idUsuario: string) {
    return this.calificacionRespuestasService.calificarManual(idRespuesta, dto, rol, idUsuario);
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
