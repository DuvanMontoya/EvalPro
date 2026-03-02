/**
 * @archivo   Intentos.service.ts
 * @descripcion Gestiona intentos de estudiantes y entrega de exámenes sanitizados.
 * @modulo    Intentos
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { EstadoIntento, EstadoSesion, RolUsuario } from '@prisma/client';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { aleatorizarConSemilla } from '../Comun/Utilidades/AleatorizadorPreguntas.util';
import { CODIGOS_ERROR } from '../Comun/Constantes/Mensajes.constantes';
import { IniciarIntentoDto } from './Dto/IniciarIntento.dto';

const LIMITE_SEMILLA_PERSONAL = 999999;

@Injectable()
export class IntentosService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Inicia un intento para un estudiante en una sesión activa evitando duplicados.
   * @param dto - Datos de inicio de intento.
   * @param idEstudiante - UUID del estudiante.
   */
  async iniciar(dto: IniciarIntentoDto, idEstudiante: string) {
    const sesion = await this.prisma.sesionExamen.findUnique({ where: { id: dto.idSesion } });
    if (!sesion) {
      throw new NotFoundException('Sesión no encontrada');
    }

    if (sesion.estado !== EstadoSesion.ACTIVA) {
      throw new BadRequestException('La sesión no está activa');
    }

    const intentoExistente = await this.prisma.intentoExamen.findUnique({
      where: { estudianteId_sesionId: { estudianteId: idEstudiante, sesionId: dto.idSesion } },
    });

    if (intentoExistente) {
      throw new ConflictException({
        message: 'El estudiante ya tiene un intento en esta sesión',
        codigoError: CODIGOS_ERROR.INTENTO_DUPLICADO,
      });
    }

    const semillaPersonal = Math.floor(Math.random() * LIMITE_SEMILLA_PERSONAL) + 1;
    return this.prisma.intentoExamen.create({
      data: {
        semillaPersonal,
        estado: EstadoIntento.EN_PROGRESO,
        estudianteId: idEstudiante,
        sesionId: dto.idSesion,
        ipDispositivo: dto.ipDispositivo,
        modeloDispositivo: dto.modeloDispositivo,
        sistemaOperativo: dto.sistemaOperativo,
        versionApp: dto.versionApp,
      },
    });
  }

  /**
   * Obtiene el examen del intento ocultando respuestas correctas y aplicando aleatorización.
   * @param idIntento - UUID del intento.
   * @param idEstudiante - UUID del estudiante autenticado.
   */
  async obtenerExamen(idIntento: string, idEstudiante: string) {
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
  async anular(idIntento: string, rol: RolUsuario, idUsuario: string) {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: { sesion: true },
    });
    if (!intento) {
      throw new NotFoundException('Intento no encontrado');
    }
    if (rol === RolUsuario.DOCENTE && intento.sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre este intento');
    }
    if (intento.estado !== EstadoIntento.EN_PROGRESO && intento.estado !== EstadoIntento.ENVIADO) {
      throw new BadRequestException('Solo se pueden anular intentos en progreso o enviados');
    }
    return this.prisma.intentoExamen.update({
      where: { id: idIntento },
      data: { estado: EstadoIntento.ANULADO },
    });
  }
}
