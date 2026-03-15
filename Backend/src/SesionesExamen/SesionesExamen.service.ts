/**
 * @archivo   SesionesExamen.service.ts
 * @descripcion Implementa ciclo de vida de sesiones con validaciones de estado, tenant y eventos WebSocket.
 * @modulo    SesionesExamen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable,
  NotFoundException,
  forwardRef,
} from '@nestjs/common';
import { EstadoExamen, EstadoGrupo, EstadoIntento, EstadoSesion, RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { CODIGOS_ERROR } from '../Comun/Constantes/Mensajes.constantes';
import { generarCodigoSesion } from '../Comun/Utilidades/GeneradorCodigo.util';
import { sanitizarExamenParaEstudiante } from '../Comun/Utilidades/SanitizadorExamenEstudiante.util';
import { RespuestasService } from '../Respuestas/Respuestas.service';
import { CrearSesionDto } from './Dto/CrearSesion.dto';
import { SesionesExamenGateway } from './SesionesExamen.gateway';

const LIMITE_SEMILLA_GRUPO = 999999;
const MAX_INTENTOS_GENERAR_CODIGO = 5;

@Injectable()
export class SesionesExamenService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly gateway: SesionesExamenGateway,
    @Inject(forwardRef(() => RespuestasService))
    private readonly respuestasService: RespuestasService,
  ) {}

  /**
   * Crea una sesión en estado pendiente sin código de acceso (se genera al activar).
   */
  async crear(dto: CrearSesionDto, idDocente: string, idInstitucion: string | null) {
    let idExamen = dto.idExamen ?? null;
    let idAsignacion = dto.idAsignacion ?? null;

    if (!idExamen && !idAsignacion) {
      throw new BadRequestException('Debe enviar idAsignacion o idExamen');
    }

    if (idAsignacion) {
      const asignacion = await this.prisma.asignacionExamen.findUnique({
        where: { id: idAsignacion },
        include: { examen: true },
      });
      if (!asignacion) {
        throw new NotFoundException('Asignación no encontrada');
      }
      if (asignacion.idInstitucion !== idInstitucion) {
        throw new ForbiddenException('No puede crear sesiones para otra institución');
      }
      if (asignacion.examen.creadoPorId !== idDocente) {
        throw new ForbiddenException('Solo el docente dueño puede crear sesión para esta asignación');
      }
      idExamen = asignacion.idExamen;
    }

    if (!idExamen) {
      throw new BadRequestException('No se pudo resolver examen para la sesión');
    }

    const examen = await this.prisma.examen.findUnique({ where: { id: idExamen } });
    if (!examen) {
      throw new NotFoundException('Examen no encontrado');
    }

    if (examen.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede crear sesiones fuera de su institución');
    }

    if (examen.creadoPorId !== idDocente) {
      throw new ForbiddenException('No tiene permisos sobre este examen');
    }

    if (examen.estado !== EstadoExamen.PUBLICADO) {
      throw new BadRequestException('El examen debe estar publicado para crear sesiones');
    }

    const semillaGrupo = Math.floor(Math.random() * LIMITE_SEMILLA_GRUPO) + 1;

    return this.prisma.sesionExamen.create({
      data: {
        codigoAcceso: null,
        estado: EstadoSesion.PENDIENTE,
        descripcion: dto.descripcion,
        semillaGrupo,
        examenId: idExamen,
        idAsignacion,
        creadaPorId: idDocente,
        idInstitucion: idInstitucion ?? null,
      },
    });
  }

  /**
   * Lista sesiones según rol, propiedad y tenant.
   */
  async listar(rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    if (rol === RolUsuario.ESTUDIANTE) {
      if (!idInstitucion) {
        throw new ForbiddenException('Estudiante sin institución asociada');
      }

      const ahora = new Date();
      return this.prisma.sesionExamen.findMany({
        where: {
          idInstitucion,
          estado: EstadoSesion.ACTIVA,
          asignacion: {
            is: {
              fechaInicio: { lte: ahora },
              fechaFin: { gte: ahora },
              OR: [
                { idEstudiante: idUsuario },
                {
                  idGrupo: { not: null },
                  grupo: {
                    estudiantes: {
                      some: {
                        idEstudiante: idUsuario,
                        activo: true,
                      },
                    },
                  },
                },
              ],
            },
          },
        },
        include: {
          examen: {
            select: {
              id: true,
              titulo: true,
              duracionMinutos: true,
            },
          },
          asignacion: {
            select: {
              id: true,
              fechaInicio: true,
              fechaFin: true,
              intentosMaximos: true,
              idGrupo: true,
              idEstudiante: true,
            },
          },
        },
        orderBy: { fechaCreacion: 'desc' },
      });
    }

    const where: Record<string, unknown> = {};
    if (rol !== RolUsuario.SUPERADMINISTRADOR) {
      where.idInstitucion = idInstitucion;
    }
    if (rol === RolUsuario.DOCENTE) {
      where.creadaPorId = idUsuario;
    }
    return this.prisma.sesionExamen.findMany({ where, orderBy: { fechaCreacion: 'desc' } });
  }

  /**
   * Obtiene una sesión validando alcance de rol/tenant.
   */
  async obtenerPorId(idSesion: string, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const sesion = await this.prisma.sesionExamen.findUnique({ where: { id: idSesion }, include: { examen: true } });
    if (!sesion) {
      throw new NotFoundException('Sesión no encontrada');
    }

    if (rol !== RolUsuario.SUPERADMINISTRADOR && sesion.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede consultar sesiones de otra institución');
    }

    if (rol === RolUsuario.DOCENTE && sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre esta sesión');
    }

    return sesion;
  }

  /**
   * Activa sesión pendiente y genera código de acceso único.
   */
  async activar(idSesion: string, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const sesion = await this.obtenerSesionGestionable(idSesion, rol, idUsuario, idInstitucion);
    if (sesion.estado !== EstadoSesion.PENDIENTE) {
      throw new BadRequestException('La sesión no está en estado pendiente');
    }

    const sesionConContexto = await this.prisma.sesionExamen.findUnique({
      where: { id: idSesion },
      include: {
        examen: { select: { estado: true } },
        asignacion: {
          select: {
            fechaInicio: true,
            fechaFin: true,
            grupo: { select: { estado: true } },
          },
        },
      },
    });
    if (!sesionConContexto) {
      throw new NotFoundException('Sesión no encontrada');
    }

    if (sesionConContexto.examen.estado !== EstadoExamen.PUBLICADO) {
      throw new ConflictException('El examen debe estar publicado para activar la sesión');
    }

    if (sesionConContexto.asignacion) {
      const ahora = new Date();
      if (ahora < sesionConContexto.asignacion.fechaInicio || ahora > sesionConContexto.asignacion.fechaFin) {
        throw new ForbiddenException({
          message: 'La sesión no está dentro de la ventana de asignación',
          codigoError: CODIGOS_ERROR.SESION_NO_ACTIVA,
        });
      }

      if (sesionConContexto.asignacion.grupo && sesionConContexto.asignacion.grupo.estado !== EstadoGrupo.ACTIVO) {
        throw new ConflictException('El grupo de la asignación debe estar activo para activar la sesión');
      }
    }

    const conflictoSesionActiva = await this.prisma.sesionExamen.findFirst({
      where: sesion.idAsignacion
        ? {
            idAsignacion: sesion.idAsignacion,
            estado: EstadoSesion.ACTIVA,
            id: { not: idSesion },
          }
        : {
            examenId: sesion.examenId,
            estado: EstadoSesion.ACTIVA,
            id: { not: idSesion },
          },
      select: { id: true },
    });
    if (conflictoSesionActiva) {
      throw new ConflictException('Ya existe una sesión activa para este examen');
    }

    const codigoAcceso = await this.generarCodigoUnico();
    const actualizada = await this.prisma.sesionExamen.update({
      where: { id: idSesion },
      data: { estado: EstadoSesion.ACTIVA, fechaInicio: new Date(), codigoAcceso },
    });

    this.gateway.emitirSesionActivada(idSesion);
    return actualizada;
  }

  /**
   * Finaliza sesión activa y envía intentos pendientes.
   */
  async finalizar(idSesion: string, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const sesion = await this.obtenerSesionGestionable(idSesion, rol, idUsuario, idInstitucion);
    if (sesion.estado !== EstadoSesion.ACTIVA) {
      throw new BadRequestException({
        message: 'La sesión no está activa',
        codigoError: CODIGOS_ERROR.SESION_NO_ACTIVA,
      });
    }

    const fechaFin = new Date();
    const actualizada = await this.prisma.sesionExamen.update({
      where: { id: idSesion },
      data: { estado: EstadoSesion.FINALIZADA, fechaFin },
    });

    await this.prisma.intentoExamen.updateMany({
      where: {
        sesionId: idSesion,
        estado: { in: [EstadoIntento.EN_PROGRESO, EstadoIntento.SINCRONIZACION_PENDIENTE] },
      },
      data: {
        estado: EstadoIntento.ENVIADO,
        fechaEnvio: fechaFin,
      },
    });

    this.gateway.emitirSesionFinalizada(idSesion);
    await this.respuestasService.calcularPuntajesTodosIntentos(idSesion);
    return actualizada;
  }

  /**
   * Cancela sesión pendiente o activa y anula intentos en progreso.
   */
  async cancelar(idSesion: string, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const sesion = await this.obtenerSesionGestionable(idSesion, rol, idUsuario, idInstitucion);
    if (sesion.estado !== EstadoSesion.PENDIENTE && sesion.estado !== EstadoSesion.ACTIVA) {
      throw new BadRequestException('La sesión no se puede cancelar desde su estado actual');
    }

    const fechaFin = sesion.estado === EstadoSesion.ACTIVA ? new Date() : null;
    await this.prisma.intentoExamen.updateMany({
      where: {
        sesionId: idSesion,
        estado: { in: [EstadoIntento.EN_PROGRESO, EstadoIntento.SINCRONIZACION_PENDIENTE] },
      },
      data: {
        estado: EstadoIntento.ANULADO,
        anuladoEn: new Date(),
        razonAnulacion: 'SESION_CANCELADA',
        anuladoPorId: idUsuario,
      },
    });

    return this.prisma.sesionExamen.update({
      where: { id: idSesion },
      data: { estado: EstadoSesion.CANCELADA, fechaFin, codigoAcceso: null },
    });
  }

  /**
   * Busca sesión activa por código y devuelve examen sanitizado para estudiante.
   */
  async buscarPorCodigo(codigo: string, idEstudiante: string, idInstitucion: string | null) {
    const codigoNormalizado = codigo.trim().toUpperCase();
    const sesion = await this.prisma.sesionExamen.findFirst({
      where: {
        codigoAcceso: { equals: codigoNormalizado, mode: 'insensitive' },
      },
      include: {
        asignacion: true,
        examen: {
          include: {
            preguntas: {
              include: { opciones: true },
              orderBy: { orden: 'asc' },
            },
          },
        },
      },
    });
    if (!sesion) {
      throw new NotFoundException('Sesión no encontrada');
    }

    if (sesion.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede consultar sesiones de otra institución');
    }

    if (sesion.estado !== EstadoSesion.ACTIVA) {
      throw new BadRequestException('La sesión no está activa');
    }

    if (sesion.asignacion) {
      const ahora = new Date();
      if (ahora < sesion.asignacion.fechaInicio || ahora > sesion.asignacion.fechaFin) {
        throw new ForbiddenException({
          message: 'La sesión no está dentro de la ventana de asignación',
          codigoError: CODIGOS_ERROR.SESION_NO_ACTIVA,
        });
      }

      if (sesion.asignacion.idEstudiante && sesion.asignacion.idEstudiante !== idEstudiante) {
        throw new ForbiddenException('La asignación individual no corresponde al estudiante autenticado');
      }

      if (sesion.asignacion.idGrupo) {
        const membresia = await this.prisma.grupoEstudiante.findFirst({
          where: {
            idGrupo: sesion.asignacion.idGrupo,
            idEstudiante,
            activo: true,
          },
          select: { id: true },
        });
        if (!membresia) {
          throw new ForbiddenException('El estudiante no pertenece activamente al grupo de la asignación');
        }
      }
    }

    const intentosPrevios = await this.prisma.intentoExamen.count({
      where: {
        sesionId: sesion.id,
        estudianteId: idEstudiante,
        estado: EstadoIntento.ENVIADO,
      },
    });

    if (sesion.asignacion?.intentosMaximos && sesion.asignacion.intentosMaximos > 0) {
      if (intentosPrevios >= sesion.asignacion.intentosMaximos) {
        throw new ForbiddenException({
          message: 'Se alcanzó el máximo de intentos permitidos para esta sesión',
          codigoError: CODIGOS_ERROR.INTENTOS_AGOTADOS,
        });
      }
    }

    const examenSanitizado = sanitizarExamenParaEstudiante({
      id: sesion.examen.id,
      titulo: sesion.examen.titulo,
      instrucciones: sesion.examen.instrucciones,
      modalidad: sesion.examen.modalidad,
      duracionMinutos: sesion.examen.duracionMinutos,
      version: sesion.examen.version,
      preguntas: [],
    });

    return {
      id: sesion.id,
      codigoAcceso: sesion.codigoAcceso,
      estado: sesion.estado,
      fechaActivacion: sesion.fechaInicio,
      examen: {
        id: examenSanitizado.id,
        titulo: examenSanitizado.titulo,
        instrucciones: examenSanitizado.instrucciones,
        modalidad: examenSanitizado.modalidad,
        duracionMinutos: examenSanitizado.duracionMinutos,
        identificadorCuadernillo: examenSanitizado.identificadorCuadernillo,
      },
      intentosPrevios,
      intentosMaximos: sesion.asignacion?.intentosMaximos ?? 1,
      configuracionAntifraude: sesion.configuracionAntifraude ?? null,
    };
  }

  private async generarCodigoUnico(): Promise<string> {
    let intentos = 0;
    while (intentos < MAX_INTENTOS_GENERAR_CODIGO) {
      const codigo = generarCodigoSesion();
      const existe = await this.prisma.sesionExamen.findUnique({ where: { codigoAcceso: codigo } });
      if (!existe) {
        return codigo;
      }

      intentos += 1;
    }

    throw new ConflictException('No fue posible generar un código de sesión único');
  }

  private async obtenerSesionGestionable(
    idSesion: string,
    rol: RolUsuario,
    idUsuario: string,
    idInstitucion: string | null,
  ) {
    const sesion = await this.prisma.sesionExamen.findUnique({ where: { id: idSesion } });
    if (!sesion) {
      throw new NotFoundException('Sesión no encontrada');
    }

    if (rol !== RolUsuario.SUPERADMINISTRADOR && sesion.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede operar sobre sesiones fuera de su institución');
    }

    if (rol === RolUsuario.DOCENTE && sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre esta sesión');
    }

    return sesion;
  }
}
