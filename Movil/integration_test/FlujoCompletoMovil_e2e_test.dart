/// @archivo   FlujoCompletoMovil_e2e_test.dart
/// @descripcion Ejecuta flujo e2e real docente-estudiante contra backend real.
/// @modulo    integration_test
/// @autor     EvalPro
/// @fecha     2026-03-05

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movil/Configuracion/Entorno.dart';
import 'package:movil/main.dart' as app;

import 'Soporte/BackendE2eHelper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'docente activa sesion, estudiante presenta examen y docente valida reporte',
      (tester) async {
    BackendE2eHelper? backend;
    addTearDown(() => backend?.cerrar());

    final escenario = (await tester.runAsync(() async {
      await Entorno.inicializar();
      backend = BackendE2eHelper(baseUrl: Entorno.apiUrl);
      await backend!.esperarDisponible();
      await const FlutterSecureStorage().deleteAll();
      return backend!.prepararEscenario();
    }))!;

    await app.main();
    await _esperarVisible(
      tester,
      find.byKey(const Key('login_email_field')),
    );

    await _iniciarSesion(
      tester,
      correo: escenario.docente.correo,
      contrasena: escenario.docente.contrasena,
    );

    await _tapVisible(
      tester,
      find.byKey(const Key('inicio_manage_sessions_button')),
    );
    await _esperarVisible(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_activate_button_${escenario.idSesion}'),
      ),
    );
    await _tapVisible(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_activate_button_${escenario.idSesion}'),
      ),
    );
    await _esperarVisible(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_report_button_${escenario.idSesion}'),
      ),
    );

    final codigoSesion = (await tester.runAsync(
      () => backend!.esperarCodigoSesionActivo(escenario),
    ))!;
    expect(codigoSesion, isNotEmpty);

    await _cerrarSesion(tester);

    await _iniciarSesion(
      tester,
      correo: escenario.estudiante.correo,
      contrasena: escenario.estudiante.contrasena,
    );

    await _tapVisible(
      tester,
      find.byKey(const Key('inicio_join_session_button')),
    );
    await _esperarVisible(
      tester,
      find.byKey(const Key('session_search_code_field')),
    );
    await tester.enterText(
      find.byKey(const Key('session_search_code_field')),
      codigoSesion,
    );
    await _tapVisible(
      tester,
      find.byKey(const Key('session_search_button')),
    );
    await _esperarVisible(
      tester,
      find.byKey(ValueKey<String>('session_join_button_${escenario.idSesion}')),
      timeout: const Duration(seconds: 25),
    );
    await _tapVisible(
      tester,
      find.byKey(ValueKey<String>('session_join_button_${escenario.idSesion}')),
    );

    for (var indice = 0; indice < escenario.totalPreguntas; indice++) {
      final idPreguntaActual = await _obtenerIdPreguntaActual(tester);
      await _tapVisible(
        tester,
        find.byKey(ValueKey<String>('exam_option_${idPreguntaActual}_A')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await _tapVisible(
        tester,
        find.byKey(const Key('exam_next_button')),
      );
    }

    await _esperarVisible(
      tester,
      find.byKey(const Key('exam_submit_button')),
    );
    await _tapVisible(
      tester,
      find.byKey(const Key('exam_submit_button')),
    );
    await _esperarVisible(
      tester,
      find.byKey(const Key('exam_back_home_button')),
      timeout: const Duration(seconds: 35),
    );
    expect(find.text('Tu examen fue enviado correctamente'), findsOneWidget);

    await _tapVisible(
      tester,
      find.byKey(const Key('exam_back_home_button')),
    );
    await _esperarVisible(
      tester,
      find.byKey(const Key('inicio_logout_button')),
    );

    await tester.runAsync(() => backend!.esperarReporteConEntrega(escenario));

    await _cerrarSesion(tester);

    await _iniciarSesion(
      tester,
      correo: escenario.docente.correo,
      contrasena: escenario.docente.contrasena,
    );
    await _tapVisible(
      tester,
      find.byKey(const Key('inicio_manage_sessions_button')),
    );
    await _esperarVisible(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_report_button_${escenario.idSesion}'),
      ),
    );
    await _tapVisible(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_report_button_${escenario.idSesion}'),
      ),
    );

    await _esperarVisible(
      tester,
      find.byKey(const Key('session_report_metric_submitted')),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('session_report_metric_total_students')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('session_report_metric_submitted')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(
          ValueKey<String>(
            'session_report_student_${escenario.estudiante.nombre}_${escenario.estudiante.apellidos}',
          ),
        ),
        matching: find.textContaining(escenario.estudiante.nombre),
      ),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 600));
    await _esperarVisible(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_finalize_button_${escenario.idSesion}'),
      ),
    );
    await _tapVisible(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_finalize_button_${escenario.idSesion}'),
      ),
    );
    await tester.runAsync(() => backend!.esperarSesionFinalizada(escenario));
  });
}

Future<void> _iniciarSesion(
  WidgetTester tester, {
  required String correo,
  required String contrasena,
}) async {
  await _esperarVisible(
    tester,
    find.byKey(const Key('login_email_field')),
  );
  await tester.enterText(find.byKey(const Key('login_email_field')), correo);
  await tester.enterText(
    find.byKey(const Key('login_password_field')),
    contrasena,
  );
  await _tapVisible(
    tester,
    find.byKey(const Key('login_submit_button')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('inicio_logout_button')),
    timeout: const Duration(seconds: 25),
  );
}

Future<void> _cerrarSesion(WidgetTester tester) async {
  await _tapVisible(
    tester,
    find.byKey(const Key('inicio_logout_button')),
  );
  await _esperarVisible(
    tester,
    find.byKey(const Key('login_email_field')),
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _esperarVisible(tester, finder);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _esperarVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final limite = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure(
    'No se encontro el elemento esperado en ${timeout.inSeconds}s.',
  );
}

Future<String> _obtenerIdPreguntaActual(WidgetTester tester) async {
  final limite = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 250));
    for (final widget in tester.widgetList<Card>(find.byType(Card))) {
      final clave = widget.key;
      if (clave is ValueKey<String> &&
          clave.value.startsWith('exam_question_card_')) {
        return clave.value.replaceFirst('exam_question_card_', '');
      }
    }
  }
  throw TestFailure(
      'No fue posible identificar la pregunta actual del examen.');
}
