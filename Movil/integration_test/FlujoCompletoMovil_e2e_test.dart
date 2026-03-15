/// @archivo   FlujoCompletoMovil_e2e_test.dart
/// @descripcion Ejecuta flujo e2e real docente-estudiante contra backend real.
/// @modulo    integration_test
/// @autor     EvalPro
/// @fecha     2026-03-05

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movil/Configuracion/Entorno.dart';
import 'package:movil/Constantes/Rutas.dart';
import 'package:movil/main.dart' as app;

import 'Soporte/BackendE2eHelper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'docente monitorea sesion, estudiante presenta examen y docente valida reporte',
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
    print('E2E paso: escenario preparado ${escenario.idSesion}');

    await app.main();
    await _esperarVisible(
      tester,
      find.byKey(const Key('login_email_field')),
    );
    print('E2E paso: login docente listo');

    await _iniciarSesion(
      tester,
      correo: escenario.docente.correo,
      contrasena: escenario.docente.contrasena,
    );
    print('E2E paso: docente autenticado');

    await _tapVisible(
      tester,
      find.byKey(const Key('inicio_manage_sessions_button')),
    );
    final codigoSesion = (await tester.runAsync(
      () => backend!.activarSesionComoDocente(escenario),
    ))!;
    print('E2E paso: sesion activada $codigoSesion');
    final botonActualizar = find.byTooltip('Actualizar');
    if (botonActualizar.evaluate().isNotEmpty) {
      print('E2E paso: refrescando lista de sesiones');
      await _tapVisible(tester, botonActualizar);
      print('E2E paso: refresco solicitado');
    }
    await _esperarVisible(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_finalize_button_${escenario.idSesion}'),
      ),
      timeout: const Duration(seconds: 20),
    );
    print('E2E paso: boton finalizar visible');
    await _esperarVisible(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_report_button_${escenario.idSesion}'),
      ),
    );
    print('E2E paso: boton reporte visible');
    expect(codigoSesion, isNotEmpty);

    print('E2E paso: regresando a inicio docente');
    await _navegarARuta(tester, Rutas.inicio);
    await _esperarVisible(
      tester,
      find.byKey(const Key('inicio_logout_button')),
    );
    await _cerrarSesion(tester);
    print('E2E paso: docente cerro sesion');

    await _iniciarSesion(
      tester,
      correo: escenario.estudiante.correo,
      contrasena: escenario.estudiante.contrasena,
    );
    print('E2E paso: estudiante autenticado');

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
    await _activarBotonElevado(
      tester,
      find.byKey(ValueKey<String>('session_join_button_${escenario.idSesion}')),
    );
    print('E2E paso: estudiante unido a sesion');
    final mensajesJoin = _leerTextosSnackBar(tester);
    if (mensajesJoin.isNotEmpty) {
      print('E2E aviso join UI: ${mensajesJoin.join(' | ')}');
    }
    final totalParticipantes = (await tester.runAsync(
      () => backend!.obtenerTotalParticipantesSesion(escenario),
    ))!;
    print('E2E paso: participantes reportados tras join = $totalParticipantes');
    await _esperarVisible(
      tester,
      find.byKey(const Key('exam_next_button')),
      timeout: const Duration(seconds: 30),
    );
    print('E2E paso: examen activo visible');

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
    print('E2E paso: examen enviado desde UI');
    await _esperarVisible(
      tester,
      find.byKey(const Key('exam_back_home_button')),
      timeout: const Duration(seconds: 35),
    );
    expect(find.text('Tu examen fue enviado'), findsOneWidget);

    await _tapVisible(
      tester,
      find.byKey(const Key('exam_back_home_button')),
    );
    await _esperarVisible(
      tester,
      find.byKey(const Key('inicio_logout_button')),
    );

    await tester.runAsync(() => backend!.esperarReporteConEntrega(escenario));
    print('E2E paso: reporte backend reflejo entrega');

    await _cerrarSesion(tester);
    print('E2E paso: estudiante cerro sesion');

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
    await _activarBotonAccion(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_report_button_${escenario.idSesion}'),
      ),
    );
    print('E2E paso: docente abrio reporte');

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
    final tarjetaEstudiante = find.byKey(
      ValueKey<String>(
        'session_report_student_${escenario.estudiante.nombre}_${escenario.estudiante.apellidos}',
      ),
    );
    await _desplazarHastaVisible(tester, tarjetaEstudiante);
    expect(tarjetaEstudiante, findsOneWidget);

    await _navegarARuta(tester, Rutas.gestionSesiones);
    await _esperarVisible(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_finalize_button_${escenario.idSesion}'),
      ),
    );
    await _activarBotonAccion(
      tester,
      find.byKey(
        ValueKey<String>(
            'session_management_finalize_button_${escenario.idSesion}'),
      ),
    );
    await tester.runAsync(() => backend!.esperarSesionFinalizada(escenario));
    print('E2E paso: sesion finalizada');
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
    timeout: const Duration(seconds: 25),
  );
}

