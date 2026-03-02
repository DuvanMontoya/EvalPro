/**
 * @archivo   SesionesExamen.service.ts
 * @descripcion Implementa ciclo de vida de sesiones con eventos WebSocket y cierre de puntajes.
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
import { EstadoExamen, EstadoSesion, RolUsuario } from '@prisma/client';
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
   * Crea una sesión en estado pendiente con código único y semilla grupal.
   * @param dto - Datos de creación de sesión.
   * @param idDocente - UUID del docente autenticado.
   */
  async crear(dto: CrearSesionDto, idDocente: string) {
    const examen = await this.prisma.examen.findUnique({ where: { id: dto.idExamen } });
    if (!examen) {
      throw new NotFoundException('Examen no encontrado');
    }

    if (examen.creadoPorId !== idDocente) {
      throw new ForbiddenException('No tiene permisos sobre este examen');
    }

    if (examen.estado !== EstadoExamen.PUBLICADO) {
      throw new BadRequestException('El examen debe estar publicado para crear sesiones');
    }

    const codigoAcceso = await this.generarCodigoUnico();
    const semillaGrupo = Math.floor(Math.random() * LIMITE_SEMILLA_GRUPO) + 1;

    return this.prisma.sesionExamen.create({
      data: {
        codigoAcceso,
        estado: EstadoSesion.PENDIENTE,
        descripcion: dto.descripcion,
        semillaGrupo,
        examenId: dto.idExamen,
        creadaPorId: idDocente,
      },
    });
  }

  /**
   * Lista sesiones según rol del usuario autenticado.
   */
  async listar(rol: RolUsuario, idUsuario: string) {
    const where = rol === RolUsuario.ADMINISTRADOR ? {} : { creadaPorId: idUsuario };
    return this.prisma.sesionExamen.findMany({ where, orderBy: { fechaCreacion: 'desc' } });
  }

  /**
   * Obtiene una sesión verificando permisos para docentes.
   */
  async obtenerPorId(idSesion: string, rol: RolUsuario, idUsuario: string) {
    const sesion = await this.prisma.sesionExamen.findUnique({ where: { id: idSesion }, include: { examen: true } });
    if (!sesion) {
      throw new NotFoundException('Sesión no encontrada');
    }

    if (rol === RolUsuario.DOCENTE && sesion.creadaPorId !== idUsuario) {
      throw new ForbiddenException('No tiene permisos sobre esta sesión');
    }

    return sesion;
  }

  /**
   * Activa una sesión pendiente y notifica por WebSocket.
   * @param idSesion - UUID de sesión.
   * @param idDocente - UUID del docente propietario.
   */
  async activar(idSesion: string, idDocente: string) {
    const sesion = await this.prisma.sesionExamen.findUnique({ where: { id: idSesion } });
    if (!sesion) {
      throw new NotFoundException('Sesión no encontrada');
    }

    if (sesion.creadaPorId !== idDocente) {
      throw new ForbiddenException('No tiene permisos sobre esta sesión');
    }

    if (sesion.estado !== EstadoSesion.PENDIENTE) {
      throw new BadRequestException('La sesión no está en estado pendiente');
    }

    const actualizada = await this.prisma.sesionExamen.update({
      where: { id: idSesion },
      data: { estado: EstadoSesion.ACTIVA, fechaInicio: new Date() },
    });

    this.gateway.emitirSesionActivada(idSesion);
    return actualizada;
  }

  /**
   * Finaliza sesión activa, notifica WebSocket y calcula puntajes de todos los intentos.
   * @param idSesion - UUID de sesión.
   * @param idDocente - UUID del docente propietario.
   */
  async finalizar(idSesion: string, idDocente: string) {
    const sesion = await this.prisma.sesionExamen.findUnique({ where: { id: idSesion } });
    if (!sesion) {
      throw new NotFoundException('Sesión no encontrada');
    }

    if (sesion.creadaPorId !== idDocente) {
      throw new ForbiddenException('No tiene permisos sobre esta sesión');
    }

    if (sesion.estado !== EstadoSesion.ACTIVA) {
      throw new BadRequestException('La sesión no está activa');
    }

    const fechaFin = new Date();
    const actualizada = await this.prisma.sesionExamen.update({
      where: { id: idSesion },
      data: { estado: EstadoSesion.FINALIZADA, fechaFin },
    });

    this.gateway.emitirSesionFinalizada(idSesion);
    await this.respuestasService.calcularPuntajesTodosIntentos(idSesion);
    return actualizada;
  }

  /**
   * Busca sesión por código de acceso para flujo estudiantil.
   * @param codigo - Código corto de sesión.
   */
  async buscarPorCodigo(codigo: string) {
    const sesion = await this.prisma.sesionExamen.findUnique({ where: { codigoAcceso: codigo }, include: { examen: true } });
    if (!sesion) {
      throw new NotFoundException('Sesión no encontrada');
    }

    return {
      id: sesion.id,
      codigoAcceso: sesion.codigoAcceso,
      estado: sesion.estado,
      examen: {
        id: sesion.examen.id,
        titulo: sesion.examen.titulo,
        modalidad: sesion.examen.modalidad,
      },
    };
  }

  /**
   * Genera un código de acceso único con máximo de intentos permitido.
   */
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
}
