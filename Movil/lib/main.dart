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
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Entorno.validar();
  runApp(const ProviderScope(child: Aplicacion()));
}