Future<void> _activarBotonElevado(WidgetTester tester, Finder finder) async {
  await _esperarVisible(tester, finder);
  await tester.ensureVisible(finder);
  final boton = tester.widget<ElevatedButton>(finder);
  final accion = boton.onPressed;
  if (accion == null) {
    throw TestFailure('El boton esperado existe pero esta deshabilitado.');
  }
  accion();
  await _bombearDurante(tester, const Duration(seconds: 5));
}

Future<void> _activarBotonAccion(WidgetTester tester, Finder finder) async {
  await _esperarVisible(tester, finder);
  await tester.ensureVisible(finder);
  final widget = tester.widget<Widget>(finder);

  VoidCallback? accion;
  if (widget is ElevatedButton) {
    accion = widget.onPressed;
  } else if (widget is OutlinedButton) {
    accion = widget.onPressed;
  } else if (widget is FilledButton) {
    accion = widget.onPressed;
  } else if (widget is TextButton) {
    accion = widget.onPressed;
  } else if (widget is IconButton) {
    accion = widget.onPressed;
  }

  if (accion == null) {
    throw TestFailure(
      'El widget esperado no expone una accion compatible o esta deshabilitado.',
    );
  }

  accion();
  await _bombearDurante(tester, const Duration(seconds: 5));
}

Future<void> _navegarARuta(WidgetTester tester, String ruta) async {
  final contexto = tester.element(find.byType(Scaffold).first);
  GoRouter.of(contexto).go(ruta);
  await tester.pump(const Duration(milliseconds: 600));
}

List<String> _leerTextosSnackBar(WidgetTester tester) {
  return tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.byType(Text),
        ),
      )
      .map((texto) => texto.data?.trim() ?? '')
      .where((texto) => texto.isNotEmpty)
      .toList(growable: false);
}

Future<void> _bombearDurante(
  WidgetTester tester,
  Duration duracion,
) async {
  final limite = DateTime.now().add(duracion);
  while (DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 250));
  }
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

Future<void> _desplazarHastaVisible(
  WidgetTester tester,
  Finder finder, {
  double delta = 320,
  Duration timeout = const Duration(seconds: 15),
}) async {
  final limite = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(limite)) {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder);
      await tester.pump(const Duration(milliseconds: 250));
      return;
    }
    await tester.drag(find.byType(Scrollable).first, Offset(0, -delta));
    await tester.pump(const Duration(milliseconds: 350));
  }
  throw TestFailure(
    'No se pudo desplazar hasta el elemento esperado en ${timeout.inSeconds}s.',
  );
}

Future<String> _obtenerIdPreguntaActual(WidgetTester tester) async {
  final limite = DateTime.now().add(const Duration(seconds: 25));
  final buscadorPregunta = find.byWidgetPredicate((widget) {
    final clave = widget.key;
    return clave is ValueKey<String> &&
        clave.value.startsWith('exam_question_card_');
  });
  while (DateTime.now().isBefore(limite)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (buscadorPregunta.evaluate().isNotEmpty) {
      final widget = tester.widget<Widget>(buscadorPregunta.first);
      final clave = widget.key;
      if (clave is ValueKey<String>) {
        return clave.value.replaceFirst('exam_question_card_', '');
      }
    }
  }
  throw TestFailure(
      'No fue posible identificar la pregunta actual del examen.');
}
