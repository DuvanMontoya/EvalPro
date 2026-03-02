/**
 * @archivo   Usuarios.service.ts
 * @descripcion Implementa operaciones CRUD de usuarios con resguardo de datos sensibles.
 * @modulo    Usuarios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { RolUsuario } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { CODIGOS_ERROR } from '../Comun/Constantes/Mensajes.constantes';
import { CrearUsuarioDto } from './Dto/CrearUsuario.dto';
import { CrearUsuarioRolDto } from './Dto/CrearUsuarioRol.dto';
import { ActualizarUsuarioDto } from './Dto/ActualizarUsuario.dto';
import { RespuestaUsuarioDto } from './Dto/RespuestaUsuario.dto';
import { mapearUsuarioRespuesta, normalizarCorreoUsuario } from './Utilidades/TransformadorUsuario.util';

@Injectable()
export class UsuariosService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly servicioConfiguracion: ConfigService,
  ) {}

  /**
   * Lista usuarios según permisos del solicitante.
   * @param rolSolicitante - Rol del usuario autenticado.
   * @param idSolicitante - ID del usuario autenticado.
   * @returns Arreglo de usuarios sin campos sensibles.
   */
  async listar(rolSolicitante: RolUsuario, idSolicitante: string): Promise<RespuestaUsuarioDto[]> {
    const filtro = rolSolicitante === RolUsuario.ADMINISTRADOR ? {} : { id: idSolicitante };
    const usuarios = await this.prisma.usuario.findMany({ where: filtro, orderBy: { fechaCreacion: 'desc' } });
    return usuarios.map((usuario) => mapearUsuarioRespuesta(usuario));
  }

  /**
   * Crea un usuario hasheando su contraseña antes de persistir.
   * @param dto - Datos de creación.
   * @returns Usuario creado sin contraseña ni refresh token.
   */
  async crear(dto: CrearUsuarioDto): Promise<RespuestaUsuarioDto> {
    if (dto.rol === RolUsuario.ADMINISTRADOR) {
      throw new BadRequestException({
        message: 'No se permite crear administradores desde esta ruta',
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
    );
  }

  /**
   * Crea un usuario con rol DOCENTE.
   * @param dto - Datos de alta del docente.
   * @returns Usuario creado en rol docente.
   */
  async crearDocente(dto: CrearUsuarioRolDto): Promise<RespuestaUsuarioDto> {
    return this.crearConRol(dto, RolUsuario.DOCENTE);
  }

  /**
   * Crea un usuario con rol ESTUDIANTE.
   * @param dto - Datos de alta del estudiante.
   * @returns Usuario creado en rol estudiante.
   */
  async crearEstudiante(dto: CrearUsuarioRolDto): Promise<RespuestaUsuarioDto> {
    return this.crearConRol(dto, RolUsuario.ESTUDIANTE);
  }

  /**
   * Crea un usuario aplicando normalización de correo y validación de unicidad.
   * @param dto - Datos de creación base.
   * @param rol - Rol final asignado al usuario.
   * @returns Usuario creado sin campos sensibles.
   */
  private async crearConRol(dto: CrearUsuarioRolDto, rol: RolUsuario): Promise<RespuestaUsuarioDto> {
    const rondasHash = Number(this.servicioConfiguracion.get<string>('BCRYPT_RONDAS_HASH', '12'));
    const contrasenaHash = await bcrypt.hash(dto.contrasena, rondasHash);
    const correoNormalizado = normalizarCorreoUsuario(dto.correo);
    await this.validarCorreoUnico(correoNormalizado);

    const usuario = await this.prisma.usuario.create({
      data: {
        nombre: dto.nombre,
        apellidos: dto.apellidos,
        correo: correoNormalizado,
        contrasena: contrasenaHash,
        rol,
      },
    });

    return mapearUsuarioRespuesta(usuario);
  }

  /**
   * Obtiene un usuario por su identificador.
   * @param id - UUID del usuario.
   * @returns Datos de usuario sin campos sensibles.
   */
  async obtenerPorId(id: string): Promise<RespuestaUsuarioDto> {
    const usuario = await this.prisma.usuario.findUnique({ where: { id } });
    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    return mapearUsuarioRespuesta(usuario);
  }

  /**
   * Actualiza datos de un usuario y rehashea contraseña cuando aplica.
   * @param id - UUID del usuario.
   * @param dto - Datos parciales a modificar.
   * @param rolSolicitante - Rol del usuario autenticado.
   * @param idSolicitante - UUID del usuario autenticado.
   * @returns Usuario actualizado sin campos sensibles.
   */
  async actualizar(
    id: string,
    dto: ActualizarUsuarioDto,
    rolSolicitante: RolUsuario,
    idSolicitante: string,
  ): Promise<RespuestaUsuarioDto> {
    const usuario = await this.prisma.usuario.findUnique({ where: { id } });
    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    if (rolSolicitante !== RolUsuario.ADMINISTRADOR && typeof dto.rol !== 'undefined') {
      throw new ForbiddenException('Solo el administrador puede cambiar roles');
    }
    if (rolSolicitante === RolUsuario.ADMINISTRADOR && dto.rol === RolUsuario.ADMINISTRADOR && id !== idSolicitante) {
      throw new BadRequestException({
        message: 'No se permite elevar otros usuarios al rol administrador',
        codigoError: CODIGOS_ERROR.ROL_NO_PERMITIDO,
      });
    }
    const correoNormalizado = dto.correo ? normalizarCorreoUsuario(dto.correo) : undefined;
    if (correoNormalizado && correoNormalizado !== usuario.correo) {
      await this.validarCorreoUnico(correoNormalizado);
    }

    const rondasHash = Number(this.servicioConfiguracion.get<string>('BCRYPT_RONDAS_HASH', '12'));
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
      },
    });

    return mapearUsuarioRespuesta(actualizado);
  }

  /**
   * Desactiva lógicamente un usuario sin eliminar su registro.
   * @param id - UUID del usuario.
   * @returns Usuario desactivado.
   */
  async desactivar(id: string): Promise<RespuestaUsuarioDto> {
    const usuario = await this.prisma.usuario.findUnique({ where: { id } });
    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    const actualizado = await this.prisma.usuario.update({ where: { id }, data: { activo: false } });
    return mapearUsuarioRespuesta(actualizado);
  }

  /**
   * Verifica que no exista otro usuario con el mismo correo.
   * @param correo - Correo normalizado a verificar.
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
}
