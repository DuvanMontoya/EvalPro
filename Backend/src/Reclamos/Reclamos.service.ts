import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoReclamo, EstadoResultado, RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { CrearReclamoDto } from './Dto/CrearReclamo.dto';
import { ResolverReclamoDto } from './Dto/ResolverReclamo.dto';

@Injectable()
export class ReclamosService {
  constructor(private readonly prisma: PrismaService) {}

  async listar(actor: UsuarioAutenticado) {
    const condiciones: Record<string, unknown>[] = [];

    if (actor.rol !== RolUsuario.SUPERADMINISTRADOR) {
      if (!actor.idInstitucion) {
        throw new ForbiddenException('Actor sin institución asociada');
      }
      condiciones.push({
        resultado: {
          intento: {
            idInstitucion: actor.idInstitucion,
          },
        },
      });
    }

    if (actor.rol === RolUsuario.DOCENTE) {
      condiciones.push({
        resultado: {
          intento: {
            sesion: {
              creadaPorId: actor.id,
            },
          },
        },
      });
    }

    const where = condiciones.length > 0 ? { AND: condiciones } : {};
    const reclamos = await this.prisma.reclamoCalificacion.findMany({
      where,
      include: {
        estudiante: {
          select: {
            id: true,
            nombre: true,
            apellidos: true,
            correo: true,
          },
        },
        resueltoPor: {
          select: {
            id: true,
            nombre: true,
            apellidos: true,
            correo: true,
          },
        },
        resultado: {
          include: {
            intento: {
              include: {
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
        },
      },
      orderBy: { presentadoEn: 'desc' },
    });

    return reclamos.map((reclamo) => ({
      id: reclamo.id,
      resultadoId: reclamo.resultadoId,
      idEstudiante: reclamo.idEstudiante,
      idPregunta: reclamo.idPregunta,
      motivo: reclamo.motivo,
      estado: reclamo.estado,
      presentadoEn: reclamo.presentadoEn,
      resolverEn: reclamo.resolverEn,
      resolucion: reclamo.resolucion,
      puntajeAnterior: reclamo.puntajeAnterior,
      puntajeNuevo: reclamo.puntajeNuevo,
      estudiante: reclamo.estudiante,
      resueltoPor: reclamo.resueltoPor,
      resultado: {
        id: reclamo.resultado.id,
        estado: reclamo.resultado.estado,
        puntajeTotal: reclamo.resultado.puntajeTotal,
        puntajeMaximoPosible: reclamo.resultado.puntajeMaximoPosible,
        porcentaje: reclamo.resultado.porcentaje,
      },
      intento: {
        id: reclamo.resultado.intento.id,
        estado: reclamo.resultado.intento.estado,
        sesionId: reclamo.resultado.intento.sesionId,
        fechaEnvio: reclamo.resultado.intento.fechaEnvio,
      },
      sesion: {
        id: reclamo.resultado.intento.sesion.id,
        codigoAcceso: reclamo.resultado.intento.sesion.codigoAcceso,
        examen: reclamo.resultado.intento.sesion.examen,
      },
    }));
  }

  async crear(idResultado: string, dto: CrearReclamoDto, actor: UsuarioAutenticado) {
    const resultado = await this.prisma.resultadoIntento.findUnique({
      where: { id: idResultado },
      include: { intento: true },
    });
    if (!resultado) {
      throw new NotFoundException('Resultado no encontrado');
    }
    if (resultado.intento.estudianteId !== actor.id) {
      throw new ForbiddenException('Solo el estudiante dueño puede presentar reclamos');
    }
    if (resultado.intento.idInstitucion !== actor.idInstitucion) {
      throw new ForbiddenException('No puede reclamar resultados de otra institución');
    }

    const reclamo = await this.prisma.reclamoCalificacion.create({
      data: {
        resultadoId: idResultado,
        idEstudiante: actor.id,
        idPregunta: dto.idPregunta ?? null,
        motivo: dto.motivo.trim(),
        estado: EstadoReclamo.PRESENTADO,
        resolverEn: new Date(Date.now() + 7 * 24 * 60 * 60_000),
      },
    });

    await this.prisma.resultadoIntento.update({
      where: { id: idResultado },
      data: { estado: EstadoResultado.EN_RECLAMO },
    });

    return reclamo;
  }

  async resolver(idReclamo: string, dto: ResolverReclamoDto, actor: UsuarioAutenticado) {
    const reclamo = await this.prisma.reclamoCalificacion.findUnique({
      where: { id: idReclamo },
      include: {
        resultado: {
          include: {
            intento: {
              include: { sesion: true },
            },
          },
        },
      },
    });
    if (!reclamo) {
      throw new NotFoundException('Reclamo no encontrado');
    }

    const idInstitucionIntento = reclamo.resultado.intento.idInstitucion;
    if (actor.rol !== RolUsuario.SUPERADMINISTRADOR && actor.idInstitucion !== idInstitucionIntento) {
      throw new ForbiddenException('No puede resolver reclamos fuera de su institución');
    }

    if (actor.rol === RolUsuario.DOCENTE && reclamo.resultado.intento.sesion.creadaPorId !== actor.id) {
      throw new ForbiddenException('Docente sin permisos sobre este reclamo');
    }

    if (reclamo.estado !== EstadoReclamo.PRESENTADO && reclamo.estado !== EstadoReclamo.EN_REVISION) {
      throw new BadRequestException('El reclamo no está en estado resoluble');
    }

    const puntajeAnterior = reclamo.resultado.puntajeTotal;
    const puntajeMaximo = reclamo.resultado.puntajeMaximoPosible;
    const puntajeNuevo =
      dto.aprobar && typeof dto.puntajeNuevo === 'number'
        ? Math.max(0, Math.min(puntajeMaximo, dto.puntajeNuevo))
        : puntajeAnterior;
    const porcentaje = puntajeMaximo > 0 ? Number(((puntajeNuevo / puntajeMaximo) * 100).toFixed(2)) : 0;

    const resultadoEstado = dto.aprobar ? EstadoResultado.RECTIFICADO : EstadoResultado.OFICIAL;
    await this.prisma.resultadoIntento.update({
      where: { id: reclamo.resultadoId },
      data: {
        puntajeTotal: puntajeNuevo,
        porcentaje,
        estado: resultadoEstado,
        version: { increment: 1 },
      },
    });

    return this.prisma.reclamoCalificacion.update({
      where: { id: idReclamo },
      data: {
        estado: dto.aprobar ? EstadoReclamo.RESUELTO : EstadoReclamo.RECHAZADO,
        resueltoPorId: actor.id,
        resolucion: dto.resolucion.trim(),
        puntajeAnterior,
        puntajeNuevo,
      },
    });
  }
}
