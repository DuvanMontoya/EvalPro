/// @archivo   Entorno.dart
/// @descripcion Lee variables de compilacion para URL de API, socket y version de app.
/// @modulo    Configuracion
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../Constantes/Textos.dart';

/// Configuracion de entorno obtenida por --dart-define.
abstract class Entorno {
  static const apiUrl = String.fromEnvironment('API_URL');
  static const websocketUrl = String.fromEnvironment('WEBSOCKET_URL');
  static const versionApp =
      String.fromEnvironment('VERSION_APP', defaultValue: '1.0.0');

  /// Verifica que las variables obligatorias esten cargadas.
  static void validar() {
    if (apiUrl.isEmpty || websocketUrl.isEmpty) {
      throw StateError(
          '${Textos.errorGeneral} Configura API_URL y WEBSOCKET_URL por dart-define.');
    }
  }
}
