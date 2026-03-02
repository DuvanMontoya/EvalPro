/// @archivo   ApiAuxiliar.dart
/// @descripcion Contiene utilidades compartidas para parseo API y renovacion de tokens.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Constantes/ApiEndpoints.dart';
import '../Constantes/ClavesAlmacen.dart';

/// Renueva tokens de acceso utilizando el refresh token persistido.
Future<String?> refrescarTokenAcceso({
  required Dio clienteRefresco,
  required FlutterSecureStorage almacenSeguro,
}) async {
  final tokenRefresh =
      await almacenSeguro.read(key: ClavesAlmacen.tokenRefresh);
  final usuarioJson =
      await almacenSeguro.read(key: ClavesAlmacen.usuarioActual);
  if (tokenRefresh == null || usuarioJson == null) return null;

  final usuario = jsonDecode(usuarioJson) as Map<String, dynamic>;
  final idUsuario = usuario['id'] as String?;
  if (idUsuario == null || idUsuario.isEmpty) return null;

  try {
    final respuesta = await clienteRefresco.post<dynamic>(
      ApiEndpoints.autenticacionRefrescar,
      data: <String, dynamic>{
        'idUsuario': idUsuario,
        'tokenRefresh': tokenRefresh,
      },
    );

    final cuerpo = respuesta.data as Map<String, dynamic>;
    final datos = cuerpo['datos'] as Map<String, dynamic>?;
    if ((cuerpo['exito'] as bool? ?? false) == false || datos == null)
      return null;

    final nuevoAcceso = datos['tokenAcceso'] as String?;
    final nuevoRefresh = datos['tokenRefresh'] as String?;
    final usuarioNuevo = datos['usuario'] as Map<String, dynamic>?;
    if (nuevoAcceso == null || nuevoRefresh == null || usuarioNuevo == null)
      return null;

    await almacenSeguro.write(
        key: ClavesAlmacen.tokenAcceso, value: nuevoAcceso);
    await almacenSeguro.write(
        key: ClavesAlmacen.tokenRefresh, value: nuevoRefresh);
    await almacenSeguro.write(
        key: ClavesAlmacen.usuarioActual, value: jsonEncode(usuarioNuevo));
    return nuevoAcceso;
  } catch (_) {
    return null;
  }
}

/// Elimina tokens locales y avisa a la capa superior por callback opcional.
Future<void> cerrarSesionLocal({
  required FlutterSecureStorage almacenSeguro,
  required VoidCallback? alExpirarSesion,
}) async {
  await almacenSeguro.deleteAll();
  alExpirarSesion?.call();
}

/// Extrae el campo `datos` del contrato estandar del backend.
T mapearDatosApi<T>(
    Response<dynamic> respuesta, T Function(Object? valor) mapear) {
  final cuerpo = respuesta.data;
  if (cuerpo is Map<String, dynamic> && cuerpo.containsKey('datos')) {
    if ((cuerpo['exito'] as bool? ?? false) == false) {
      throw DioException(
        requestOptions: respuesta.requestOptions,
        response: respuesta,
        error: cuerpo['mensaje'] ?? 'Error en la API',
        type: DioExceptionType.badResponse,
      );
    }
    return mapear(cuerpo['datos']);
  }
  return mapear(cuerpo);
}
