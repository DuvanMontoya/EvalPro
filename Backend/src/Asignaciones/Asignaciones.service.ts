import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoExamen, EstadoGrupo, RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { CrearAsignacionDto } from './Dto/CrearAsignacion.dto';

@Injectable()
export class AsignacionesService {
  constructor(private readonly prisma: PrismaService) {}

  async listar(actor: UsuarioAutenticado) {
    if (actor.rol !== RolUsuario.SUPERADMINISTRADOR && !actor.idInstitucion) {
      throw new ForbiddenException('Actor sin institución asociada');
    }

    const where = this.construirFiltroLectura(actor);
    return this.prisma.asignacionExamen.findMany({
      where,
      include: {
        examen: {
          select: {
            id: true,
            titulo: true,
            estado: true,
            creadoPorId: true,
          },
        },
        grupo: {
          select: {
            id: true,
            nombre: true,
            estado: true,
            idPeriodo: true,
          },
        },
        estudiante: {
          select: {
            id: true,
            nombre: true,
            apellidos: true,
            correo: true,
          },
        },
        actor: {
          select: {
            id: true,
            nombre: true,
            apellidos: true,
            correo: true,
          },
        },
      },
      orderBy: { fechaCreacion: 'desc' },
    });
  }

  async obtenerPorId(idAsignacion: string, actor: UsuarioAutenticado) {
    const asignacion = await this.prisma.asignacionExamen.findUnique({
      where: { id: idAsignacion },
      include: {
        examen: {
          select: {
            id: true,
            titulo: true,
            estado: true,
            creadoPorId: true,
          },
        },
        grupo: {
          select: {
            id: true,
            nombre: true,
            estado: true,
            idPeriodo: true,
          },
        },
        estudiante: {
          select: {
            id: true,
            nombre: true,
            apellidos: true,
            correo: true,
          },
        },
        actor: {
          select: {
            id: true,
            nombre: true,
            apellidos: true,
            correo: true,
          },
        },
      },
    });

    if (!asignacion) {
      throw new NotFoundException('Asignación no encontrada');
    }

    await this.validarLecturaAsignacion(asignacion, actor);
    return asignacion;
  }

  async crear(dto: CrearAsignacionDto, actor: UsuarioAutenticado) {
    if (actor.rol !== RolUsuario.DOCENTE) {
      throw new ForbiddenException('Solo DOCENTE puede crear asignaciones');
    }
    if (!actor.idInstitucion) {
      throw new ForbiddenException('Docente sin institución asociada');
    }

    const existeGrupo = typeof dto.idGrupo === 'string';
    const existeEstudiante = typeof dto.idEstudiante === 'string';
    if (existeGrupo === existeEstudiante) {
      throw new BadRequestException('Debe indicar exactamente uno de idGrupo o idEstudiante');
    }

    const fechaInicio = new Date(dto.fechaInicio);
    const fechaFin = new Date(dto.fechaFin);
    if (Number.isNaN(fechaInicio.getTime()) || Number.isNaN(fechaFin.getTime())) {
      throw new BadRequestException('Fechas inválidas');
    }
    if (fechaFin <= fechaInicio) {
      throw new BadRequestException('fechaFin debe ser mayor a fechaInicio');
    }
    if (fechaInicio < new Date()) {
      throw new BadRequestException('No se puede crear una asignación en el pasado');
    }

    const examen = await this.prisma.examen.findUnique({ where: { id: dto.idExamen } });
    if (!examen) {
      throw new NotFoundException('Examen no encontrado');
    }
    if (examen.idInstitucion !== actor.idInstitucion) {
      throw new ForbiddenException('No puede asignar exámenes de otra institución');
    }
    if (examen.creadoPorId !== actor.id) {
      throw new ForbiddenException('Solo el docente dueño puede crear asignaciones');
    }
    if (examen.estado !== EstadoExamen.PUBLICADO) {
      throw new BadRequestException('El examen debe estar PUBLICADO');
    }

    if (dto.idGrupo) {
      const grupo = await this.prisma.grupoAcademico.findUnique({ where: { id: dto.idGrupo } });
      if (!grupo) {
        throw new NotFoundException('Grupo no encontrado');
      }
      if (grupo.idInstitucion !== actor.idInstitucion || grupo.estado !== EstadoGrupo.ACTIVO) {
        throw new BadRequestException('El grupo debe estar ACTIVO y pertenecer a la misma institución');
      }

      const docenteEnGrupo = await this.prisma.grupoDocente.findFirst({
        where: {
          idGrupo: dto.idGrupo,
          idDocente: actor.id,
          activo: true,
        },
      });
      if (!docenteEnGrupo) {
        throw new ForbiddenException('El docente debe estar asignado al grupo');
      }
    }

    if (dto.idEstudiante) {
      const estudiante = await this.prisma.usuario.findUnique({ where: { id: dto.idEstudiante } });
      if (!estudiante || estudiante.rol !== RolUsuario.ESTUDIANTE || estudiante.idInstitucion !== actor.idInstitucion) {
        throw new BadRequestException('El estudiante no pertenece a la institución o no tiene rol ESTUDIANTE');
      }

      const estudianteEnGrupoDocente = await this.prisma.grupoEstudiante.findFirst({
        where: {
          idEstudiante: dto.idEstudiante,
          activo: true,
          grupo: {
            docentes: {
              some: {
                idDocente: actor.id,
                activo: true,
              },
            },
          },
        },
      });

      if (!estudianteEnGrupoDocente) {
        throw new ForbiddenException('El estudiante debe pertenecer a un grupo asignado al docente');
      }
    }

    return this.prisma.asignacionExamen.create({
      data: {
        idInstitucion: actor.idInstitucion,
        idExamen: dto.idExamen,
        idGrupo: dto.idGrupo ?? null,
        idEstudiante: dto.idEstudiante ?? null,
        fechaInicio,
        fechaFin,
        intentosMaximos: dto.intentosMaximos,
        mostrarPuntajeInmediato: dto.mostrarPuntajeInmediato,
        mostrarRespuestasCorrectas: dto.mostrarRespuestasCorrectas,
        publicarResultadosEn: dto.publicarResultadosEn ? new Date(dto.publicarResultadosEn) : null,
        creadoPor: actor.id,
      },
    });
  }

