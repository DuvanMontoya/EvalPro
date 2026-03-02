import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoInstitucion, RolUsuario } from '@prisma/client';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { CambiarEstadoInstitucionDto } from './Dto/CambiarEstadoInstitucion.dto';
import { CrearInstitucionDto } from './Dto/CrearInstitucion.dto';

@Injectable()
export class InstitucionesService {
  constructor(private readonly prisma: PrismaService) {}

  async crear(dto: CrearInstitucionDto, rolActor: RolUsuario) {
    this.validarSuperadministrador(rolActor);
    return this.prisma.institucion.create({
      data: {
        nombre: dto.nombre.trim(),
        dominio: dto.dominio?.trim().toLowerCase() ?? null,
        configuracion: (dto.configuracion ?? {}) as Prisma.InputJsonValue,
        estado: EstadoInstitucion.ACTIVA,
      },
    });
  }

  async cambiarEstado(idInstitucion: string, dto: CambiarEstadoInstitucionDto, rolActor: RolUsuario) {
    this.validarSuperadministrador(rolActor);
    const institucion = await this.prisma.institucion.findUnique({ where: { id: idInstitucion } });
    if (!institucion) {
      throw new NotFoundException('Institución no encontrada');
    }

    this.validarTransicionEstado(institucion.estado, dto.estado);

    const actualizada = await this.prisma.institucion.update({
      where: { id: idInstitucion },
      data: { estado: dto.estado },
    });

    if (dto.estado === EstadoInstitucion.SUSPENDIDA) {
      await this.prisma.usuario.updateMany({
        where: { idInstitucion },
        data: { tokenRefresh: null },
      });
    }

    return {
      ...actualizada,
      razon: dto.razon,
    };
  }

  private validarSuperadministrador(rolActor: RolUsuario): void {
    if (rolActor !== RolUsuario.SUPERADMINISTRADOR) {
      throw new ForbiddenException('Solo SUPERADMINISTRADOR puede operar sobre instituciones');
    }
  }

  private validarTransicionEstado(actual: EstadoInstitucion, objetivo: EstadoInstitucion): void {
    if (actual === objetivo) {
      return;
    }

    if (actual === EstadoInstitucion.ARCHIVADA) {
      throw new BadRequestException('La institución archivada es terminal y no admite cambios');
    }

    if (
      actual === EstadoInstitucion.ACTIVA &&
      objetivo !== EstadoInstitucion.SUSPENDIDA &&
      objetivo !== EstadoInstitucion.ARCHIVADA
    ) {
      throw new BadRequestException('Transición inválida desde ACTIVA');
    }

    if (
      actual === EstadoInstitucion.SUSPENDIDA &&
      objetivo !== EstadoInstitucion.ACTIVA &&
      objetivo !== EstadoInstitucion.ARCHIVADA
    ) {
      throw new BadRequestException('Transición inválida desde SUSPENDIDA');
    }
  }
}
