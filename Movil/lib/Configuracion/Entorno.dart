/// @archivo   Entorno.dart
/// @descripcion Lee variables de compilacion para URL de API, socket y version de app.
/// @modulo    Configuracion
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:convert';

import 'package:flutter/services.dart';

import '../Constantes/Textos.dart';

/// Configuracion de entorno obtenida por --dart-define.
abstract class Entorno {
  static const _apiUrlPorDefecto = 'http://10.0.2.2:3001/api/v1';
  static const _websocketUrlPorDefecto = 'http://10.0.2.2:3001';
  static const _versionAppPorDefecto = '1.0.0';
  static const _rutaEntornoDev = 'Entornos/dev.json';

  static const _apiUrlDartDefine = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );
  static const _websocketUrlDartDefine = String.fromEnvironment(
    'WEBSOCKET_URL',
    defaultValue: '',
  );
  static const _versionAppDartDefine = String.fromEnvironment(
    'VERSION_APP',
    defaultValue: '',
  );
  static const _diasRetencionDartDefine = int.fromEnvironment(
    'DIAS_RETENCION_TELEMETRIA',
    defaultValue: 7,
  );

  static String _apiUrl = _apiUrlPorDefecto;
  static String _websocketUrl = _websocketUrlPorDefecto;
  static int _diasRetencionTelemetria = _diasRetencionDartDefine;
  static String _versionApp = _versionAppPorDefecto;
  static bool _inicializado = false;

  static String get apiUrl => _apiUrl;
  static String get websocketUrl => _websocketUrl;
  static int get diasRetencionTelemetria => _diasRetencionTelemetria;
  static String get versionApp => _versionApp;

  /// Carga variables desde --dart-define y, como fallback, desde Entornos/dev.json.
  static Future<void> inicializar() async {
    if (_inicializado) {
      return;
    }

    final jsonEntorno = await _cargarEntornoEmpaquetado();

    final apiUrlJson = _leerCadena(jsonEntorno, 'API_URL');
    final websocketUrlJson = _leerCadena(jsonEntorno, 'WEBSOCKET_URL');
    final versionAppJson = _leerCadena(jsonEntorno, 'VERSION_APP');
    final diasRetencionJson =
        _leerEntero(jsonEntorno, 'DIAS_RETENCION_TELEMETRIA');

    _apiUrl = _apiUrlDartDefine.trim().isNotEmpty
        ? _apiUrlDartDefine.trim()
        : (apiUrlJson.isNotEmpty ? apiUrlJson : _apiUrlPorDefecto);
    _websocketUrl = _websocketUrlDartDefine.trim().isNotEmpty
        ? _websocketUrlDartDefine.trim()
        : (websocketUrlJson.isNotEmpty
            ? websocketUrlJson
            : _websocketUrlPorDefecto);
    _versionApp = _versionAppDartDefine.trim().isNotEmpty
        ? _versionAppDartDefine.trim()
        : (versionAppJson.isNotEmpty ? versionAppJson : _versionAppPorDefecto);
    _diasRetencionTelemetria = _diasRetencionDartDefine >= 1
        ? _diasRetencionDartDefine
        : (diasRetencionJson ?? 7);

    _inicializado = true;
  }

  /// Verifica que las variables obligatorias esten cargadas.
  static void validar() {
    if (!_inicializado) {
      throw StateError(
        '${Textos.errorGeneral} Inicializa la configuracion de entorno antes de ejecutar la app.',
      );
    }

    if (apiUrl.isEmpty || websocketUrl.isEmpty) {
      throw StateError(
        '${Textos.errorGeneral} Configura API_URL y WEBSOCKET_URL por dart-define.',
      );
    }

    final uriApi = Uri.tryParse(apiUrl);
    final uriSocket = Uri.tryParse(websocketUrl);
    final apiValida = uriApi != null &&
        uriApi.hasScheme &&
        uriApi.host.isNotEmpty &&
        uriApi.path.contains('/api/v1');
    final socketValido =
        uriSocket != null && uriSocket.hasScheme && uriSocket.host.isNotEmpty;

    if (!apiValida || !socketValido) {
      throw StateError(
        '${Textos.errorGeneral} API_URL o WEBSOCKET_URL no tienen formato valido.',
      );
    }

    if (diasRetencionTelemetria < 1) {
      throw StateError(
        '${Textos.errorGeneral} DIAS_RETENCION_TELEMETRIA debe ser mayor o igual a 1.',
      );
    }
  }

  static Future<Map<String, dynamic>> _cargarEntornoEmpaquetado() async {
    try {
      final contenido = await rootBundle.loadString(_rutaEntornoDev);
      final json = jsonDecode(contenido);
      if (json is Map<String, dynamic>) {
        return json;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static String _leerCadena(Map<String, dynamic> fuente, String clave) {
    final valor = fuente[clave];
    if (valor is String) {
      return valor.trim();
    }
    return '';
  }

  static int? _leerEntero(Map<String, dynamic> fuente, String clave) {
    final valor = fuente[clave];
    if (valor is int) {
      return valor;
    }
    if (valor is String) {
      return int.tryParse(valor.trim());
    }
    return null;
  }
}
