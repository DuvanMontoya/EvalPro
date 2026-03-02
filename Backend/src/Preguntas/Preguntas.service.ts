/**
 * @archivo   Preguntas.service.ts
 * @descripcion Gestiona CRUD de preguntas y consistencia de métricas del examen padre.
 * @modulo    Preguntas
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoExamen, Prisma, TipoPregunta } from '@prisma/client';
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
   * @param idDocente - UUID del docente autenticado.
   */
  async listar(idExamen: string, idDocente: string, idInstitucion: string | null) {
    await this.validarPropiedadExamen(idExamen, idDocente, idInstitucion);
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
   * @param idDocente - UUID del docente autenticado.
   */
  async crear(idExamen: string, dto: CrearPreguntaDto, idDocente: string, idInstitucion: string | null) {
    return this.prisma.$transaction(async (prismaTransaccional) => {
      const examen = await this.validarExamenEditable(idExamen, idDocente, idInstitucion, prismaTransaccional);
      const totalActual = await prismaTransaccional.pregunta.count({ where: { examenId: idExamen } });
      const orden = totalActual + 1;
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
      if (dto.tipo !== TipoPregunta.RESPUESTA_ABIERTA && dto.tipo !== TipoPregunta.ABIERTA && dto.opciones) {
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
  async actualizar(idExamen: string, idPregunta: string, dto: ActualizarPreguntaDto, idDocente: string, idInstitucion: string | null) {
    const examen = await this.validarExamenEditable(idExamen, idDocente, idInstitucion);
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
  async eliminar(idExamen: string, idPregunta: string, idDocente: string, idInstitucion: string | null) {
    const examen = await this.validarExamenEditable(idExamen, idDocente, idInstitucion);
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
  async reordenar(idExamen: string, dto: ReordenarPreguntasDto, idDocente: string, idInstitucion: string | null) {
    await this.validarExamenEditable(idExamen, idDocente, idInstitucion);
    const idsSolicitados = dto.preguntas.map((entrada) => entrada.idPregunta);
    const preguntas = await this.prisma.pregunta.findMany({
      where: { examenId: idExamen, id: { in: idsSolicitados } },
      select: { id: true },
    });
    if (preguntas.length !== idsSolicitados.length) {
      throw new BadRequestException('La lista de preguntas incluye elementos fuera del examen');
    }
    await this.prisma.$transaction(async (prismaTransaccional) => {
      for (const entrada of dto.preguntas) {
        await prismaTransaccional.pregunta.update({
          where: { id: entrada.idPregunta },
          data: { orden: entrada.orden },
        });
      }
    });
    return this.listar(idExamen, idDocente, idInstitucion);
  }
  private validarOpcionesSegunTipo(tipo: TipoPregunta, opciones: { esCorrecta: boolean }[]): void {
    if (tipo === TipoPregunta.RESPUESTA_ABIERTA || tipo === TipoPregunta.ABIERTA) {
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

  private async validarExamenEditable(
    idExamen: string,
    idDocente: string,
    idInstitucion: string | null,
    prismaTransaccional: Prisma.TransactionClient | PrismaService = this.prisma,
  ) {
    const examen = await this.validarPropiedadExamen(idExamen, idDocente, idInstitucion, prismaTransaccional);
    if (examen.estado !== EstadoExamen.BORRADOR) {
      throw new BadRequestException('Solo se pueden modificar preguntas en borrador');
    }
    return examen;
  }
  private async validarPropiedadExamen(
    idExamen: string,
    idDocente: string,
    idInstitucion: string | null,
    prismaTransaccional: Prisma.TransactionClient | PrismaService = this.prisma,
  ) {
    const examen = await prismaTransaccional.examen.findUnique({ where: { id: idExamen } });
    if (!examen) {
      throw new NotFoundException('Examen no encontrado');
    }
    if (examen.creadoPorId !== idDocente) {
      throw new ForbiddenException('No tiene permisos sobre este examen');
    }
    if (examen.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No tiene permisos sobre exámenes de otra institución');
    }
    return examen;
  }
}
