/// @archivo   AutenticacionServicio.dart
/// @descripcion Gestiona inicio/cierre de sesion y persistencia segura de tokens.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Constantes/ApiEndpoints.dart';
import '../Constantes/ClavesAlmacen.dart';
import '../Constantes/Textos.dart';
import '../Modelos/SesionAutenticada.dart';
import '../Modelos/Usuario.dart';
import 'ApiServicio.dart';

class RequiereCambioContrasenaException implements Exception {
  final String tokenTemporal;

  const RequiereCambioContrasenaException(this.tokenTemporal);
}

class AutenticacionServicio {
  final ApiServicio _apiServicio;
  final FlutterSecureStorage _almacenSeguro;

  AutenticacionServicio({
    required ApiServicio apiServicio,
    required FlutterSecureStorage almacenSeguro,
  })  : _apiServicio = apiServicio,
        _almacenSeguro = almacenSeguro;

  /// Inicia sesion y persiste tokens/usuario en almacenamiento seguro.
  Future<SesionAutenticada> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    final respuesta = await _apiServicio.publicar<Map<String, dynamic>>(
      ApiEndpoints.autenticacionIniciarSesion,
      (valor) => valor as Map<String, dynamic>,
      cuerpo: <String, dynamic>{
        'correo': correo,
        'contrasena': contrasena,
      },
    );
    final requiereCambioContrasena =
        (respuesta['requiereCambioContrasena'] as bool?) ?? false;
    if (requiereCambioContrasena) {
      final tokenTemporal = respuesta['tokenTemporal'] as String?;
      if (tokenTemporal == null || tokenTemporal.trim().isEmpty) {
        throw StateError(Textos.errorInicioSesion);
      }
      throw RequiereCambioContrasenaException(tokenTemporal);
    }

    final sesion = SesionAutenticada.fromJson(respuesta);
    _validarAccesoMovil(sesion.usuario);

    await _almacenSeguro.write(
        key: ClavesAlmacen.tokenAcceso, value: sesion.tokenAcceso);
    await _almacenSeguro.write(
        key: ClavesAlmacen.tokenRefresh, value: sesion.tokenRefresh);
    await _almacenSeguro.write(
      key: ClavesAlmacen.usuarioActual,
      value: jsonEncode(sesion.usuario.toJson()),
    );

    return sesion;
  }

  /// Completa primer login usando token temporal y registra sesión final.
  Future<SesionAutenticada> completarPrimerLogin({
    required String tokenTemporal,
    required String nuevaContrasena,
  }) async {
    final sesion = await _apiServicio.publicar<SesionAutenticada>(
      ApiEndpoints.autenticacionCambiarContrasena,
      (valor) => SesionAutenticada.fromJson(valor as Map<String, dynamic>),
      cuerpo: <String, dynamic>{
        'nuevaContrasena': nuevaContrasena,
      },
      encabezados: <String, dynamic>{
        'Authorization': 'Bearer ${tokenTemporal.trim()}',
      },
    );
    _validarAccesoMovil(sesion.usuario);

    await _almacenSeguro.write(
        key: ClavesAlmacen.tokenAcceso, value: sesion.tokenAcceso);
    await _almacenSeguro.write(
        key: ClavesAlmacen.tokenRefresh, value: sesion.tokenRefresh);
    await _almacenSeguro.write(
      key: ClavesAlmacen.usuarioActual,
      value: jsonEncode(sesion.usuario.toJson()),
    );

    return sesion;
  }

  /// Cierra sesion en backend y limpia credenciales locales.
  Future<void> cerrarSesion() async {
    try {
      await _apiServicio.publicar<void>(
        ApiEndpoints.autenticacionCerrarSesion,
        (_) => null,
      );
    } catch (_) {
      // Si falla el backend, de todas formas se limpia sesion local.
    }

    await _almacenSeguro.deleteAll();
  }

  /// Retorna true cuando existe token de acceso y usuario persistido.
  Future<bool> tieneSesionActiva() async {
    try {
      final tokenAcceso =
          await _almacenSeguro.read(key: ClavesAlmacen.tokenAcceso);
      if (tokenAcceso == null || tokenAcceso.isEmpty) {
        return false;
      }

      final usuario = await obtenerUsuarioActual();
      if (usuario == null) {
        return false;
      }
      _validarAccesoMovil(usuario);
      return true;
    } catch (_) {
      await _almacenSeguro.deleteAll();
      return false;
    }
  }

  /// Obtiene usuario persistido o null si no existe.
  Future<Usuario?> obtenerUsuarioActual() async {
    final usuario = await _almacenSeguro.read(key: ClavesAlmacen.usuarioActual);
    if (usuario == null || usuario.isEmpty) {
      return null;
    }

    try {
      return Usuario.fromJson(jsonDecode(usuario) as Map<String, dynamic>);
    } catch (_) {
      await _almacenSeguro.delete(key: ClavesAlmacen.usuarioActual);
      return null;
    }
  }

  void _validarAccesoMovil(Usuario usuario) {
    if (!usuario.activo || usuario.estadoCuenta != 'ACTIVO') {
      throw StateError(Textos.errorUsuarioInactivo);
    }
  }
}
