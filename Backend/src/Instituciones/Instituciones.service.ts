import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoInstitucion, Prisma, RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { ActualizarConfiguracionAntifraudeDto } from './Dto/ActualizarConfiguracionAntifraude.dto';
import { CambiarEstadoInstitucionDto } from './Dto/CambiarEstadoInstitucion.dto';
import { CrearInstitucionDto } from './Dto/CrearInstitucion.dto';

@Injectable()
export class InstitucionesService {
  constructor(private readonly prisma: PrismaService) {}

  async listar(actor: UsuarioAutenticado) {
    if (actor.rol === RolUsuario.SUPERADMINISTRADOR) {
      return this.prisma.institucion.findMany({ orderBy: { fechaCreacion: 'desc' } });
    }

    if (!actor.idInstitucion) {
      throw new ForbiddenException('El actor no tiene institución asociada');
    }

    const institucion = await this.prisma.institucion.findUnique({
      where: { id: actor.idInstitucion },
    });

    if (!institucion) {
      throw new NotFoundException('Institución no encontrada');
    }

    return [institucion];
  }

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

  async actualizarConfiguracionAntifraude(
    idInstitucion: string,
    dto: ActualizarConfiguracionAntifraudeDto,
    actor: UsuarioAutenticado,
  ) {
    if (actor.rol !== RolUsuario.SUPERADMINISTRADOR && actor.rol !== RolUsuario.ADMINISTRADOR) {
      throw new ForbiddenException('Solo SUPERADMINISTRADOR o ADMINISTRADOR pueden actualizar políticas antifraude');
    }

    if (actor.rol === RolUsuario.ADMINISTRADOR && actor.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede actualizar políticas de otra institución');
    }
    if (dto.red.umbralRiesgoCritico < dto.red.umbralRiesgoSospechoso) {
      throw new BadRequestException('El umbral crítico no puede ser menor que el umbral sospechoso');
    }

    const institucion = await this.prisma.institucion.findUnique({
      where: { id: idInstitucion },
      select: { id: true, configuracion: true },
    });
    if (!institucion) {
      throw new NotFoundException('Institución no encontrada');
    }

    const configuracionActual = this.extraerObjeto(institucion.configuracion) ?? {};
    const antifraudeActual = this.extraerObjeto(configuracionActual.antifraude) ?? {};
    const configuracionNueva = {
      ...configuracionActual,
      antifraude: {
        ...antifraudeActual,
        red: {
          ventanaSegundos: dto.red.ventanaSegundos,
          maxReconexionesVentana: dto.red.maxReconexionesVentana,
          maxCambiosTipoRedVentana: dto.red.maxCambiosTipoRedVentana,
          maxTiempoOfflineSegundos: dto.red.maxTiempoOfflineSegundos,
          riesgoPorReconexion: dto.red.riesgoPorReconexion,
          riesgoPorCambioTipoRed: dto.red.riesgoPorCambioTipoRed,
          riesgoPorOfflineExtenso: dto.red.riesgoPorOfflineExtenso,
          umbralRiesgoSospechoso: dto.red.umbralRiesgoSospechoso,
          umbralRiesgoCritico: dto.red.umbralRiesgoCritico,
        },
      },
    };

    return this.prisma.institucion.update({
      where: { id: idInstitucion },
      data: {
        configuracion: configuracionNueva as Prisma.InputJsonValue,
      },
    });
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

  private extraerObjeto(valor: unknown): Record<string, unknown> | null {
    if (valor && typeof valor === 'object' && !Array.isArray(valor)) {
      return valor as Record<string, unknown>;
    }
    return null;
  }
}
