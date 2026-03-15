/// @archivo   widget_test.dart
/// @descripcion Prueba minima de construccion de la aplicacion con ProviderScope.
/// @modulo    test
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:movil/Aplicacion.dart';
import 'package:movil/Constantes/Textos.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets(
      'La aplicacion se construye y muestra la pantalla de inicio de sesion',
      (WidgetTester tester) async {
    // Construye la aplicacion principal dentro de ProviderScope.
    await tester.pumpWidget(const ProviderScope(child: Aplicacion()));
    await tester.pumpAndSettle();
    expect(find.text(Textos.iniciarSesion), findsWidgets);
  });
}
