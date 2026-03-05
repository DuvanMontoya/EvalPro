/// @archivo   AplicacionNavegacionRoles_test.dart
/// @descripcion Verifica rutas y botones principales por rol en la aplicacion movil.
/// @modulo    test
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movil/Aplicacion.dart';
import 'package:movil/Constantes/Rutas.dart';
import 'package:movil/Constantes/Textos.dart';
import 'package:movil/Modelos/Enums/ModalidadExamen.dart';
import 'package:movil/Modelos/Enums/RolUsuario.dart';
import 'package:movil/Modelos/Enums/TipoPregunta.dart';
import 'package:movil/Modelos/Examen.dart';
import 'package:movil/Modelos/OpcionRespuesta.dart';
import 'package:movil/Modelos/Pregunta.dart';
import 'package:movil/Modelos/RespuestaLocal.dart';
import 'package:movil/Modelos/Usuario.dart';
import 'package:movil/Providers/AutenticacionProvider.dart';
import 'package:movil/Providers/ExamenProvider.dart';
import 'package:movil/Providers/Modelos/ExamenActivoEstado.dart';

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

  testWidgets(
      'estudiante no rebota a unirse cuando existe examen activo al navegar',
      (tester) async {
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

    final contexto = tester.element(find.text('Unirse a una sesion'));
    final container = ProviderScope.containerOf(contexto, listen: false);
    container.read(examenActivoProvider.notifier).state =
        _crearEstadoExamenActivoPrueba();
    await tester.pump();

    final contextoActual = tester.element(find.byType(Scaffold).first);
    GoRouter.of(contextoActual).go(Rutas.examenActivo);
    await tester.pumpAndSettle();

    expect(find.text('Unirse a sesion'), findsNothing);
    expect(find.text('Pregunta de prueba'), findsOneWidget);
  });

  testWidgets(
      'no reinicia navegacion a inicio cuando cambia examen activo estando en unirse',
      (tester) async {
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

    final contextoInicio = tester.element(find.text('Unirse a una sesion'));
    GoRouter.of(contextoInicio).go(Rutas.unirseExamen);
    await tester.pumpAndSettle();
    expect(find.text('Unirse a sesion'), findsOneWidget);

    final contextoUnirse = tester.element(find.byType(Scaffold).first);
    final container = ProviderScope.containerOf(contextoUnirse, listen: false);
    container.read(examenActivoProvider.notifier).state =
        _crearEstadoExamenActivoPrueba();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Unirse a sesion'), findsOneWidget);
    expect(find.text('Tu espacio de evaluacion'), findsNothing);
  });

  testWidgets(
      'estudiante puede abrir comprobante de examen enviado sin intento activo en memoria',
      (tester) async {
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

    final contexto = tester.element(find.text('Unirse a una sesion'));
    GoRouter.of(contexto).go(Rutas.examenEnviado);
    await tester.pumpAndSettle();

    expect(find.text(Textos.examenEnviado), findsWidgets);
    expect(find.text('Tu examen fue enviado correctamente'), findsOneWidget);
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

  testWidgets('superadministrador accede a operacion global y academica',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          apiServicioProvider.overrideWith(_construirApiSimulada),
          autenticacionEstadoProvider.overrideWith(
            () => _AutenticacionEstadoFalso(
              EstadoAutenticacion(
                inicializado: true,
                estaAutenticado: true,
                usuario: _crearUsuario(RolUsuario.SUPERADMINISTRADOR),
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
    expect(find.text(Textos.gestionarInstituciones), findsOneWidget);
    expect(find.text(Textos.gestionarUsuarios), findsOneWidget);
    expect(find.text(Textos.gestionarGrupos), findsOneWidget);
    expect(find.text(Textos.gestionarPeriodos), findsOneWidget);
    expect(find.text(Textos.gestionarReclamos), findsOneWidget);
    expect(find.text(Textos.calificacionManual), findsNothing);

    await tester.ensureVisible(find.text(Textos.gestionarSesiones));
    await tester.tap(find.text(Textos.gestionarSesiones));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(Textos.gestionarSesiones), findsWidgets);
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

ExamenActivoEstado _crearEstadoExamenActivoPrueba() {
  final pregunta = Pregunta(
    id: 'pregunta-prueba',
    enunciado: 'Pregunta de prueba',
    tipo: TipoPregunta.OPCION_MULTIPLE,
    orden: 1,
    puntaje: 1,
    opciones: const <OpcionRespuesta>[
      OpcionRespuesta(
        id: 'opcion-a',
        letra: 'A',
        contenido: 'Opcion A',
        orden: 1,
        preguntaId: 'pregunta-prueba',
      ),
      OpcionRespuesta(
        id: 'opcion-b',
        letra: 'B',
        contenido: 'Opcion B',
        orden: 2,
        preguntaId: 'pregunta-prueba',
      ),
    ],
  );

  final examen = Examen(
    id: 'examen-prueba',
    titulo: 'Examen de prueba',
    modalidad: ModalidadExamen.DIGITAL_COMPLETO,
    duracionMinutos: 20,
    permitirNavegacion: true,
    mostrarPuntaje: true,
    preguntas: <Pregunta>[pregunta],
  );

  final ahora = DateTime.utc(2026, 3, 4, 12, 0, 0);
  return ExamenActivoEstado(
    examen: examen,
    preguntasAleatorizadas: <Pregunta>[pregunta],
    indicePreguntaActual: 0,
    respuestasLocales: const <String, RespuestaLocal>{},
    tiempoInicioExamen: ahora,
    tiempoInicioPreguntaActual: ahora,
    estaEnviando: false,
    errorEnvio: null,
    idIntento: 'intento-prueba',
  );
}
