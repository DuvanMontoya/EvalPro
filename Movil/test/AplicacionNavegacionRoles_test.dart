/// @archivo   AplicacionNavegacionRoles_test.dart
/// @descripcion Verifica rutas y botones principales por rol en la aplicacion movil.
/// @modulo    test
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movil/Aplicacion.dart';
import 'package:movil/Constantes/Textos.dart';
import 'package:movil/Modelos/Enums/RolUsuario.dart';
import 'package:movil/Modelos/Usuario.dart';
import 'package:movil/Providers/AutenticacionProvider.dart';

import 'Auxiliares/ApiServicioSimulado.dart';

void main() {
  testWidgets('muestra inicio de sesion cuando no hay autenticacion',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          apiServicioProvider.overrideWith(_construirApiSimulada),
          autenticacionEstadoProvider.overrideWith(
            () => _AutenticacionEstadoFalso(
              const EstadoAutenticacion(
                inicializado: true,
                estaAutenticado: false,
                usuario: null,
                error: null,
                tokenTemporalPrimerLogin: null,
              ),
            ),
          ),
        ],
        child: const Aplicacion(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(Textos.iniciarSesion), findsWidgets);
  });

  testWidgets('estudiante ve botones de unirse y resultados', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          apiServicioProvider.overrideWith(_construirApiSimulada),
          autenticacionEstadoProvider.overrideWith(
            () => _AutenticacionEstadoFalso(
              EstadoAutenticacion(
                inicializado: true,
                estaAutenticado: true,
                usuario: _crearUsuario(RolUsuario.ESTUDIANTE),
                error: null,
                tokenTemporalPrimerLogin: null,
              ),
            ),
          ),
        ],
        child: const Aplicacion(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unirse a una sesion'), findsOneWidget);
    expect(find.text(Textos.misResultados), findsOneWidget);
    expect(find.text(Textos.gestionarSesiones), findsNothing);

    await tester.ensureVisible(find.text(Textos.misResultados));
    await tester.tap(find.text(Textos.misResultados));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(Textos.misResultados), findsWidgets);
  });

  testWidgets('administrador accede a botones de gestion', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          apiServicioProvider.overrideWith(_construirApiSimulada),
          autenticacionEstadoProvider.overrideWith(
            () => _AutenticacionEstadoFalso(
              EstadoAutenticacion(
                inicializado: true,
                estaAutenticado: true,
                usuario: _crearUsuario(RolUsuario.ADMINISTRADOR),
                error: null,
                tokenTemporalPrimerLogin: null,
              ),
            ),
          ),
        ],
        child: const Aplicacion(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(Textos.gestionarSesiones), findsOneWidget);
    expect(find.text(Textos.gestionarExamenes), findsOneWidget);
    expect(find.text(Textos.gestionarGrupos), findsOneWidget);
    expect(find.text(Textos.gestionarPeriodos), findsOneWidget);
    expect(find.text(Textos.gestionarUsuarios), findsOneWidget);
    expect(find.text(Textos.gestionarReclamos), findsOneWidget);
    expect(find.text(Textos.calificacionManual), findsOneWidget);
    expect(find.text(Textos.misResultados), findsNothing);

    await tester.ensureVisible(find.text(Textos.gestionarUsuarios));
    await tester.tap(find.text(Textos.gestionarUsuarios));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(Textos.gestionarUsuarios), findsWidgets);
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

class _AutenticacionEstadoFalso extends AutenticacionEstado {
  final EstadoAutenticacion _estadoInicial;

  _AutenticacionEstadoFalso(this._estadoInicial);

  @override
  EstadoAutenticacion build() => _estadoInicial;

  @override
  Future<void> iniciarSesion(
      {required String correo, required String contrasena}) async {}

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
