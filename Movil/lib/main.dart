/// @archivo   main.dart
/// @descripcion Punto de entrada de la app movil de EvalPro.
/// @modulo    lib
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Aplicacion.dart';
import 'Configuracion/Entorno.dart';

/// Inicia la aplicacion Flutter con el contenedor global de Riverpod.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Entorno.inicializar();
  Entorno.validar();
  debugPrint(
    '[EvalPro][Entorno] API_URL=${Entorno.apiUrl} WEBSOCKET_URL=${Entorno.websocketUrl} VERSION=${Entorno.versionApp}',
  );
  runApp(const ProviderScope(child: Aplicacion()));
}
