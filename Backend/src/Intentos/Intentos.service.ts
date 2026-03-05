/**
 * @archivo   Intentos.service.ts
 * @descripcion Gestiona intentos de estudiantes y entrega de exámenes sanitizados.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoIntento, EstadoSesion, RolUsuario } from '@prisma/client';
import { createHash } from 'crypto';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { aleatorizarConSemilla } from '../Comun/Utilidades/AleatorizadorPreguntas.util';
import { CODIGOS_ERROR } from '../Comun/Constantes/Mensajes.constantes';
import { IniciarIntentoDto } from './Dto/IniciarIntento.dto';
import { SesionesExamenGateway } from '../SesionesExamen/SesionesExamen.gateway';

const LIMITE_SEMILLA_PERSONAL = 999999;

@Injectable()
export class IntentosService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly sesionesGateway: SesionesExamenGateway,
  ) {}

  /**
   * Inicia un intento para un estudiante en una sesión activa evitando duplicados.
   * @param dto - Datos de inicio de intento.
   * @param idEstudiante - UUID del estudiante.
   */
  async iniciar(dto: IniciarIntentoDto, idEstudiante: string, idInstitucion: string | null) {
    const sesion = await this.prisma.sesionExamen.findUnique({
      where: { id: dto.idSesion },
      include: {
        examen: {
          include: {
            preguntas: {
              include: { opciones: true },
              orderBy: { orden: 'asc' },
            },
          },
        },
        asignacion: true,
      },
    });
    if (!sesion) {
      throw new NotFoundException('Sesión no encontrada');
    }

    if (sesion.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede iniciar intentos fuera de su institución');
    }

    if (sesion.estado !== EstadoSesion.ACTIVA) {
      throw new BadRequestException({
        message: 'La sesión no está activa',
        codigoError: CODIGOS_ERROR.SESION_NO_ACTIVA,
      });
    }

    if (!sesion.codigoAcceso || sesion.codigoAcceso.trim().toUpperCase() !== dto.codigoAcceso.trim().toUpperCase()) {
      throw new ForbiddenException({
        message: 'Código de acceso inválido para la sesión',
        codigoError: CODIGOS_ERROR.CODIGO_SESION_INVALIDO,
      });
    }

    await this.validarElegibilidadAsignacion(sesion.asignacion, idEstudiante);

    const intentoExistente = await this.prisma.intentoExamen.findFirst({
      where: {
        estudianteId: idEstudiante,
        sesionId: dto.idSesion,
        estado: { in: [EstadoIntento.EN_PROGRESO, EstadoIntento.SINCRONIZACION_PENDIENTE] },
      },
      select: {
        id: true,
        estado: true,
        semillaPersonal: true,
        sesionId: true,
      },
    });

    if (intentoExistente) {
      throw new ConflictException({
        message: 'El estudiante ya tiene un intento en esta sesión',
        codigoError: CODIGOS_ERROR.INTENTO_DUPLICADO,
        datos: {
          intentoExistente,
        },
      });
    }

    if (sesion.asignacion && sesion.asignacion.intentosMaximos > 0) {
      const intentosPrevios = await this.prisma.intentoExamen.count({
        where: {
          sesionId: dto.idSesion,
          estudianteId: idEstudiante,
          estado: EstadoIntento.ENVIADO,
        },
      });
      if (intentosPrevios >= sesion.asignacion.intentosMaximos) {
        throw new ForbiddenException({
          message: 'Se alcanzó el número máximo de intentos permitidos',
          codigoError: CODIGOS_ERROR.INTENTOS_AGOTADOS,
        });
      }
    }

    const semillaPersonal = Math.floor(Math.random() * LIMITE_SEMILLA_PERSONAL) + 1;
    const semillaDeterminista = this.generarSemillaDeterminista(sesion.examen.id, dto.idSesion, idEstudiante);
    const preguntasAleatorias = aleatorizarConSemilla(sesion.examen.preguntas, semillaDeterminista).map((pregunta) => ({
      idPregunta: pregunta.id,
      orden: pregunta.orden,
      opciones: aleatorizarConSemilla(pregunta.opciones, semillaDeterminista + pregunta.orden).map((opcion) => ({
        id: opcion.id,
        orden: opcion.orden,
      })),
    }));

    const intentoCreado = await this.prisma.intentoExamen.create({
      data: {
        idInstitucion: idInstitucion ?? null,
        semillaPersonal,
        estado: EstadoIntento.EN_PROGRESO,
        estudianteId: idEstudiante,
        sesionId: dto.idSesion,
        ordenPreguntasAplicado: {
          semilla: semillaDeterminista,
          preguntas: preguntasAleatorias,
        },
        ultimaSincronizacion: new Date(),
        ipDispositivo: dto.ipDispositivo,
        modeloDispositivo: dto.modeloDispositivo,
        sistemaOperativo: dto.sistemaOperativo,
        versionApp: dto.versionApp,
      },
      include: {
        estudiante: {
          select: {
            nombre: true,
            apellidos: true,
          },
        },
      },
    });

    this.sesionesGateway.emitirProgreso(dto.idSesion, {
      idIntento: intentoCreado.id,
      preguntasRespondidas: 0,
      totalPreguntas: sesion.examen.totalPreguntas,
      nombreCompleto: `${intentoCreado.estudiante.nombre} ${intentoCreado.estudiante.apellidos}`.trim(),
      modoKioscoActivo: true,
      eventosFraude: 0,
      estadoIntento: EstadoIntento.EN_PROGRESO,
    });

    return intentoCreado;
  }

  /**
   * Obtiene el examen del intento ocultando respuestas correctas y aplicando aleatorización.
   * @param idIntento - UUID del intento.
   * @param idEstudiante - UUID del estudiante autenticado.
   */
  async obtenerExamen(idIntento: string, idEstudiante: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: {
        sesion: {
          include: {
            examen: {
              include: {
                preguntas: {
                  include: { opciones: true },
                  orderBy: { orden: 'asc' },
                },
              },
            },
          },
        },
      },
    });

    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }

    if (intento.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede consultar intentos fuera de su institución');
    }

    if (intento.estudianteId !== idEstudiante) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }

    const semillaCombinada = intento.semillaPersonal + intento.sesion.semillaGrupo + intento.sesion.examen.semillaAleatorizacion;
    const preguntasAleatorias = aleatorizarConSemilla(intento.sesion.examen.preguntas, semillaCombinada).map((pregunta) => ({
      ...pregunta,
      opciones: aleatorizarConSemilla(pregunta.opciones, semillaCombinada + pregunta.orden).map(
        ({ esCorrecta: _esCorrecta, ...opcion }) => opcion,
      ),
    }));

    return {
      idIntento: intento.id,
      estado: intento.estado,
      sesion: {
        id: intento.sesion.id,
        codigoAcceso: intento.sesion.codigoAcceso,
      },
      examen: {
        id: intento.sesion.examen.id,
        titulo: intento.sesion.examen.titulo,
        descripcion: intento.sesion.examen.descripcion,
        instrucciones: intento.sesion.examen.instrucciones,
        modalidad: intento.sesion.examen.modalidad,
        duracionMinutos: intento.sesion.examen.duracionMinutos,
        permitirNavegacion: intento.sesion.examen.permitirNavegacion,
        mostrarPuntaje: intento.sesion.examen.mostrarPuntaje,
        preguntas: preguntasAleatorias,
      },
    };
  }

  /**
   * Anula un intento en progreso o enviado validando alcance por rol y propiedad de la sesión.
   * @param idIntento - UUID del intento a anular.
   * @param rol - Rol del usuario autenticado.
   * @param idUsuario - UUID del usuario autenticado.
   */
  async anular(idIntento: string, rol: RolUsuario, idUsuario: string, idInstitucion: string | null) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: { sesion: true },
    });
    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }
    if (rol !== RolUsuario.SUPERADMINISTRADOR && intento.idInstitucion !== idInstitucion) {
      throw new ForbiddenException('No puede anular intentos fuera de su institución');
    }
    if (rol === RolUsuario.DOCENTE && intento.sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }
    if (intento.estado !== EstadoIntento.EN_PROGRESO && intento.estado !== EstadoIntento.ENVIADO) {
      throw new BadRequestException('Solo se pueden anular intentos en progreso o enviados');
    }
    return this.prisma.intentoExamen.update({
      where: { id: idIntento },
      data: {
        estado: EstadoIntento.ANULADO,
        razonAnulacion: 'ANULACION_ADMINISTRATIVA',
        anuladoPorId: idUsuario,
        anuladoEn: new Date(),
      },
    });
  }

  private generarSemillaDeterminista(idExamen: string, idSesion: string, idEstudiante: string): number {
    const hash = createHash('sha256').update(`${idExamen}:${idSesion}:${idEstudiante}`).digest('hex');
    return Number.parseInt(hash.slice(0, 8), 16);
  }

  private async validarElegibilidadAsignacion(
    asignacion:
      | {
          id: string;
          fechaInicio: Date;
          fechaFin: Date;
          intentosMaximos: number;
          idGrupo: string | null;
          idEstudiante: string | null;
        }
      | null,
    idEstudiante: string,
  ): Promise<void> {
    if (!asignacion) {
      return;
    }

    const ahora = new Date();
    if (ahora < asignacion.fechaInicio || ahora > asignacion.fechaFin) {
      throw new ForbiddenException({
        message: 'La sesión está fuera de la ventana de la asignación',
        codigoError: CODIGOS_ERROR.SESION_NO_ACTIVA,
      });
    }

    if (asignacion.idEstudiante && asignacion.idEstudiante !== idEstudiante) {
      throw new ForbiddenException('La asignación es individual y no corresponde al estudiante autenticado');
    }

    if (asignacion.idGrupo) {
      const membresia = await this.prisma.grupoEstudiante.findFirst({
        where: {
          idGrupo: asignacion.idGrupo,
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
}
