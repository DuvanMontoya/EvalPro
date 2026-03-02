/**
 * @archivo   Autenticacion.service.ts
 * @descripcion Implementa autenticación con JWT de acceso/refresh y gestión segura de credenciales.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ForbiddenException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { RolUsuario, Usuario } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { RegistrarUsuarioDto } from './Dto/RegistrarUsuario.dto';

const EMISOR_JWT_DEFECTO = 'evalpro-backend';
const AUDIENCIA_JWT_DEFECTO = 'evalpro-cliente';

interface UsuarioSinDatosSensibles extends Omit<Usuario, 'contrasena' | 'tokenRefresh'> {}

export interface RespuestaSesion {
  tokenAcceso: string;
  tokenRefresh: string;
  usuario: UsuarioSinDatosSensibles;
}

@Injectable()
export class AutenticacionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly servicioConfiguracion: ConfigService,
  ) {}

  /**
   * Valida credenciales del usuario comparando correo y hash de contraseña.
   * @param correo - Correo del usuario.
   * @param contrasena - Contraseña en texto plano.
   * @returns Usuario sin contraseña o nulo cuando las credenciales son inválidas.
   */
  async validarCredenciales(correo: string, contrasena: string): Promise<UsuarioSinDatosSensibles | null> {
    const usuario = await this.prisma.usuario.findUnique({ where: { correo } });
    if (!usuario || !usuario.activo) {
      return null;
    }

    const coincide = await bcrypt.compare(contrasena, usuario.contrasena);
    if (!coincide) {
      return null;
    }

    return this.mapearUsuarioSinDatosSensibles(usuario);
  }

  /**
   * Emite tokens de acceso y refresh para un usuario autenticado y persiste hash del refresh.
   * @param usuario - Usuario autenticado sin contraseña.
   * @returns Tokens emitidos y usuario de respuesta.
   */
  async iniciarSesion(usuario: UsuarioSinDatosSensibles): Promise<RespuestaSesion> {
    const configuracionFirmado = {
      issuer: this.servicioConfiguracion.get<string>('JWT_EMISOR', EMISOR_JWT_DEFECTO),
      audience: this.servicioConfiguracion.get<string>('JWT_AUDIENCIA', AUDIENCIA_JWT_DEFECTO),
    };
    const payload = { sub: usuario.id, correo: usuario.correo, rol: usuario.rol };
    const tokenAcceso = await this.jwtService.signAsync(payload, {
      secret: this.servicioConfiguracion.get<string>('JWT_SECRETO_ACCESO', ''),
      expiresIn: this.servicioConfiguracion.get<string>('JWT_EXPIRACION_ACCESO', '15m'),
      jwtid: randomUUID(),
      ...configuracionFirmado,
    });

    const tokenRefresh = await this.jwtService.signAsync(payload, {
      secret: this.servicioConfiguracion.get<string>('JWT_SECRETO_REFRESH', ''),
      expiresIn: this.servicioConfiguracion.get<string>('JWT_EXPIRACION_REFRESH', '7d'),
      jwtid: randomUUID(),
      ...configuracionFirmado,
    });

    const rondasHash = Number(this.servicioConfiguracion.get<string>('BCRYPT_RONDAS_HASH', '12'));
    const hashRefresh = await bcrypt.hash(tokenRefresh, rondasHash);
    await this.prisma.usuario.update({
      where: { id: usuario.id },
      data: { tokenRefresh: hashRefresh },
    });

    return { tokenAcceso, tokenRefresh, usuario };
  }

  /**
   * Renueva tokens validando el refresh token recibido contra el hash almacenado.
   * @param idUsuario - Identificador del usuario propietario del token.
   * @param tokenRefreshRecibido - Refresh token enviado por el cliente.
   * @returns Nuevo par de tokens y datos de usuario.
   */
  async refrescarTokens(idUsuario: string, tokenRefreshRecibido: string): Promise<RespuestaSesion> {
    const usuario = await this.prisma.usuario.findUnique({ where: { id: idUsuario } });
    if (!usuario || !usuario.activo || !usuario.tokenRefresh) {
      throw new ForbiddenException('No autorizado para refrescar tokens');
    }

    const coincide = await bcrypt.compare(tokenRefreshRecibido, usuario.tokenRefresh);
    if (!coincide) {
      throw new ForbiddenException('No autorizado para refrescar tokens');
    }

    return this.iniciarSesion(this.mapearUsuarioSinDatosSensibles(usuario));
  }

  /**
   * Invalida sesión del usuario eliminando su hash de refresh token persistido.
   * @param idUsuario - Identificador del usuario autenticado.
   */
  async cerrarSesion(idUsuario: string): Promise<void> {
    await this.prisma.usuario.update({
      where: { id: idUsuario },
      data: { tokenRefresh: null },
    });
  }

  /**
   * Registra un nuevo usuario con contraseña hasheada para escenarios de alta inicial.
   * @param dto - Datos de creación de usuario.
   * @returns Usuario creado sin datos sensibles.
   */
  async registrar(dto: RegistrarUsuarioDto): Promise<UsuarioSinDatosSensibles> {
    const rondasHash = Number(this.servicioConfiguracion.get<string>('BCRYPT_RONDAS_HASH', '12'));
    const contrasena = await bcrypt.hash(dto.contrasena, rondasHash);

    const usuarioCreado = await this.prisma.usuario.create({
      data: {
        nombre: dto.nombre,
        apellidos: dto.apellidos,
        correo: dto.correo,
        contrasena,
        rol: dto.rol ?? RolUsuario.ESTUDIANTE,
      },
    });

    return this.mapearUsuarioSinDatosSensibles(usuarioCreado);
  }

  /**
   * Remueve campos sensibles del usuario para retornarlo en respuestas de autenticación.
   * @param usuario - Entidad de usuario obtenida desde base de datos.
   * @returns Usuario listo para enviar al cliente sin secretos.
   */
  private mapearUsuarioSinDatosSensibles(usuario: Usuario): UsuarioSinDatosSensibles {
    const { contrasena: _contrasena, tokenRefresh: _tokenRefresh, ...usuarioSinDatosSensibles } = usuario;
    return usuarioSinDatosSensibles;
  }
}
