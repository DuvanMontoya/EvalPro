/**
 * @archivo   Usuarios.service.ts
 * @descripcion Implementa operaciones CRUD de usuarios con resguardo de datos sensibles.
 * @modulo    Usuarios
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { Injectable, NotFoundException } from '@nestjs/common';
import { RolUsuario } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { CrearUsuarioDto } from './Dto/CrearUsuario.dto';
import { ActualizarUsuarioDto } from './Dto/ActualizarUsuario.dto';
import { RespuestaUsuarioDto } from './Dto/RespuestaUsuario.dto';

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
    return usuarios.map((usuario) => this.mapearUsuario(usuario));
  }

  /**
   * Crea un usuario hasheando su contraseña antes de persistir.
   * @param dto - Datos de creación.
   * @returns Usuario creado sin contraseña ni refresh token.
   */
  async crear(dto: CrearUsuarioDto): Promise<RespuestaUsuarioDto> {
    const rondasHash = Number(this.servicioConfiguracion.get<string>('BCRYPT_RONDAS_HASH', '12'));
    const contrasenaHash = await bcrypt.hash(dto.contrasena, rondasHash);

    const usuario = await this.prisma.usuario.create({
      data: {
        nombre: dto.nombre,
        apellidos: dto.apellidos,
        correo: dto.correo,
        contrasena: contrasenaHash,
        rol: dto.rol,
      },
    });

    return this.mapearUsuario(usuario);
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

    return this.mapearUsuario(usuario);
  }

  /**
   * Actualiza datos de un usuario y rehashea contraseña cuando aplica.
   * @param id - UUID del usuario.
   * @param dto - Datos parciales a modificar.
   * @returns Usuario actualizado sin campos sensibles.
   */
  async actualizar(id: string, dto: ActualizarUsuarioDto): Promise<RespuestaUsuarioDto> {
    const usuario = await this.prisma.usuario.findUnique({ where: { id } });
    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    const rondasHash = Number(this.servicioConfiguracion.get<string>('BCRYPT_RONDAS_HASH', '12'));
    const contrasenaHash = dto.contrasena ? await bcrypt.hash(dto.contrasena, rondasHash) : undefined;

    const actualizado = await this.prisma.usuario.update({
      where: { id },
      data: {
        nombre: dto.nombre,
        apellidos: dto.apellidos,
        correo: dto.correo,
        rol: dto.rol,
        contrasena: contrasenaHash,
      },
    });

    return this.mapearUsuario(actualizado);
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
    return this.mapearUsuario(actualizado);
  }

  /**
   * Mapea la entidad de Prisma al DTO de respuesta sin datos sensibles.
   * @param usuario - Registro de usuario en base de datos.
   * @returns DTO listo para respuesta al cliente.
   */
  private mapearUsuario(usuario: {
    id: string;
    nombre: string;
    apellidos: string;
    correo: string;
    rol: RolUsuario;
    activo: boolean;
    fechaCreacion: Date;
    fechaActualizacion: Date;
  }): RespuestaUsuarioDto {
    return {
      id: usuario.id,
      nombre: usuario.nombre,
      apellidos: usuario.apellidos,
      correo: usuario.correo,
      rol: usuario.rol,
      activo: usuario.activo,
      fechaCreacion: usuario.fechaCreacion,
      fechaActualizacion: usuario.fechaActualizacion,
    };
  }
}
