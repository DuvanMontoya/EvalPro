/// @archivo   FormularioLogin_test.dart
/// @descripcion Verifica interacciones del formulario de login y flujo de envio.
/// @modulo    test/Pantallas/Autenticacion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movil/Configuracion/Tema.dart';
import 'package:movil/Providers/AutenticacionProvider.dart';
import 'package:movil/Pantallas/Autenticacion/Widgets/FormularioLogin.dart';

void main() {
  testWidgets('valida campos obligatorios antes de enviar', (tester) async {
    var llamadas = 0;
    await tester.pumpWidget(
      _envolverFormulario(
        _AutenticacionEstadoFalso(
          estadoInicial: const EstadoAutenticacion(
            inicializado: true,
            estaAutenticado: false,
            usuario: null,
            error: null,
          ),
          alIniciarSesion: ({required correo, required contrasena}) async {
            llamadas++;
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.text('Ingresa un correo institucional'), findsOneWidget);
    expect(find.text('Ingresa tu contrasena'), findsOneWidget);
    expect(llamadas, 0);
  });

  testWidgets('permite alternar mostrar/ocultar contrasena', (tester) async {
    await tester.pumpWidget(
      _envolverFormulario(
        _AutenticacionEstadoFalso(
          estadoInicial: const EstadoAutenticacion(
            inicializado: true,
            estaAutenticado: false,
            usuario: null,
            error: null,
          ),
          alIniciarSesion: ({required correo, required contrasena}) async {},
        ),
      ),
    );

    final campoInicial = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('login_password_field')),
        matching: find.byType(EditableText),
      ),
    );
    expect(campoInicial.obscureText, isTrue);

    await tester.tap(find.byKey(const Key('login_password_toggle')));
    await tester.pump();

    final campoVisible = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('login_password_field')),
        matching: find.byType(EditableText),
      ),
    );
    expect(campoVisible.obscureText, isFalse);
  });

  testWidgets('envia credenciales limpias y muestra estado de carga',
      (tester) async {
    final peticion = Completer<void>();
    String? correoEnviado;
    String? contrasenaEnviada;
    await tester.pumpWidget(
      _envolverFormulario(
        _AutenticacionEstadoFalso(
          estadoInicial: const EstadoAutenticacion(
            inicializado: true,
            estaAutenticado: false,
            usuario: null,
            error: null,
          ),
          alIniciarSesion: ({required correo, required contrasena}) async {
            correoEnviado = correo;
            contrasenaEnviada = contrasena;
            await peticion.future;
          },
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      '  estudiante@evalpro.edu  ',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'Segura123!',
    );

    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.byKey(const Key('login_loading_indicator')), findsOneWidget);
    final botonDuranteCarga = tester.widget<ElevatedButton>(
      find.byKey(const Key('login_submit_button')),
    );
    expect(botonDuranteCarga.onPressed, isNull);
    expect(correoEnviado, 'estudiante@evalpro.edu');
    expect(contrasenaEnviada, 'Segura123!');

    peticion.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_loading_indicator')), findsNothing);
  });
}

Widget _envolverFormulario(_AutenticacionEstadoFalso estadoFalso) {
  return ProviderScope(
    overrides: <Override>[
      autenticacionEstadoProvider.overrideWith(() => estadoFalso),
    ],
    child: MaterialApp(
      theme: Tema.obtenerTema(),
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: FormularioLogin(),
        ),
      ),
    ),
  );
}

class _AutenticacionEstadoFalso extends AutenticacionEstado {
  final EstadoAutenticacion estadoInicial;
  final Future<void> Function({
    required String correo,
    required String contrasena,
  }) alIniciarSesion;

  _AutenticacionEstadoFalso({
    required this.estadoInicial,
    required this.alIniciarSesion,
  });

  @override
  EstadoAutenticacion build() => estadoInicial;

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    await alIniciarSesion(correo: correo, contrasena: contrasena);
  }

  @override
  Future<void> cerrarSesion() async {}
}
