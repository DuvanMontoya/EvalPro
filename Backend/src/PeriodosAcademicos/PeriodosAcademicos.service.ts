import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { ActualizarEstadoPeriodoDto } from './Dto/ActualizarEstadoPeriodo.dto';
import { CrearPeriodoAcademicoDto } from './Dto/CrearPeriodoAcademico.dto';

@Injectable()
export class PeriodosAcademicosService {
  constructor(private readonly prisma: PrismaService) {}

  async listar(actor: UsuarioAutenticado, idInstitucionFiltro?: string) {
    const where: Record<string, unknown> = {};

    if (actor.rol === RolUsuario.SUPERADMINISTRADOR) {
      if (idInstitucionFiltro) {
        where.idInstitucion = idInstitucionFiltro;
      }
    } else {
      if (!actor.idInstitucion) {
        throw new ForbiddenException('Actor sin institución asociada');
      }
      where.idInstitucion = actor.idInstitucion;
    }

    return this.prisma.periodoAcademico.findMany({
      where,
      orderBy: { fechaInicio: 'desc' },
    });
  }

  async crear(dto: CrearPeriodoAcademicoDto, actor: UsuarioAutenticado) {
    const idInstitucion = this.resolverInstitucionObjetivo(actor, dto.idInstitucion);
    const fechaInicio = new Date(dto.fechaInicio);
    const fechaFin = new Date(dto.fechaFin);

    if (Number.isNaN(fechaInicio.getTime()) || Number.isNaN(fechaFin.getTime())) {
      throw new BadRequestException('Fechas inválidas');
    }

    if (fechaFin <= fechaInicio) {
      throw new BadRequestException('fechaFin debe ser mayor que fechaInicio');
    }

    const activo = dto.activo ?? true;
    if (activo) {
      await this.prisma.periodoAcademico.updateMany({
        where: { idInstitucion, activo: true },
        data: { activo: false },
      });
    }

    return this.prisma.periodoAcademico.create({
      data: {
        idInstitucion,
        nombre: dto.nombre.trim(),
        fechaInicio,
        fechaFin,
        activo,
      },
    });
  }

  async actualizarEstado(idPeriodo: string, dto: ActualizarEstadoPeriodoDto, actor: UsuarioAutenticado) {
    const periodo = await this.prisma.periodoAcademico.findUnique({ where: { id: idPeriodo } });
    if (!periodo) {
      throw new NotFoundException('Periodo académico no encontrado');
    }

    if (actor.rol !== RolUsuario.SUPERADMINISTRADOR && periodo.idInstitucion !== actor.idInstitucion) {
      throw new ForbiddenException('No puede operar periodos de otra institución');
    }

    if (dto.activo) {
      await this.prisma.periodoAcademico.updateMany({
        where: { idInstitucion: periodo.idInstitucion, activo: true },
        data: { activo: false },
      });
    }

    return this.prisma.periodoAcademico.update({
      where: { id: idPeriodo },
      data: { activo: dto.activo },
    });
  }

  private resolverInstitucionObjetivo(actor: UsuarioAutenticado, idInstitucionDto?: string): string {
    if (actor.rol === RolUsuario.SUPERADMINISTRADOR) {
      if (!idInstitucionDto) {
        throw new BadRequestException('SUPERADMINISTRADOR debe indicar idInstitucion');
      }
      return idInstitucionDto;
    }

    if (!actor.idInstitucion) {
      throw new ForbiddenException('Actor sin institución asociada');
    }

    return actor.idInstitucion;
  }
}
