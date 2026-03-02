/// @archivo   MapeadorErroresNegocio.dart
/// @descripcion Convierte errores tecnicos/API a mensajes funcionales consistentes para UI.
/// @modulo    Utilidades
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:dio/dio.dart';

import '../Constantes/Textos.dart';

class MapeadorErroresNegocio {
  static const _codigoCredencialesInvalidas = 'CREDENCIALES_INVALIDAS';
  static const _codigoTokenExpirado = 'TOKEN_EXPIRADO';
  static const _codigoTokenInvalido = 'TOKEN_INVALIDO';
  static const _codigoSinPermisos = 'SIN_PERMISOS';
  static const _codigoValidacionFallida = 'VALIDACION_FALLIDA';
  static const _codigoSesionNoActiva = 'SESION_NO_ACTIVA';
  static const _codigoIntentoDuplicado = 'INTENTO_DUPLICADO';

  /// Retorna un mensaje funcional en espanol para mostrar al usuario final.
  static String mapear(
    Object error, {
    String mensajePorDefecto = Textos.errorGeneral,
  }) {
    if (error is DioException) {
      final datos = error.response?.data;
      if (datos is Map<String, dynamic>) {
        final codigo = datos['codigoError'] as String?;
        if (codigo != null) {
          return _mapearCodigo(codigo, mensajePorDefecto);
        }

        final mensajeApi = datos['mensaje'] as String?;
        if (mensajeApi != null && mensajeApi.trim().isNotEmpty) {
          return mensajeApi;
        }
      }
    }

    if (error is StateError) {
      final mensaje = error.message.trim();
      if (mensaje.isNotEmpty) {
        return mensaje;
      }
    }

    return mensajePorDefecto;
  }

  static String _mapearCodigo(String codigo, String mensajePorDefecto) {
    switch (codigo) {
      case _codigoCredencialesInvalidas:
        return Textos.errorInicioSesion;
      case _codigoTokenExpirado:
      case _codigoTokenInvalido:
        return Textos.errorTokenInvalido;
      case _codigoSinPermisos:
        return Textos.errorSinPermisos;
      case _codigoValidacionFallida:
        return Textos.errorValidacion;
      case _codigoSesionNoActiva:
        return Textos.errorSesionNoActiva;
      case _codigoIntentoDuplicado:
        return Textos.errorIntentoDuplicado;
      default:
        return mensajePorDefecto;
    }
  }
}
