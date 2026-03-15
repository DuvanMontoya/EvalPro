/// @archivo   PantallasPrincipalesGolden_test.dart
/// @descripcion Golden tests de pantallas criticas para prevenir regresiones visuales.
/// @modulo    test/Golden
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movil/Aplicacion.dart';
import 'package:movil/Modelos/Enums/RolUsuario.dart';
import 'package:movil/Modelos/Usuario.dart';
import 'package:movil/Providers/AutenticacionProvider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('golden login base', (tester) async {
    await _configurarSuperficie(tester, const Size(1080, 1920));
    await tester.pumpWidget(
      _envolverAplicacion(
        _AutenticacionEstadoEstatico(
          const EstadoAutenticacion(
            inicializado: true,
            estaAutenticado: false,
            usuario: null,
            error: null,
            tokenTemporalPrimerLogin: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp).first,
      matchesGoldenFile('goldens/pantallas/login_base.png'),
    );
  });

  testWidgets('golden login con error', (tester) async {
    await _configurarSuperficie(tester, const Size(1080, 1920));
    await tester.pumpWidget(
      _envolverAplicacion(
        _AutenticacionEstadoEstatico(
          const EstadoAutenticacion(
            inicializado: true,
            estaAutenticado: false,
            usuario: null,
            error: 'Credenciales invalidas para esta institucion.',
            tokenTemporalPrimerLogin: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp).first,
      matchesGoldenFile('goldens/pantallas/login_error.png'),
    );
  });

  testWidgets('golden inicio administrador', (tester) async {
    await _configurarSuperficie(tester, const Size(1080, 1920));
    await tester.pumpWidget(
      _envolverAplicacion(
        _AutenticacionEstadoEstatico(
          EstadoAutenticacion(
            inicializado: true,
            estaAutenticado: true,
            usuario: _crearUsuario(RolUsuario.ADMINISTRADOR),
            error: null,
            tokenTemporalPrimerLogin: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp).first,
      matchesGoldenFile('goldens/pantallas/inicio_admin.png'),
    );
  });
}

Future<void> _configurarSuperficie(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

Widget _envolverAplicacion(_AutenticacionEstadoEstatico estado) {
  return ProviderScope(
    overrides: <Override>[
      autenticacionEstadoProvider.overrideWith(() => estado),
    ],
    child: const Aplicacion(),
  );
}

class _AutenticacionEstadoEstatico extends AutenticacionEstado {
  final EstadoAutenticacion _estado;

  _AutenticacionEstadoEstatico(this._estado);

  @override
  EstadoAutenticacion build() => _estado;

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {}

  @override
  Future<void> cerrarSesion() async {}
}

Usuario _crearUsuario(RolUsuario rol) {
  return Usuario(
    id: 'usuario-prueba',
    idInstitucion: 'institucion-prueba',
    nombre: 'Admin',
    apellidos: 'EvalPro',
    correo: 'admin@evalpro.test',
    rol: rol,
    estadoCuenta: 'ACTIVO',
    primerLogin: false,
    activo: true,
  );
}
