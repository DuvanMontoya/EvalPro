import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoExamen, EstadoGrupo, RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { CrearAsignacionDto } from './Dto/CrearAsignacion.dto';

@Injectable()
export class AsignacionesService {
  constructor(private readonly prisma: PrismaService) {}

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
}
