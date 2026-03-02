/**
 * @archivo   Autenticacion.service.ts
 * @descripcion Implementa autenticación con JWT de acceso/refresh, primer login y bloqueo de cuenta.
 * @modulo    Autenticacion
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import { ForbiddenException, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { EstadoCuenta, EstadoInstitucion, RolUsuario, Usuario } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomBytes, randomUUID } from 'crypto';
import { AuditoriaService } from '../Auditoria/Auditoria.service';
import { PrismaService } from '../Configuracion/BaseDatos.config';
import { RegistrarUsuarioDto } from './Dto/RegistrarUsuario.dto';
import { BlacklistTokensService } from './Servicios/BlacklistTokens.service';

const EMISOR_JWT_DEFECTO = 'evalpro-backend';
const AUDIENCIA_JWT_DEFECTO = 'evalpro-cliente';
const INTENTOS_MAXIMOS_LOGIN = 5;
const MINUTOS_BLOQUEO_LOGIN = 30;
const HORAS_VIGENCIA_CREDENCIAL_TEMPORAL = 48;
const EXPIRACION_TOKEN_TEMPORAL = '15m';
const PATRON_CONTRASENA_SEGURA = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$/;

interface UsuarioConInstitucion extends Usuario {
  institucion: {
    estado: EstadoInstitucion;
  } | null;
}

interface UsuarioSinDatosSensibles
  extends Omit<Usuario, 'contrasena' | 'tokenRefresh' | 'credencialTemporal'> {}

interface ContextoCliente {
  ip?: string | null;
  userAgent?: string | null;
}

export interface RespuestaSesion {
  tokenAcceso: string;
  tokenRefresh: string;
  usuario: UsuarioSinDatosSensibles;
}

export interface RespuestaPrimerLogin {
  requiereCambioContrasena: true;
  tokenTemporal: string;
}

export type RespuestaInicioSesion = RespuestaSesion | RespuestaPrimerLogin;

@Injectable()
export class AutenticacionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly servicioConfiguracion: ConfigService,
    private readonly blacklistTokensService: BlacklistTokensService,
    private readonly auditoriaService: AuditoriaService,
  ) {}

  /**
   * Autentica credenciales y retorna sesión completa o token temporal para primer login.
   */
  async iniciarSesionConCredenciales(
    correo: string,
    contrasena: string,
    contextoCliente: ContextoCliente = {},
  ): Promise<RespuestaInicioSesion> {
    const correoNormalizado = this.normalizarCorreo(correo);
    const usuario = await this.prisma.usuario.findUnique({
      where: { correo: correoNormalizado },
      include: { institucion: { select: { estado: true } } },
    });

    if (!usuario) {
      await this.registrarAuditoriaLogin(null, RolUsuario.ESTUDIANTE, 'LOGIN_FALLIDO', contextoCliente, {
        correo: correoNormalizado,
      });
      throw new UnauthorizedException('Credenciales inválidas');
    }

    await this.validarEstadoCuentaAntesDeContrasena(usuario);

    const coincide = await bcrypt.compare(contrasena, usuario.contrasena);
    if (!coincide) {
      await this.procesarIntentoLoginFallido(usuario, contextoCliente);
      throw new UnauthorizedException('Credenciales inválidas');
    }

    await this.prisma.usuario.update({
      where: { id: usuario.id },
      data: { intentosFallidosLogin: 0, bloqueadoHasta: null },
    });

    if (usuario.primerLogin) {
      const respuestaPrimerLogin = await this.procesarPrimerLogin(usuario, contrasena, contextoCliente);
      return respuestaPrimerLogin;
    }

    this.validarInstitucionActiva(usuario);

    const actualizado = await this.prisma.usuario.update({
      where: { id: usuario.id },
      data: {
        ultimoLogin: new Date(),
        estadoCuenta: EstadoCuenta.ACTIVO,
      },
      include: { institucion: { select: { estado: true } } },
    });

    const sesion = await this.emitirSesionCompleta(actualizado);
    await this.registrarAuditoriaLogin(actualizado.id, actualizado.rol, 'LOGIN_EXITOSO', contextoCliente, {
      idUsuario: actualizado.id,
    });
    return sesion;
  }

  /**
   * Renueva tokens validando refresh token y estado de cuenta del usuario.
   */
  async refrescarTokens(
    idUsuario: string,
    tokenRefreshRecibido: string,
    contextoCliente: ContextoCliente = {},
  ): Promise<RespuestaSesion> {
    const usuario = await this.prisma.usuario.findUnique({
      where: { id: idUsuario },
      include: { institucion: { select: { estado: true } } },
    });

    if (!usuario || !usuario.tokenRefresh || !usuario.activo || usuario.estadoCuenta !== EstadoCuenta.ACTIVO) {
      throw new ForbiddenException('No autorizado para refrescar tokens');
    }

    this.validarInstitucionActiva(usuario);

    const coincide = await bcrypt.compare(tokenRefreshRecibido, usuario.tokenRefresh);
    if (!coincide) {
      throw new ForbiddenException('No autorizado para refrescar tokens');
    }

    const sesion = await this.emitirSesionCompleta(usuario);
    await this.auditoriaService.registrar({
      idInstitucion: usuario.idInstitucion ?? null,
      idActor: usuario.id,
      rolActor: usuario.rol,
      accion: 'TOKEN_REFRESCADO',
      recurso: 'autenticacion',
      idRecurso: usuario.id,
      snapshotAntes: null,
      snapshotDespues: { refrescado: true },
      ip: contextoCliente.ip ?? null,
      userAgent: contextoCliente.userAgent ?? null,
    });
    return sesion;
  }

  /**
   * Invalida sesión del usuario removiendo refresh y revocando access token actual.
   */
  async cerrarSesion(idUsuario: string, tokenAcceso: string | null, contextoCliente: ContextoCliente = {}): Promise<void> {
    await this.prisma.usuario.update({
      where: { id: idUsuario },
      data: { tokenRefresh: null },
    });

    if (tokenAcceso) {
      try {
        const payload = await this.jwtService.verifyAsync<{ jti?: string; exp?: number }>(tokenAcceso, {
          secret: this.servicioConfiguracion.get<string>('JWT_SECRETO_ACCESO', ''),
          issuer: this.servicioConfiguracion.get<string>('JWT_EMISOR', EMISOR_JWT_DEFECTO),
          audience: this.servicioConfiguracion.get<string>('JWT_AUDIENCIA', AUDIENCIA_JWT_DEFECTO),
        });
        if (payload.jti && payload.exp) {
          this.blacklistTokensService.revocar(payload.jti, payload.exp);
        }
      } catch {
        // Ignora token inválido en logout: refresh ya quedó invalidado.
      }
    }

    const usuario = await this.prisma.usuario.findUnique({
      where: { id: idUsuario },
      select: { id: true, rol: true, idInstitucion: true },
    });

    await this.auditoriaService.registrar({
      idInstitucion: usuario?.idInstitucion ?? null,
      idActor: usuario?.id ?? idUsuario,
      rolActor: usuario?.rol ?? null,
      accion: 'LOGOUT',
      recurso: 'autenticacion',
      idRecurso: idUsuario,
      snapshotAntes: null,
      snapshotDespues: { logout: true },
      ip: contextoCliente.ip ?? null,
      userAgent: contextoCliente.userAgent ?? null,
    });
  }

  /**
   * Cambia contraseña de primer login validando token temporal y política de complejidad.
   */
  async cambiarContrasenaPrimerLogin(
    idUsuario: string,
    nuevaContrasena: string,
    contextoCliente: ContextoCliente = {},
  ): Promise<RespuestaSesion> {
    const usuario = await this.prisma.usuario.findUnique({
      where: { id: idUsuario },
      include: { institucion: { select: { estado: true } } },
    });
    if (!usuario) {
      throw new UnauthorizedException('Usuario no encontrado');
    }
    if (!usuario.primerLogin || !usuario.credencialTemporal) {
      throw new ForbiddenException('La cuenta no requiere cambio inicial de contraseña');
    }

    if (!PATRON_CONTRASENA_SEGURA.test(nuevaContrasena)) {
      throw new ForbiddenException(
        'La contraseña debe tener mínimo 8 caracteres, mayúscula, minúscula, número y carácter especial',
      );
    }

    const coincideConTemporal = await bcrypt.compare(nuevaContrasena, usuario.credencialTemporal);
    if (coincideConTemporal) {
      throw new ForbiddenException('La nueva contraseña no puede ser igual a la credencial temporal');
    }

    const rondasHash = this.obtenerRondasHash();
    const hashContrasena = await bcrypt.hash(nuevaContrasena, rondasHash);

    const actualizado = await this.prisma.usuario.update({
      where: { id: idUsuario },
      data: {
        contrasena: hashContrasena,
        primerLogin: false,
        credencialTemporal: null,
        credencialTemporalVence: null,
        estadoCuenta: EstadoCuenta.ACTIVO,
        intentosFallidosLogin: 0,
        bloqueadoHasta: null,
      },
      include: { institucion: { select: { estado: true } } },
    });

    this.validarInstitucionActiva(actualizado);
    const sesion = await this.emitirSesionCompleta(actualizado);
    await this.auditoriaService.registrar({
      idInstitucion: actualizado.idInstitucion ?? null,
      idActor: actualizado.id,
      rolActor: actualizado.rol,
      accion: 'CONTRASENA_CAMBIADA_PRIMER_LOGIN',
      recurso: 'usuarios',
      idRecurso: actualizado.id,
      snapshotAntes: { primerLogin: true },
      snapshotDespues: { primerLogin: false },
      ip: contextoCliente.ip ?? null,
      userAgent: contextoCliente.userAgent ?? null,
    });

    return sesion;
  }

  /**
   * Registra un usuario con credencial temporal para activación inicial.
   */
  async registrar(dto: RegistrarUsuarioDto): Promise<UsuarioSinDatosSensibles & { credencialTemporalPlano: string }> {
    const rondasHash = this.obtenerRondasHash();
    const credencialTemporalPlano = this.generarCredencialTemporal();
    const hashTemporal = await bcrypt.hash(credencialTemporalPlano, rondasHash);

    const usuarioCreado = await this.prisma.usuario.create({
      data: {
        nombre: dto.nombre,
        apellidos: dto.apellidos,
        correo: this.normalizarCorreo(dto.correo),
        contrasena: hashTemporal,
        rol: dto.rol ?? RolUsuario.ESTUDIANTE,
        idInstitucion: dto.idInstitucion ?? null,
        primerLogin: true,
        credencialTemporal: hashTemporal,
        credencialTemporalVence: this.calcularVencimientoCredencialTemporal(),
        estadoCuenta: EstadoCuenta.PENDIENTE_ACTIVACION,
      },
    });

    const usuarioSinDatosSensibles = this.mapearUsuarioSinDatosSensibles(usuarioCreado);
    return { ...usuarioSinDatosSensibles, credencialTemporalPlano };
  }

  private async procesarPrimerLogin(
    usuario: UsuarioConInstitucion,
    contrasena: string,
    contextoCliente: ContextoCliente,
  ): Promise<RespuestaPrimerLogin> {
    if (!usuario.credencialTemporal || !usuario.credencialTemporalVence) {
      throw new ForbiddenException('Cuenta pendiente de activación sin credencial temporal válida');
    }

    if (usuario.credencialTemporalVence.getTime() < Date.now()) {
      throw new UnauthorizedException('La credencial temporal expiró. Solicite una nueva');
    }

    const coincideTemporal = await bcrypt.compare(contrasena, usuario.credencialTemporal);
    if (!coincideTemporal) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    const payloadBase = this.construirPayload(usuario);
    const tokenTemporal = await this.jwtService.signAsync(
      { ...payloadBase, scope: 'CAMBIO_CONTRASENA_PRIMER_LOGIN' },
      {
        secret: this.servicioConfiguracion.get<string>('JWT_SECRETO_ACCESO', ''),
        expiresIn: EXPIRACION_TOKEN_TEMPORAL,
        jwtid: randomUUID(),
        issuer: this.servicioConfiguracion.get<string>('JWT_EMISOR', EMISOR_JWT_DEFECTO),
        audience: this.servicioConfiguracion.get<string>('JWT_AUDIENCIA', AUDIENCIA_JWT_DEFECTO),
      },
    );

    await this.auditoriaService.registrar({
      idInstitucion: usuario.idInstitucion ?? null,
      idActor: usuario.id,
      rolActor: usuario.rol,
      accion: 'LOGIN_TEMPORAL_PRIMER_LOGIN',
      recurso: 'autenticacion',
      idRecurso: usuario.id,
      snapshotAntes: { primerLogin: true },
      snapshotDespues: { tokenTemporalEmitido: true },
      ip: contextoCliente.ip ?? null,
      userAgent: contextoCliente.userAgent ?? null,
    });

    return {
      requiereCambioContrasena: true,
      tokenTemporal,
    };
  }

  private async emitirSesionCompleta(usuario: UsuarioConInstitucion): Promise<RespuestaSesion> {
    const configuracionFirmado = {
      issuer: this.servicioConfiguracion.get<string>('JWT_EMISOR', EMISOR_JWT_DEFECTO),
      audience: this.servicioConfiguracion.get<string>('JWT_AUDIENCIA', AUDIENCIA_JWT_DEFECTO),
    };
    const payload = this.construirPayload(usuario);

    const tokenAcceso = await this.jwtService.signAsync(payload, {
      secret: this.servicioConfiguracion.get<string>('JWT_SECRETO_ACCESO', ''),
      expiresIn: this.servicioConfiguracion.get<string>('JWT_EXPIRACION_ACCESO', '8h'),
      jwtid: randomUUID(),
      ...configuracionFirmado,
    });

    const tokenRefresh = await this.jwtService.signAsync(payload, {
      secret: this.servicioConfiguracion.get<string>('JWT_SECRETO_REFRESH', ''),
      expiresIn: this.servicioConfiguracion.get<string>('JWT_EXPIRACION_REFRESH', '7d'),
      jwtid: randomUUID(),
      ...configuracionFirmado,
    });

    const hashRefresh = await bcrypt.hash(tokenRefresh, this.obtenerRondasHash());
    await this.prisma.usuario.update({
      where: { id: usuario.id },
      data: { tokenRefresh: hashRefresh, ultimoLogin: new Date() },
    });

    return { tokenAcceso, tokenRefresh, usuario: this.mapearUsuarioSinDatosSensibles(usuario) };
  }

  private construirPayload(usuario: Pick<Usuario, 'id' | 'correo' | 'rol' | 'idInstitucion'>) {
    return {
      sub: usuario.id,
      correo: usuario.correo,
      rol: usuario.rol,
      idInstitucion: usuario.idInstitucion ?? null,
    };
  }

  private async validarEstadoCuentaAntesDeContrasena(usuario: UsuarioConInstitucion): Promise<void> {
    if (!usuario.activo) {
      throw new ForbiddenException('Cuenta inactiva');
    }

    if (usuario.estadoCuenta === EstadoCuenta.SUSPENDIDO) {
      throw new ForbiddenException('Cuenta suspendida');
    }

    if (usuario.estadoCuenta === EstadoCuenta.BLOQUEADO) {
      if (usuario.bloqueadoHasta && usuario.bloqueadoHasta.getTime() > Date.now()) {
        throw new ForbiddenException('Cuenta bloqueada temporalmente');
      }

      await this.prisma.usuario.update({
        where: { id: usuario.id },
        data: { estadoCuenta: EstadoCuenta.ACTIVO, bloqueadoHasta: null, intentosFallidosLogin: 0 },
      });
    }
  }

  private validarInstitucionActiva(usuario: UsuarioConInstitucion): void {
    if (usuario.rol === RolUsuario.SUPERADMINISTRADOR) {
      return;
    }
    if (!usuario.idInstitucion || !usuario.institucion || usuario.institucion.estado !== EstadoInstitucion.ACTIVA) {
      throw new ForbiddenException('La institución asociada no se encuentra activa');
    }
  }

  private async procesarIntentoLoginFallido(usuario: Usuario, contextoCliente: ContextoCliente): Promise<void> {
    const intentosFallidos = usuario.intentosFallidosLogin + 1;
    const excedioLimite = intentosFallidos >= INTENTOS_MAXIMOS_LOGIN;

    await this.prisma.usuario.update({
      where: { id: usuario.id },
      data: {
        intentosFallidosLogin: intentosFallidos,
        estadoCuenta: excedioLimite ? EstadoCuenta.BLOQUEADO : usuario.estadoCuenta,
        bloqueadoHasta: excedioLimite ? this.calcularFechaBloqueo() : usuario.bloqueadoHasta,
      },
    });

    await this.registrarAuditoriaLogin(usuario.id, usuario.rol, 'LOGIN_FALLIDO', contextoCliente, {
      intentosFallidos,
      bloqueado: excedioLimite,
    });
  }

  private async registrarAuditoriaLogin(
    idActor: string | null,
    rolActor: RolUsuario | null,
    accion: string,
    contextoCliente: ContextoCliente,
    snapshot: unknown,
  ): Promise<void> {
    await this.auditoriaService.registrar({
      idActor,
      rolActor,
      accion,
      recurso: 'autenticacion',
      idRecurso: idActor,
      snapshotAntes: null,
      snapshotDespues: snapshot,
      ip: contextoCliente.ip ?? null,
      userAgent: contextoCliente.userAgent ?? null,
    });
  }

  private mapearUsuarioSinDatosSensibles(usuario: Usuario): UsuarioSinDatosSensibles {
    const {
      contrasena: _contrasena,
      tokenRefresh: _tokenRefresh,
      credencialTemporal: _credencialTemporal,
      ...usuarioSinDatosSensibles
    } = usuario;
    return usuarioSinDatosSensibles;
  }

  private normalizarCorreo(correo: string): string {
    return correo.trim().toLowerCase();
  }

  private calcularFechaBloqueo(): Date {
    return new Date(Date.now() + MINUTOS_BLOQUEO_LOGIN * 60_000);
  }

  private calcularVencimientoCredencialTemporal(): Date {
    return new Date(Date.now() + HORAS_VIGENCIA_CREDENCIAL_TEMPORAL * 60 * 60_000);
  }

  private generarCredencialTemporal(): string {
    return randomBytes(9).toString('base64url').slice(0, 12).toUpperCase();
  }

  private obtenerRondasHash(): number {
    const valorConfigurado = Number(this.servicioConfiguracion.get<string>('BCRYPT_RONDAS_HASH', '12'));
    return Number.isFinite(valorConfigurado) && valorConfigurado >= 12 ? valorConfigurado : 12;
  }
}
