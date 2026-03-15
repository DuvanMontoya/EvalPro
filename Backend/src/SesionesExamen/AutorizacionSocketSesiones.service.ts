/**
 * @archivo   AutorizacionSocketSesiones.service.ts
 * @descripcion Resuelve autenticación JWT y validaciones de permiso para eventos socket de sesiones.
 * @modulo    SesionesExamen
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { EstadoCuenta, EstadoInstitucion, EstadoIntento, RolUsuario } from '@prisma/client';
import { Socket } from 'socket.io';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { calcularIndicesPreguntasRespondidas } from '../Comun/Utilidades/ProgresoPreguntas.util';
import { obtenerEstadosNoTerminalesIntento } from '../Intentos/MaquinaEstadosIntento.util';

const EMISOR_JWT_DEFECTO = 'evalpro-backend';
const AUDIENCIA_JWT_DEFECTO = 'evalpro-cliente';

export interface UsuarioSocket {
  id: string;
  correo: string;
  rol: RolUsuario;
  idInstitucion: string | null;
}

@Injectable()
export class AutorizacionSocketSesionesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly servicioConfiguracion: ConfigService,
  ) {}

  /**
   * Valida el token de acceso del handshake y retorna el usuario activo asociado.
   * @param cliente - Socket en conexión inicial.
   * @returns Usuario del socket o nulo si no pudo autenticarse.
   */
  async autenticarCliente(cliente: Socket): Promise<UsuarioSocket | null> {
    const token = this.extraerToken(cliente);
    if (!token) {
      return null;
    }

    try {
      const payload = await this.jwtService.verifyAsync<{ sub: string; idInstitucion?: string | null }>(token, {
        secret: this.servicioConfiguracion.get<string>('JWT_SECRETO_ACCESO', ''),
        issuer: this.servicioConfiguracion.get<string>('JWT_EMISOR', EMISOR_JWT_DEFECTO),
        audience: this.servicioConfiguracion.get<string>('JWT_AUDIENCIA', AUDIENCIA_JWT_DEFECTO),
      });
      const usuario = await this.prisma.usuario.findUnique({
        where: { id: payload.sub },
        select: {
          id: true,
          correo: true,
          rol: true,
          activo: true,
          idInstitucion: true,
          estadoCuenta: true,
          bloqueadoHasta: true,
          institucion: { select: { estado: true } },
        },
      });
      if (!usuario || !usuario.activo || usuario.estadoCuenta !== EstadoCuenta.ACTIVO) {
        return null;
      }
      if (usuario.bloqueadoHasta && usuario.bloqueadoHasta.getTime() > Date.now()) {
        return null;
      }
      if (usuario.rol !== RolUsuario.SUPERADMINISTRADOR) {
        if (!usuario.idInstitucion || !usuario.institucion || usuario.institucion.estado !== EstadoInstitucion.ACTIVA) {
          return null;
        }
      }
      return { id: usuario.id, correo: usuario.correo, rol: usuario.rol, idInstitucion: usuario.idInstitucion ?? null };
    } catch {
      return null;
    }
  }

  /**
   * Determina si un usuario socket puede unirse a una sala de sesión concreta.
   * @param idSesion - UUID de sesión objetivo.
   * @param usuario - Usuario autenticado en el socket.
   * @returns Verdadero si el usuario tiene permiso de unión.
   */
  async puedeUnirseASesion(idSesion: string, usuario: UsuarioSocket): Promise<boolean> {
    const sesion = await this.prisma.sesionExamen.findUnique({
      where: { id: idSesion },
      select: { id: true, creadaPorId: true, idInstitucion: true },
    });
    if (!sesion) {
      return false;
    }
    if (usuario.rol !== RolUsuario.SUPERADMINISTRADOR && sesion.idInstitucion !== usuario.idInstitucion) {
      return false;
    }
    if (usuario.rol === RolUsuario.SUPERADMINISTRADOR || usuario.rol === RolUsuario.ADMINISTRADOR) {
      return true;
    }
    if (usuario.rol === RolUsuario.DOCENTE) {
      return sesion.creadaPorId === usuario.id;
    }
    const intento = await this.prisma.intentoExamen.findFirst({
      where: { sesionId: sesion.id, estudianteId: usuario.id },
      select: { id: true },
    });
    return Boolean(intento);
  }

  /**
   * Determina si un usuario socket puede publicar eventos para un intento específico.
   * @param idIntento - UUID del intento reportado por el socket.
   * @param usuario - Usuario autenticado en el socket.
   * @returns Sesión del intento si existe permiso; nulo en caso contrario.
   */
  async obtenerSesionAutorizadaPorIntento(idIntento: string, usuario: UsuarioSocket): Promise<string | null> {
    const intento = await this.prisma.intentoExamen.findUnique({
      where: { id: idIntento },
      include: { sesion: { select: { creadaPorId: true, idInstitucion: true } } },
    });
    if (!intento) {
      return null;
    }
    if (usuario.rol !== RolUsuario.SUPERADMINISTRADOR && intento.sesion.idInstitucion !== usuario.idInstitucion) {
      return null;
    }
    if (usuario.rol === RolUsuario.SUPERADMINISTRADOR || usuario.rol === RolUsuario.ADMINISTRADOR) {
      return intento.sesionId;
    }
    if (usuario.rol === RolUsuario.DOCENTE) {
      return intento.sesion.creadaPorId === usuario.id ? intento.sesionId : null;
    }
    return intento.estudianteId === usuario.id ? intento.sesionId : null;
  }

  /**
   * Obtiene el intento activo de un estudiante dentro de una sesión para bootstrap de monitoreo.
   * @param idSesion - UUID de la sesión.
   * @param idEstudiante - UUID del estudiante autenticado en socket.
   */
  async obtenerIntentoActivoSesionEstudiante(
    idSesion: string,
    idEstudiante: string,
  ): Promise<{
    idIntento: string;
    idEstudiante: string;
    nombreCompleto: string;
    preguntasRespondidas: number;
    preguntasRespondidasIndices: number[];
    totalPreguntas: number;
  } | null> {
    const intento = await this.prisma.intentoExamen.findFirst({
      where: {
        sesionId: idSesion,
        estudianteId: idEstudiante,
        estado: { in: obtenerEstadosNoTerminalesIntento() },
      },
      include: {
        estudiante: {
          select: {
            nombre: true,
            apellidos: true,
          },
        },
        sesion: {
          select: {
            examen: {
              select: {
                totalPreguntas: true,
                preguntas: { select: { id: true } },
              },
            },
          },
        },
        respuestas: {
          select: {
            preguntaId: true,
          },
        },
        _count: {
          select: {
            respuestas: true,
          },
        },
      },
      orderBy: { fechaInicio: 'desc' },
    });
    if (!intento) {
      return null;
    }

    const preguntasRespondidasIndices = calcularIndicesPreguntasRespondidas(
      intento.ordenPreguntasAplicado,
      intento.respuestas.map((respuesta) => respuesta.preguntaId),
      intento.sesion.examen.preguntas.map((pregunta) => pregunta.id),
    );

    return {
      idIntento: intento.id,
      idEstudiante: intento.estudianteId,
      nombreCompleto: `${intento.estudiante.nombre} ${intento.estudiante.apellidos}`.trim(),
      preguntasRespondidas: intento._count.respuestas,
      preguntasRespondidasIndices,
      totalPreguntas: intento.sesion.examen.totalPreguntas,
    };
  }

  private extraerToken(cliente: Socket): string | null {
    const tokenAuth = typeof cliente.handshake.auth?.token === 'string' ? cliente.handshake.auth.token : null;
    const tokenAuthAcceso =
      typeof cliente.handshake.auth?.tokenAcceso === 'string' ? cliente.handshake.auth.tokenAcceso : null;
    const autorizacion = typeof cliente.handshake.headers.authorization === 'string'
      ? cliente.handshake.headers.authorization
      : '';
    const tokenEncabezado = autorizacion.startsWith('Bearer ') ? autorizacion.slice(7).trim() : null;
    return tokenAuth ?? tokenAuthAcceso ?? tokenEncabezado;
  }
}
