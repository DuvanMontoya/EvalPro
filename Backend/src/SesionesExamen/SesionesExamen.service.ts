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
import { EstadoExamen, EstadoIntento, EstadoSesion, RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { generarCodigoSesion } from '../Comun/Utilidades/GeneradorCodigo.util';
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
      throw new BadRequestException('La sesión no está activa');
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
        throw new ForbiddenException('La sesión no está dentro de la ventana de asignación');
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
      },
    });

    if (sesion.asignacion?.intentosMaximos && sesion.asignacion.intentosMaximos > 0) {
      if (intentosPrevios >= sesion.asignacion.intentosMaximos) {
        throw new ForbiddenException('Se alcanzó el máximo de intentos permitidos para esta sesión');
      }
    }

    return {
      id: sesion.id,
      codigoAcceso: sesion.codigoAcceso,
      estado: sesion.estado,
      fechaActivacion: sesion.fechaInicio,
      examen: {
        id: sesion.examen.id,
        titulo: sesion.examen.titulo,
        instrucciones: sesion.examen.instrucciones,
        modalidad: sesion.examen.modalidad,
        duracionMinutos: sesion.examen.duracionMinutos,
        preguntas: sesion.examen.preguntas.map((pregunta) => ({
          id: pregunta.id,
          enunciado: pregunta.enunciado,
          tipo: pregunta.tipo,
          puntaje: pregunta.puntaje,
          orden: pregunta.orden,
          opciones: pregunta.opciones.map(({ esCorrecta: _esCorrecta, ...opcion }) => opcion),
        })),
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
