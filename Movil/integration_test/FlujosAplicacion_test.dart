/// @archivo   FlujosAplicacion_test.dart
/// @descripcion Pruebas de integracion para flujos principales de autenticacion y navegacion.
/// @modulo    integration_test
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movil/Aplicacion.dart';
import 'package:movil/Constantes/Textos.dart';
import 'package:movil/Modelos/Enums/RolUsuario.dart';
import 'package:movil/Modelos/Usuario.dart';
import 'package:movil/Providers/AutenticacionProvider.dart';

import '../test/Auxiliares/ApiServicioSimulado.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login exitoso de estudiante navega al inicio', (tester) async {
    final autenticacionPrueba = _AutenticacionEstadoPrueba(
      estadoInicial: const EstadoAutenticacion(
        inicializado: true,
        estaAutenticado: false,
        usuario: null,
        error: null,
        tokenTemporalPrimerLogin: null,
      ),
      alIniciarSesion: (notifier,
          {required correo, required contrasena}) async {
        notifier.establecerEstado(
          EstadoAutenticacion(
            inicializado: true,
            estaAutenticado: true,
            usuario: _crearUsuario(RolUsuario.ESTUDIANTE),
            error: null,
            tokenTemporalPrimerLogin: null,
          ),
        );
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          apiServicioProvider.overrideWith(_construirApiSimulada),
          autenticacionEstadoProvider.overrideWith(() => autenticacionPrueba),
        ],
        child: const Aplicacion(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'estudiante@evalpro.edu',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'Segura123!',
    );
    await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('Tu espacio de evaluacion'), findsOneWidget);
    expect(find.text('Unirse a una sesion'), findsOneWidget);
  });

  testWidgets('login fallido muestra banner de error', (tester) async {
    final autenticacionPrueba = _AutenticacionEstadoPrueba(
      estadoInicial: const EstadoAutenticacion(
        inicializado: true,
        estaAutenticado: false,
        usuario: null,
        error: null,
        tokenTemporalPrimerLogin: null,
      ),
      alIniciarSesion: (notifier,
          {required correo, required contrasena}) async {
        notifier.establecerEstado(
          const EstadoAutenticacion(
            inicializado: true,
            estaAutenticado: false,
            usuario: null,
            error: 'Credenciales invalidas para esta institucion.',
            tokenTemporalPrimerLogin: null,
          ),
        );
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          apiServicioProvider.overrideWith(_construirApiSimulada),
          autenticacionEstadoProvider.overrideWith(() => autenticacionPrueba),
        ],
        child: const Aplicacion(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('login_email_field')),
      'admin@evalpro.edu',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'Segura123!',
    );
    await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login_error_banner')), findsOneWidget);
    expect(
      find.text('Credenciales invalidas para esta institucion.'),
      findsOneWidget,
    );
  });

  testWidgets('administrador abre gestion de usuarios desde inicio',
      (tester) async {
    final autenticacionPrueba = _AutenticacionEstadoPrueba(
      estadoInicial: EstadoAutenticacion(
        inicializado: true,
        estaAutenticado: true,
        usuario: _crearUsuario(RolUsuario.ADMINISTRADOR),
        error: null,
        tokenTemporalPrimerLogin: null,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          apiServicioProvider.overrideWith(_construirApiSimulada),
          autenticacionEstadoProvider.overrideWith(() => autenticacionPrueba),
        ],
        child: const Aplicacion(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(Textos.gestionarUsuarios));
    await tester.tap(find.text(Textos.gestionarUsuarios));
    await tester.pumpAndSettle();

    expect(find.text(Textos.gestionarUsuarios), findsWidgets);
    expect(find.text(Textos.sinDatos), findsOneWidget);
  });
}

ApiServicioSimulado _construirApiSimulada(ApiServicioRef ref) {
  return ApiServicioSimulado(
    alObtener: (ruta, _) async {
      if (ruta.startsWith('/reportes/estudiante/')) {
        return <String, dynamic>{};
      }
      return <dynamic>[];
    },
    alPublicar: (_, __) async => <String, dynamic>{},
  );
}

class _AutenticacionEstadoPrueba extends AutenticacionEstado {
  final EstadoAutenticacion estadoInicial;
  final Future<void> Function(
    _AutenticacionEstadoPrueba notifier, {
    required String correo,
    required String contrasena,
  })? alIniciarSesion;

  _AutenticacionEstadoPrueba({
    required this.estadoInicial,
    this.alIniciarSesion,
  });

  @override
  EstadoAutenticacion build() => estadoInicial;

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    if (alIniciarSesion != null) {
      await alIniciarSesion!(
        this,
        correo: correo,
        contrasena: contrasena,
      );
    }
  }

  @override
  Future<void> cerrarSesion() async {
    state = const EstadoAutenticacion(
      inicializado: true,
      estaAutenticado: false,
      usuario: null,
      error: null,
      tokenTemporalPrimerLogin: null,
    );
  }

  void establecerEstado(EstadoAutenticacion nuevoEstado) {
    state = nuevoEstado;
  }
}

Usuario _crearUsuario(RolUsuario rol) {
  return Usuario(
    id: 'usuario-prueba',
    idInstitucion:
        rol == RolUsuario.SUPERADMINISTRADOR ? null : 'institucion-prueba',
    nombre: 'Usuario',
    apellidos: rol.name,
    correo: 'usuario.${rol.name.toLowerCase()}@evalpro.test',
    rol: rol,
    estadoCuenta: 'ACTIVO',
    primerLogin: false,
    activo: true,
  );
}
