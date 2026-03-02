/**
 * @archivo   Preguntas.service.ts
 * @descripcion Gestiona CRUD de preguntas y consistencia de métricas del examen padre.
 * @modulo    Preguntas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoExamen, TipoPregunta } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { CrearPreguntaDto } from './Dto/CrearPregunta.dto';
import { ActualizarPreguntaDto } from './Dto/ActualizarPregunta.dto';
import { ReordenarPreguntasDto } from './Dto/ReordenarPreguntas.dto';
@Injectable()
export class PreguntasService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Lista preguntas de un examen ordenadas de forma ascendente.
   * @param idExamen - UUID del examen.
   */
  async listar(idExamen: string) {
    return this.prisma.pregunta.findMany({
      where: { examenId: idExamen },
      include: { opciones: { orderBy: { orden: 'asc' } } },
      orderBy: { orden: 'asc' },
    });
  }

  /**
   * Crea una pregunta usando transacción y actualiza acumulados del examen.
   * @param idExamen - UUID del examen.
   * @param dto - Datos de la pregunta.
   */
  async crear(idExamen: string, dto: CrearPreguntaDto) {
    return this.prisma.$transaction(async (prismaTransaccional) => {
      const examen = await prismaTransaccional.examen.findUnique({ where: { id: idExamen }, include: { preguntas: true } });
      if (!examen) {
        throw new NotFoundException('Examen no encontrado');
      }
      if (examen.estado !== EstadoExamen.BORRADOR) {
        throw new BadRequestException('Solo se pueden agregar preguntas a exámenes en borrador');
      }
      const orden = examen.preguntas.length + 1;
      this.validarOpcionesSegunTipo(dto.tipo, dto.opciones ?? []);
      const pregunta = await prismaTransaccional.pregunta.create({
        data: {
          enunciado: dto.enunciado,
          tipo: dto.tipo,
          orden,
          puntaje: dto.puntaje,
          tiempoSugerido: dto.tiempoSugerido,
          imagenUrl: dto.imagenUrl,
          examenId: idExamen,
        },
      });
      if (dto.tipo !== TipoPregunta.RESPUESTA_ABIERTA && dto.opciones) {
        await prismaTransaccional.opcionRespuesta.createMany({
          data: dto.opciones.map((opcion, indice) => ({
            letra: opcion.letra,
            contenido: opcion.contenido,
            esCorrecta: opcion.esCorrecta,
            orden: opcion.orden ?? indice + 1,
            preguntaId: pregunta.id,
          })),
        });
      }
      await prismaTransaccional.examen.update({
        where: { id: idExamen },
        data: {
          totalPreguntas: examen.totalPreguntas + 1,
          puntajeMaximo: examen.puntajeMaximo + dto.puntaje,
        },
      });
      return prismaTransaccional.pregunta.findUnique({
        where: { id: pregunta.id },
        include: { opciones: { orderBy: { orden: 'asc' } } },
      });
    });
  }

  /**
   * Actualiza una pregunta verificando propiedad del examen y estado borrador.
   * @param idExamen - UUID del examen.
   * @param idPregunta - UUID de la pregunta.
   * @param dto - Datos de actualización.
   * @param idDocente - UUID del docente.
   */
  async actualizar(idExamen: string, idPregunta: string, dto: ActualizarPreguntaDto, idDocente: string) {
    const examen = await this.validarExamenEditable(idExamen, idDocente);
    const pregunta = await this.prisma.pregunta.findUnique({ where: { id: idPregunta } });
    if (!pregunta || pregunta.examenId !== idExamen) {
      throw new NotFoundException('Pregunta no encontrada');
    }
    const actualizada = await this.prisma.pregunta.update({
      where: { id: idPregunta },
      data: {
        enunciado: dto.enunciado,
        tipo: dto.tipo,
        puntaje: dto.puntaje,
        tiempoSugerido: dto.tiempoSugerido,
        imagenUrl: dto.imagenUrl,
      },
      include: { opciones: true },
    });
    if (typeof dto.puntaje === 'number' && dto.puntaje !== pregunta.puntaje) {
      await this.prisma.examen.update({
        where: { id: examen.id },
        data: { puntajeMaximo: examen.puntajeMaximo - pregunta.puntaje + dto.puntaje },
      });
    }
    return actualizada;
  }

  /**
   * Elimina una pregunta y descuenta su puntaje del examen padre.
   * @param idExamen - UUID del examen.
   * @param idPregunta - UUID de la pregunta.
   * @param idDocente - UUID del docente.
   */
  async eliminar(idExamen: string, idPregunta: string, idDocente: string) {
    const examen = await this.validarExamenEditable(idExamen, idDocente);
    const pregunta = await this.prisma.pregunta.findUnique({ where: { id: idPregunta } });
    if (!pregunta || pregunta.examenId !== idExamen) {
      throw new NotFoundException('Pregunta no encontrada');
    }
    await this.prisma.pregunta.delete({ where: { id: idPregunta } });
    await this.prisma.examen.update({
      where: { id: examen.id },
      data: {
        totalPreguntas: Math.max(0, examen.totalPreguntas - 1),
        puntajeMaximo: Math.max(0, examen.puntajeMaximo - pregunta.puntaje),
      },
    });
    return { eliminada: true };
  }

  /**
   * Reordena preguntas existentes dentro del examen indicado.
   * @param idExamen - UUID del examen.
   * @param dto - Lista con nuevo orden.
   * @param idDocente - UUID del docente.
   */
  async reordenar(idExamen: string, dto: ReordenarPreguntasDto, idDocente: string) {
    await this.validarExamenEditable(idExamen, idDocente);
    await this.prisma.$transaction(
      dto.preguntas.map((entrada) =>
        this.prisma.pregunta.update({
          where: { id: entrada.idPregunta },
          data: { orden: entrada.orden },
        }),
      ),
    );
    return this.listar(idExamen);
  }
  private validarOpcionesSegunTipo(tipo: TipoPregunta, opciones: { esCorrecta: boolean }[]): void {
    if (tipo === TipoPregunta.RESPUESTA_ABIERTA) {
      return;
    }
    const totalCorrectas = opciones.filter((opcion) => opcion.esCorrecta).length;
    if (
      (tipo === TipoPregunta.OPCION_MULTIPLE || tipo === TipoPregunta.VERDADERO_FALSO) &&
      totalCorrectas !== 1
    ) {
      throw new BadRequestException('Debe existir exactamente una opción correcta');
    }
    if (tipo === TipoPregunta.SELECCION_MULTIPLE && totalCorrectas < 1) {
      throw new BadRequestException('Debe existir al menos una opción correcta');
    }
  }
  private async validarExamenEditable(idExamen: string, idDocente: string) {
    const examen = await this.prisma.examen.findUnique({ where: { id: idExamen } });
    if (!examen) {
      throw new NotFoundException('Examen no encontrado');
    }
    if (examen.creadoPorId !== idDocente) {
      throw new ForbiddenException('No tiene permisos sobre este examen');
    }
    if (examen.estado !== EstadoExamen.BORRADOR) {
      throw new BadRequestException('Solo se pueden modificar preguntas en borrador');
    }
    return examen;
  }
}