  private construirFiltroLectura(actor: UsuarioAutenticado): Record<string, unknown> {
    if (actor.rol === RolUsuario.SUPERADMINISTRADOR) {
      return {};
    }

    const whereBase: Record<string, unknown> = { idInstitucion: actor.idInstitucion };

    if (actor.rol === RolUsuario.ADMINISTRADOR) {
      return whereBase;
    }

    if (actor.rol === RolUsuario.DOCENTE) {
      return {
        ...whereBase,
        creadoPor: actor.id,
      };
    }

    if (actor.rol === RolUsuario.ESTUDIANTE) {
      const ahora = new Date();
      return {
        ...whereBase,
        fechaInicio: { lte: ahora },
        fechaFin: { gte: ahora },
        OR: [
          { idEstudiante: actor.id },
          {
            idGrupo: { not: null },
            grupo: {
              estudiantes: {
                some: {
                  idEstudiante: actor.id,
                  activo: true,
                },
              },
            },
          },
        ],
      };
    }

    return whereBase;
  }

  private async validarLecturaAsignacion(
    asignacion: {
      idInstitucion: string;
      creadoPor: string;
      idEstudiante: string | null;
      idGrupo: string | null;
      fechaInicio: Date;
      fechaFin: Date;
    },
    actor: UsuarioAutenticado,
  ): Promise<void> {
    if (actor.rol === RolUsuario.SUPERADMINISTRADOR) {
      return;
    }

    if (!actor.idInstitucion || asignacion.idInstitucion !== actor.idInstitucion) {
      throw new ForbiddenException('No puede consultar asignaciones de otra institución');
    }

    if (actor.rol === RolUsuario.ADMINISTRADOR) {
      return;
    }

    if (actor.rol === RolUsuario.DOCENTE) {
      if (asignacion.creadoPor !== actor.id) {
        throw new ForbiddenException('No tiene permisos sobre esta asignación');
      }
      return;
    }

    if (actor.rol === RolUsuario.ESTUDIANTE) {
      const ahora = new Date();
      if (asignacion.fechaInicio > ahora || asignacion.fechaFin < ahora) {
        throw new ForbiddenException('La asignación no está vigente para el estudiante');
      }

      if (asignacion.idEstudiante === actor.id) {
        return;
      }

      if (asignacion.idGrupo) {
        const membresia = await this.prisma.grupoEstudiante.findFirst({
          where: {
            idGrupo: asignacion.idGrupo,
            idEstudiante: actor.id,
            activo: true,
          },
          select: { id: true },
        });
        if (membresia) {
          return;
        }
      }

      throw new ForbiddenException('No tiene permisos sobre esta asignación');
    }

    throw new ForbiddenException('Rol no autorizado para consultar asignaciones');
  }
}
