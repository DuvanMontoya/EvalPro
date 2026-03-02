/// @archivo   Entorno.dart
/// @descripcion Lee variables de compilacion para URL de API, socket y version de app.
/// @modulo    Configuracion
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../Constantes/Textos.dart';

/// Configuracion de entorno obtenida por --dart-define.
abstract class Entorno {
  static const _apiUrlPorDefecto = 'http://10.0.2.2:3001/api/v1';
  static const _websocketUrlPorDefecto = 'http://10.0.2.2:3001';

  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: _apiUrlPorDefecto,
  );
  static const websocketUrl = String.fromEnvironment(
    'WEBSOCKET_URL',
    defaultValue: _websocketUrlPorDefecto,
  );
  static const diasRetencionTelemetria = int.fromEnvironment(
    'DIAS_RETENCION_TELEMETRIA',
    defaultValue: 7,
  );
  static const versionApp =
      String.fromEnvironment('VERSION_APP', defaultValue: '1.0.0');

  /// Verifica que las variables obligatorias esten cargadas.
  static void validar() {
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
}
