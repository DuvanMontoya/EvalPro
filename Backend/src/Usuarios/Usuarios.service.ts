/**
 * @archivo   Usuarios.service.ts
 * @descripcion Implementa operaciones CRUD de usuarios con aislamiento tenant y primer login obligatorio.
 * @modulo    Usuarios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EstadoCuenta, RolUsuario } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomBytes } from 'crypto';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { CODIGOS_ERROR } from '../Comun/Constantes/Mensajes.constantes';
import { CrearUsuarioDto } from './Dto/CrearUsuario.dto';
import { CrearUsuarioRolDto } from './Dto/CrearUsuarioRol.dto';
import { ActualizarUsuarioDto } from './Dto/ActualizarUsuario.dto';
import { RespuestaUsuarioDto } from './Dto/RespuestaUsuario.dto';
import { mapearUsuarioRespuesta, normalizarCorreoUsuario } from './Utilidades/TransformadorUsuario.util';

const HORAS_CREDENCIAL_TEMPORAL = 48;

@Injectable()
export class UsuariosService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly servicioConfiguracion: ConfigService,
  ) {}

  /**
   * Lista usuarios según alcance del rol y tenant del solicitante.
   */
  async listar(rolSolicitante: RolUsuario, idSolicitante: string, idInstitucionSolicitante: string | null): Promise<RespuestaUsuarioDto[]> {
    const where: Record<string, unknown> = {};
    if (rolSolicitante !== RolUsuario.SUPERADMINISTRADOR) {
      where.idInstitucion = idInstitucionSolicitante;
    }
    if (rolSolicitante === RolUsuario.DOCENTE || rolSolicitante === RolUsuario.ESTUDIANTE) {
      where.id = idSolicitante;
    }

    const usuarios = await this.prisma.usuario.findMany({ where, orderBy: { fechaCreacion: 'desc' } });
    return usuarios.map((usuario) => mapearUsuarioRespuesta(usuario));
  }

  /**
   * Crea un usuario en el tenant del administrador autenticado.
   */
  async crear(
    dto: CrearUsuarioDto,
    idInstitucionSolicitante: string | null,
  ): Promise<RespuestaUsuarioDto> {
    if (dto.rol === RolUsuario.ADMINISTRADOR || dto.rol === RolUsuario.SUPERADMINISTRADOR) {
      throw new BadRequestException({
        message: 'No se permite crear administradores por esta ruta',
        codigoError: CODIGOS_ERROR.ROL_NO_PERMITIDO,
      });
    }
    return this.crearConRol(
      {
        nombre: dto.nombre,
        apellidos: dto.apellidos,
        correo: dto.correo,
        contrasena: dto.contrasena,
      },
      dto.rol,
      idInstitucionSolicitante,
    );
  }

  /**
   * Crea un usuario con rol DOCENTE usando credencial temporal.
   */
  async crearDocente(dto: CrearUsuarioRolDto, idInstitucionSolicitante: string | null): Promise<RespuestaUsuarioDto> {
    return this.crearConRol(dto, RolUsuario.DOCENTE, idInstitucionSolicitante);
  }

  /**
   * Crea un usuario con rol ESTUDIANTE usando credencial temporal.
   */
  async crearEstudiante(dto: CrearUsuarioRolDto, idInstitucionSolicitante: string | null): Promise<RespuestaUsuarioDto> {
    return this.crearConRol(dto, RolUsuario.ESTUDIANTE, idInstitucionSolicitante);
  }

  /**
   * Crea usuario aplicando normalización de correo y flujo de activación inicial.
   */
  private async crearConRol(
    dto: CrearUsuarioRolDto,
    rol: RolUsuario,
    idInstitucionSolicitante: string | null,
  ): Promise<RespuestaUsuarioDto> {
    if (!idInstitucionSolicitante) {
      throw new ForbiddenException('El actor no tiene institución asociada');
    }

    const correoNormalizado = normalizarCorreoUsuario(dto.correo);
    await this.validarCorreoUnico(correoNormalizado);

    const rondasHash = this.obtenerRondasHash();
    const credencialTemporalPlano = this.generarCredencialTemporal();
    const hashTemporal = await bcrypt.hash(credencialTemporalPlano, rondasHash);

    const usuario = await this.prisma.usuario.create({
      data: {
        nombre: dto.nombre,
        apellidos: dto.apellidos,
        correo: correoNormalizado,
        contrasena: hashTemporal,
        rol,
        idInstitucion: idInstitucionSolicitante,
        estadoCuenta: EstadoCuenta.PENDIENTE_ACTIVACION,
        primerLogin: true,
        credencialTemporal: hashTemporal,
        credencialTemporalVence: this.calcularVencimientoCredencialTemporal(),
      },
    });

    const respuesta = mapearUsuarioRespuesta(usuario);
    respuesta.credencialTemporalPlano = credencialTemporalPlano;
    return respuesta;
  }

  /**
   * Obtiene usuario por ID validando alcance por rol.
   */
  async obtenerPorId(
    id: string,
    rolSolicitante: RolUsuario,
    idSolicitante: string,
    idInstitucionSolicitante: string | null,
  ): Promise<RespuestaUsuarioDto> {
    const usuario = await this.prisma.usuario.findUnique({ where: { id } });
    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    this.validarAccesoUsuario(usuario.id, usuario.idInstitucion, rolSolicitante, idSolicitante, idInstitucionSolicitante);
    return mapearUsuarioRespuesta(usuario);
  }

  /**
   * Actualiza usuario con reglas de rol y tenant.
   */
  async actualizar(
    id: string,
    dto: ActualizarUsuarioDto,
    rolSolicitante: RolUsuario,
    idSolicitante: string,
    idInstitucionSolicitante: string | null,
  ): Promise<RespuestaUsuarioDto> {
    const usuario = await this.prisma.usuario.findUnique({ where: { id } });
    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    this.validarAccesoUsuario(usuario.id, usuario.idInstitucion, rolSolicitante, idSolicitante, idInstitucionSolicitante);

    if (
      typeof dto.rol !== 'undefined' &&
      rolSolicitante !== RolUsuario.ADMINISTRADOR &&
      rolSolicitante !== RolUsuario.SUPERADMINISTRADOR
    ) {
      throw new ForbiddenException('Solo ADMINISTRADOR o SUPERADMINISTRADOR pueden cambiar roles');
    }

    if (
      rolSolicitante !== RolUsuario.SUPERADMINISTRADOR &&
      (dto.rol === RolUsuario.ADMINISTRADOR || dto.rol === RolUsuario.SUPERADMINISTRADOR)
    ) {
      throw new BadRequestException({
        message: 'Solo SUPERADMINISTRADOR puede asignar roles administrativos altos',
        codigoError: CODIGOS_ERROR.ROL_NO_PERMITIDO,
      });
    }

    const correoNormalizado = dto.correo ? normalizarCorreoUsuario(dto.correo) : undefined;
    if (correoNormalizado && correoNormalizado !== usuario.correo) {
      await this.validarCorreoUnico(correoNormalizado);
    }

    const rondasHash = this.obtenerRondasHash();
    const contrasenaHash = dto.contrasena ? await bcrypt.hash(dto.contrasena, rondasHash) : undefined;

    const actualizado = await this.prisma.usuario.update({
      where: { id },
      data: {
        nombre: dto.nombre,
        apellidos: dto.apellidos,
        correo: correoNormalizado,
        rol: dto.rol,
        contrasena: contrasenaHash,
        tokenRefresh: dto.contrasena ? null : undefined,
        estadoCuenta: dto.contrasena ? EstadoCuenta.ACTIVO : undefined,
        primerLogin: dto.contrasena ? false : undefined,
        credencialTemporal: dto.contrasena ? null : undefined,
        credencialTemporalVence: dto.contrasena ? null : undefined,
      },
    });

    return mapearUsuarioRespuesta(actualizado);
  }

  /**
   * Desactiva lógicamente usuario por ID respetando tenant.
   */
  async desactivar(id: string, rolSolicitante: RolUsuario, idInstitucionSolicitante: string | null): Promise<RespuestaUsuarioDto> {
    const usuario = await this.prisma.usuario.findUnique({ where: { id } });
    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    if (
      rolSolicitante !== RolUsuario.SUPERADMINISTRADOR &&
      usuario.idInstitucion !== idInstitucionSolicitante
    ) {
      throw new ForbiddenException('No puede desactivar usuarios de otra institución');
    }

    const actualizado = await this.prisma.usuario.update({
      where: { id },
      data: { activo: false, estadoCuenta: EstadoCuenta.SUSPENDIDO, tokenRefresh: null },
    });
    return mapearUsuarioRespuesta(actualizado);
  }

  /**
   * Verifica que no exista otro usuario con el mismo correo.
   */
  private async validarCorreoUnico(correo: string): Promise<void> {
    const existente = await this.prisma.usuario.findUnique({ where: { correo } });
    if (existente) {
      throw new ConflictException({
        message: 'Ya existe un usuario con ese correo',
        codigoError: CODIGOS_ERROR.USUARIO_YA_EXISTE,
      });
    }
  }

  private validarAccesoUsuario(
    idObjetivo: string,
    idInstitucionObjetivo: string | null,
    rolSolicitante: RolUsuario,
    idSolicitante: string,
    idInstitucionSolicitante: string | null,
  ): void {
    if (rolSolicitante === RolUsuario.SUPERADMINISTRADOR) {
      return;
    }

    if (idInstitucionObjetivo !== idInstitucionSolicitante) {
      throw new ForbiddenException('No puede operar sobre usuarios fuera de su institución');
    }

    if (rolSolicitante === RolUsuario.ADMINISTRADOR) {
      return;
    }

    if (idObjetivo !== idSolicitante) {
      throw new ForbiddenException('No puede operar sobre otro usuario');
    }
  }

  private generarCredencialTemporal(): string {
    return randomBytes(9).toString('base64url').slice(0, 12).toUpperCase();
  }

  private calcularVencimientoCredencialTemporal(): Date {
    return new Date(Date.now() + HORAS_CREDENCIAL_TEMPORAL * 60 * 60_000);
  }

  private obtenerRondasHash(): number {
    const valorConfigurado = Number(this.servicioConfiguracion.get<string>('BCRYPT_RONDAS_HASH', '12'));
    return Number.isFinite(valorConfigurado) && valorConfigurado >= 12 ? valorConfigurado : 12;
  }
}
