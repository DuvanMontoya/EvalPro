import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoReclamo, EstadoResultado, RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { CrearReclamoDto } from './Dto/CrearReclamo.dto';
import { ResolverReclamoDto } from './Dto/ResolverReclamo.dto';

@Injectable()
export class ReclamosService {
  constructor(private readonly prisma: PrismaService) {}

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
