/**
 * @archivo   Respuestas.service.ts
 * @descripcion Sincroniza respuestas y calcula puntajes finales de intentos.
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
import { EstadoIntento, TipoPregunta } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { calcularPorcentaje, compararConjuntosLetras } from '../Comun/Utilidades/CalculadorPuntaje.util';
import { TelemetriaService } from '../Telemetria/Telemetria.service';
import { SincronizarRespuestasDto } from './Dto/SincronizarRespuestas.dto';
import { ResultadoFinalDto } from './Dto/ResultadoFinal.dto';
@Injectable()
export class RespuestasService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(forwardRef(() => TelemetriaService))
    private readonly telemetriaService: TelemetriaService,
  ) {}

  /**
   * Sincroniza un lote de respuestas mediante upsert para evitar duplicados.
   * @param dto - Lote de respuestas por intento.
   * @param idEstudiante - UUID del estudiante autenticado.
   */
  async sincronizarLote(dto: SincronizarRespuestasDto, idEstudiante: string) {
    const intento = await this.prisma.intentoExamen.findUnique({ where: { id: dto.idIntento } });
    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }
    if (intento.estudianteId !== idEstudiante) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }
    await this.prisma.$transaction(
      dto.respuestas.map((respuesta) =>
        this.prisma.respuesta.upsert({
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
            opcionesSeleccionadas: respuesta.opcionesSeleccionadas,
            tiempoRespuesta: respuesta.tiempoRespuesta,
            esSincronizada: true,
          },
          update: {
            valorTexto: respuesta.valorTexto,
            opcionesSeleccionadas: respuesta.opcionesSeleccionadas,
            tiempoRespuesta: respuesta.tiempoRespuesta,
            esSincronizada: true,
          },
        }),
      ),
    );
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
    const { puntajeObtenido, porcentaje } = await this.calificarIntento(intento.id);
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
      await this.calificarIntento(intento.id);
      await this.telemetriaService.detectarAnomalias(intento.id);
    }
  }
  private async calificarIntento(idIntento: string): Promise<{ puntajeObtenido: number; porcentaje: number }> {
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
    for (const pregunta of intento.sesion.examen.preguntas) {
      const respuesta = intento.respuestas.find((item) => item.preguntaId === pregunta.id);
      if (!respuesta) {
        continue;
      }
      const letrasCorrectas = pregunta.opciones.filter((opcion) => opcion.esCorrecta).map((opcion) => opcion.letra);
      let esCorrecta: boolean | null = false;
      if (pregunta.tipo === TipoPregunta.OPCION_MULTIPLE || pregunta.tipo === TipoPregunta.VERDADERO_FALSO) {
        esCorrecta = respuesta.opcionesSeleccionadas[0] === letrasCorrectas[0];
      } else if (pregunta.tipo === TipoPregunta.SELECCION_MULTIPLE) {
        esCorrecta = compararConjuntosLetras(respuesta.opcionesSeleccionadas, letrasCorrectas);
      } else if (pregunta.tipo === TipoPregunta.RESPUESTA_ABIERTA) {
        esCorrecta = null;
      }
      const puntajeRespuesta = esCorrecta ? pregunta.puntaje : 0;
      if (esCorrecta) {
        puntajeObtenido += pregunta.puntaje;
      }
      await this.prisma.respuesta.update({
        where: { intentoId_preguntaId: { intentoId: intento.id, preguntaId: pregunta.id } },
        data: {
          esCorrecta,
          puntajeObtenido: puntajeRespuesta,
        },
      });
    }
    const porcentaje = calcularPorcentaje(puntajeObtenido, intento.sesion.examen.puntajeMaximo);
    await this.prisma.intentoExamen.update({
      where: { id: intento.id },
      data: {
        estado: EstadoIntento.ENVIADO,
        fechaEnvio: new Date(),
        puntajeObtenido,
        porcentaje,
      },
    });
    return { puntajeObtenido, porcentaje };
  }
}
