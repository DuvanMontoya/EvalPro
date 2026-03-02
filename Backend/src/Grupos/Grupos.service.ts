import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoGrupo, EstadoSesion, RolUsuario } from '@prisma/client';
import { randomBytes } from 'crypto';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { UsuarioAutenticado } from '../Comun/Tipos/UsuarioAutenticado.tipo';
import { AsignarDocenteGrupoDto } from './Dto/AsignarDocenteGrupo.dto';
import { CambiarEstadoGrupoDto } from './Dto/CambiarEstadoGrupo.dto';
import { CrearGrupoDto } from './Dto/CrearGrupo.dto';
import { InscribirEstudianteGrupoDto } from './Dto/InscribirEstudianteGrupo.dto';

@Injectable()
export class GruposService {
  constructor(private readonly prisma: PrismaService) {}

  async crear(dto: CrearGrupoDto, actor: UsuarioAutenticado) {
    const idInstitucion = this.resolverInstitucionObjetivo(actor, dto.idInstitucion);
    const periodo = await this.prisma.periodoAcademico.findUnique({
      where: { id: dto.idPeriodo },
      select: { id: true, idInstitucion: true, activo: true },
    });
    if (!periodo) {
      throw new NotFoundException('Periodo académico no encontrado');
    }
    if (periodo.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('El periodo académico no pertenece a la institución objetivo');
    }
    if (!periodo.activo) {
      throw new BadRequestException('El periodo académico no está activo');
    }

    return this.prisma.grupoAcademico.create({
      data: {
        idInstitucion,
        idPeriodo: dto.idPeriodo,
        nombre: dto.nombre.trim(),
        descripcion: dto.descripcion?.trim() ?? null,
        estado: EstadoGrupo.BORRADOR,
        codigoAcceso: await this.generarCodigoGrupoUnico(),
      },
    });
  }

  async asignarDocente(idGrupo: string, dto: AsignarDocenteGrupoDto, actor: UsuarioAutenticado) {
    const grupo = await this.obtenerGrupoYValidarTenant(idGrupo, actor);
    const docente = await this.prisma.usuario.findUnique({ where: { id: dto.idDocente } });
    if (!docente) {
      throw new NotFoundException('Docente no encontrado');
    }
    if (docente.idInstitucion !== grupo.idInstitucion || docente.rol !== RolUsuario.DOCENTE || !docente.activo) {
      throw new BadRequestException('El usuario no cumple condiciones para asignarse como docente');
    }

    try {
      return await this.prisma.grupoDocente.create({
        data: {
          idGrupo,
          idDocente: dto.idDocente,
          activo: true,
          asignadoPor: actor.id,
        },
      });
    } catch {
      throw new ConflictException('El docente ya está asignado a este grupo');
    }
  }

  async inscribirEstudiante(idGrupo: string, dto: InscribirEstudianteGrupoDto, actor: UsuarioAutenticado) {
    const grupo = await this.obtenerGrupoYValidarTenant(idGrupo, actor);
    const estudiante = await this.prisma.usuario.findUnique({ where: { id: dto.idEstudiante } });
    if (!estudiante) {
      throw new NotFoundException('Estudiante no encontrado');
    }
    if (estudiante.idInstitucion !== grupo.idInstitucion || estudiante.rol !== RolUsuario.ESTUDIANTE || !estudiante.activo) {
      throw new BadRequestException('El usuario no cumple condiciones para inscribirse como estudiante');
    }

    try {
      return await this.prisma.grupoEstudiante.create({
        data: {
          idGrupo,
          idEstudiante: dto.idEstudiante,
          activo: true,
          inscritoPor: actor.id,
        },
      });
    } catch {
      throw new ConflictException('El estudiante ya está inscrito en este grupo');
    }
  }

  async cambiarEstado(idGrupo: string, dto: CambiarEstadoGrupoDto, actor: UsuarioAutenticado) {
    const grupo = await this.obtenerGrupoYValidarTenant(idGrupo, actor);
    this.validarTransicionEstado(grupo.estado, dto.estado);

    if (dto.estado === EstadoGrupo.ACTIVO) {
      const [docentes, estudiantes] = await Promise.all([
        this.prisma.grupoDocente.count({ where: { idGrupo, activo: true } }),
        this.prisma.grupoEstudiante.count({ where: { idGrupo, activo: true } }),
      ]);
      if (docentes < 1 || estudiantes < 1) {
        throw new BadRequestException('Para activar el grupo se requiere al menos un docente y un estudiante activos');
      }
    }

    if (dto.estado === EstadoGrupo.CERRADO) {
      await this.prisma.sesionExamen.updateMany({
        where: {
          asignacion: {
            idGrupo,
          },
          estado: EstadoSesion.ACTIVA,
        },
        data: {
          estado: EstadoSesion.FINALIZADA,
          fechaFin: new Date(),
          codigoAcceso: null,
        },
      });
    }

    return this.prisma.grupoAcademico.update({
      where: { id: idGrupo },
      data: { estado: dto.estado },
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

  private async obtenerGrupoYValidarTenant(idGrupo: string, actor: UsuarioAutenticado) {
    const grupo = await this.prisma.grupoAcademico.findUnique({ where: { id: idGrupo } });
    if (!grupo) {
      throw new NotFoundException('Grupo no encontrado');
    }

    if (actor.rol !== RolUsuario.SUPERADMINISTRADOR && grupo.idInstitucion !== actor.idInstitucion) {
      throw new ForbiddenException('No puede operar sobre grupos fuera de su institución');
    }
    return grupo;
  }

  private validarTransicionEstado(actual: EstadoGrupo, objetivo: EstadoGrupo): void {
    if (actual === objetivo) {
      return;
    }
    if (actual === EstadoGrupo.ARCHIVADO) {
      throw new BadRequestException('Grupo archivado es terminal');
    }
    if (
      actual === EstadoGrupo.BORRADOR &&
      objetivo !== EstadoGrupo.ACTIVO &&
      objetivo !== EstadoGrupo.ARCHIVADO
    ) {
      throw new BadRequestException('Transición inválida desde BORRADOR');
    }
    if (actual === EstadoGrupo.ACTIVO && objetivo !== EstadoGrupo.CERRADO) {
      throw new BadRequestException('Transición inválida desde ACTIVO');
    }
    if (actual === EstadoGrupo.CERRADO && objetivo !== EstadoGrupo.ARCHIVADO) {
      throw new BadRequestException('Transición inválida desde CERRADO');
    }
  }

  private async generarCodigoGrupoUnico(): Promise<string> {
    for (let intento = 0; intento < 10; intento += 1) {
      const codigo = randomBytes(8).toString('base64url').replace(/[^A-Za-z0-9]/g, '').slice(0, 8).toUpperCase();
      if (codigo.length < 8) {
        continue;
      }
      const existente = await this.prisma.grupoAcademico.findUnique({ where: { codigoAcceso: codigo } });
      if (!existente) {
        return codigo;
      }
    }
    throw new ConflictException('No fue posible generar código único para el grupo');
  }
}
