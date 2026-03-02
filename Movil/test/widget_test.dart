// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movil/Aplicacion.dart';
import 'package:movil/Constantes/Textos.dart';

void main() {
  testWidgets(
      'La aplicacion se construye y muestra la pantalla de inicio de sesion',
      (WidgetTester tester) async {
    // Construye la aplicacion principal dentro de un ProviderScope, igual que en main().
    await tester.pumpWidget(const ProviderScope(child: Aplicacion()));

    // Permite que el router y los widgets iniciales se construyan.
    await tester.pumpAndSettle();

    // Verifica que se muestre el texto principal de inicio de sesion al menos una vez.
    expect(find.text(Textos.iniciarSesion), findsWidgets);
  });
}
