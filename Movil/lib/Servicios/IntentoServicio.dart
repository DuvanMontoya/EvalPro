/// @archivo   IntentoServicio.dart
/// @descripcion Inicia intentos de examen para estudiantes autenticados.
/// @modulo    Servicios
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../Configuracion/Entorno.dart';
import '../Constantes/ApiEndpoints.dart';
import '../Modelos/IntentoExamen.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'ApiServicio.dart';

class IntentoServicio {
  final ApiServicio _apiServicio;

  IntentoServicio(this._apiServicio);

  /// Crea un intento en backend para la sesion indicada.
  Future<IntentoExamen> iniciar(
    String idSesion,
    String codigoAcceso, {
    Map<String, dynamic>? integridadDispositivo,
  }) async {
    try {
      final sistemaOperativo = _obtenerSistemaOperativo();
      return await _apiServicio.publicar<IntentoExamen>(
        ApiEndpoints.intentos,
        (valor) => IntentoExamen.fromJson(valor as Map<String, dynamic>),
        cuerpo: <String, dynamic>{
          'idSesion': idSesion,
          'codigoAcceso': codigoAcceso,
          'versionApp': Entorno.versionApp,
          'sistemaOperativo': sistemaOperativo,
          if (integridadDispositivo != null)
            'integridadDispositivo': integridadDispositivo,
        },
      );
    } on DioException catch (error) {
      final datosRespuesta = error.response?.data;
      if (datosRespuesta is Map<String, dynamic> &&
          (datosRespuesta['codigoError'] as String?) == 'INTENTO_DUPLICADO') {
        final datos = datosRespuesta['datos'];
        if (datos is Map<String, dynamic>) {
          final intentoExistente = datos['intentoExistente'];
          if (intentoExistente is Map<String, dynamic>) {
            return IntentoExamen.fromJson(intentoExistente);
          }
        }
      }
      rethrow;
    }
  }

  String _obtenerSistemaOperativo() {
    if (Platform.isAndroid) {
      return 'ANDROID';
    }
    if (Platform.isIOS) {
      return 'IOS';
    }
    if (Platform.isMacOS) {
      return 'MACOS';
    }
    if (Platform.isWindows) {
      return 'WINDOWS';
    }
    if (Platform.isLinux) {
      return 'LINUX';
    }
    return 'DESCONOCIDO';
  }
}
