/// @archivo   Entorno_test.dart
/// @descripcion Valida carga de configuracion de entorno para ejecucion movil.
/// @modulo    test/Configuracion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movil/Configuracion/Entorno.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('carga Entornos/dev.json cuando no hay dart-define', () async {
    await Entorno.inicializar();
    Entorno.validar();

    final contenido = await rootBundle.loadString('Entornos/dev.json');
    final json = jsonDecode(contenido) as Map<String, dynamic>;

    expect(Entorno.apiUrl, json['API_URL']);
    expect(Entorno.websocketUrl, json['WEBSOCKET_URL']);
    expect(Entorno.versionApp, json['VERSION_APP']);
  });
}
