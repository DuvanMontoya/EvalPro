/**
 * @archivo   CalificacionRespuestas.service.ts
 * @descripcion Centraliza la calificación automática y manual de respuestas e intentos.
 * @modulo    Respuestas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoIntento, RolUsuario, TipoPregunta } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { calcularPorcentaje, compararConjuntosLetras } from '../Comun/Utilidades/CalculadorPuntaje.util';
import { CalificarRespuestaManualDto } from './Dto/CalificarRespuestaManual.dto';

@Injectable()
export class CalificacionRespuestasService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Califica automáticamente un intento según reglas por tipo de pregunta.
   * @param idIntento - UUID del intento a calificar.
   * @returns Puntaje y porcentaje consolidados del intento.
   */
  async calificarIntento(idIntento: string): Promise<{ puntajeObtenido: number; porcentaje: number }> {
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

    let puntajeObtenido = 0;
    await this.prisma.$transaction(async (prismaTransaccional) => {
      for (const pregunta of intento.sesion.examen.preguntas) {
        const respuesta = intento.respuestas.find((item) => item.preguntaId === pregunta.id);
        if (!respuesta) {
          continue;
        }

        const letrasCorrectas = pregunta.opciones.filter((opcion) => opcion.esCorrecta).map((opcion) => opcion.letra);
        const resultado = this.evaluarRespuesta(pregunta.tipo, pregunta.puntaje, letrasCorrectas, respuesta.opcionesSeleccionadas);
        let puntajeRespuesta = resultado.puntajeObtenido;
        if (pregunta.tipo === TipoPregunta.RESPUESTA_ABIERTA) {
          puntajeRespuesta = typeof respuesta.puntajeObtenido === 'number' ? respuesta.puntajeObtenido : null;
        }

        if (typeof puntajeRespuesta === 'number') {
          puntajeObtenido += puntajeRespuesta;
        }
        await prismaTransaccional.respuesta.update({
          where: { intentoId_preguntaId: { intentoId: intento.id, preguntaId: pregunta.id } },
          data: { esCorrecta: resultado.esCorrecta, puntajeObtenido: puntajeRespuesta },
        });
      }

      const porcentaje = calcularPorcentaje(puntajeObtenido, intento.sesion.examen.puntajeMaximo);
      await prismaTransaccional.intentoExamen.update({
        where: { id: intento.id },
        data: { estado: EstadoIntento.ENVIADO, fechaEnvio: new Date(), puntajeObtenido, porcentaje },
      });
    });

    const porcentaje = calcularPorcentaje(puntajeObtenido, intento.sesion.examen.puntajeMaximo);
    return { puntajeObtenido, porcentaje };
  }

  /**
   * Califica manualmente una respuesta abierta y actualiza el consolidado del intento.
   * @param idRespuesta - UUID de la respuesta abierta.
   * @param dto - Puntaje y observación opcional.
   * @param rol - Rol del usuario autenticado.
   * @param idUsuario - UUID del usuario autenticado.
   */
  async calificarManual(idRespuesta: string, dto: CalificarRespuestaManualDto, rol: RolUsuario, idUsuario: string) {
    const respuesta = await this.prisma.respuesta.findUnique({
      where: { id: idRespuesta },
      include: {
        pregunta: { select: { tipo: true, puntaje: true } },
        intento: { include: { sesion: true } },
      },
    });
    if (!respuesta) {
      throw new NotFoundException('Respuesta no encontrada');
    }
    if (respuesta.pregunta.tipo !== TipoPregunta.RESPUESTA_ABIERTA) {
      throw new BadRequestException('Solo se puede calificar manualmente preguntas abiertas');
    }
    if (rol === RolUsuario.DOCENTE && respuesta.intento.sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos para calificar esta respuesta');
    }
    if (dto.puntajeObtenido > respuesta.pregunta.puntaje) {
      throw new BadRequestException('El puntaje manual no puede superar el valor máximo de la pregunta');
    }

    const esCorrecta = dto.puntajeObtenido === respuesta.pregunta.puntaje ? true : dto.puntajeObtenido === 0 ? false : null;
    const fechaCalificacion = new Date();
    const respuestaActualizada = await this.prisma.respuesta.update({
      where: { id: idRespuesta },
      data: {
        puntajeObtenido: dto.puntajeObtenido,
        esCorrecta,
        observacionCalificacion: dto.observacion ?? null,
        fechaCalificacion,
      },
    });
    const totales = await this.recalcularTotalesIntento(respuesta.intentoId);

    return {
      idRespuesta: respuestaActualizada.id,
      puntajeObtenido: respuestaActualizada.puntajeObtenido,
      observacion: respuestaActualizada.observacionCalificacion ?? null,
      fechaCalificacion: respuestaActualizada.fechaCalificacion?.toISOString() ?? fechaCalificacion.toISOString(),
      puntajeIntento: totales.puntajeObtenido,
      porcentajeIntento: totales.porcentaje,
    };
  }

  /**
   * Recalcula puntaje y porcentaje del intento con base en sus respuestas actuales.
   * @param idIntento - UUID del intento a consolidar.
   * @returns Puntaje y porcentaje actualizados.
   */
  async recalcularTotalesIntento(idIntento: string): Promise<{ puntajeObtenido: number; porcentaje: number }> {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: { respuestas: true, sesion: { include: { examen: true } } },
    });
    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }

    const puntajeObtenido = intento.respuestas.reduce(
      (total, respuesta) => total + (typeof respuesta.puntajeObtenido === 'number' ? respuesta.puntajeObtenido : 0),
      0,
    );
    const porcentaje = calcularPorcentaje(puntajeObtenido, intento.sesion.examen.puntajeMaximo);
    await this.prisma.intentoExamen.update({ where: { id: idIntento }, data: { puntajeObtenido, porcentaje } });
    return { puntajeObtenido, porcentaje };
  }

  private evaluarRespuesta(
    tipo: TipoPregunta,
    puntajePregunta: number,
    letrasCorrectas: string[],
    opcionesSeleccionadas: string[],
  ): { esCorrecta: boolean | null; puntajeObtenido: number | null } {
    if (tipo === TipoPregunta.RESPUESTA_ABIERTA) {
      return { esCorrecta: null, puntajeObtenido: null };
    }
    if (tipo === TipoPregunta.SELECCION_MULTIPLE) {
      const esCorrecta = compararConjuntosLetras(opcionesSeleccionadas, letrasCorrectas);
      return { esCorrecta, puntajeObtenido: esCorrecta ? puntajePregunta : 0 };
    }

    const esCorrecta = opcionesSeleccionadas[0] === letrasCorrectas[0];
    return { esCorrecta, puntajeObtenido: esCorrecta ? puntajePregunta : 0 };
  }
}
