/// @archivo   Aplicacion.dart
/// @descripcion Define MaterialApp.router con protecciones de rutas segun sesion e intento activo.
/// @modulo    lib
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'Configuracion/Tema.dart';
import 'Constantes/Rutas.dart';
import 'Modelos/Enums/RolUsuario.dart';
import 'Pantallas/Autenticacion/IniciarSesionPantalla.dart';
import 'Pantallas/Error/SesionInvalidadaPantalla.dart';
import 'Pantallas/Error/SinConexionPantalla.dart';
import 'Pantallas/Examen/ExamenActivoPantalla.dart';
import 'Pantallas/Examen/ExamenEnviadoPantalla.dart';
import 'Pantallas/Examen/HojaRespuestasPantalla.dart';
import 'Pantallas/Examen/ResultadosEstudiantePantalla.dart';
import 'Pantallas/Examen/ResumenExamenPantalla.dart';
import 'Pantallas/Examen/UnirseASesionPantalla.dart';
import 'Pantallas/Gestion/CalificacionManualPantalla.dart';
import 'Pantallas/Gestion/ExamenesGestionPantalla.dart';
import 'Pantallas/Gestion/GruposGestionPantalla.dart';
import 'Pantallas/Gestion/InstitucionesGestionPantalla.dart';
import 'Pantallas/Gestion/PeriodosGestionPantalla.dart';
import 'Pantallas/Gestion/ReclamosGestionPantalla.dart';
import 'Pantallas/Gestion/ReporteSesionPantalla.dart';
import 'Pantallas/Gestion/SesionesGestionPantalla.dart';
import 'Pantallas/Gestion/UsuariosGestionPantalla.dart';
import 'Pantallas/Inicio/InicioPantalla.dart';
import 'Providers/AutenticacionProvider.dart';
import 'Providers/ExamenProvider.dart';

/// Widget raiz que configura tema y enrutamiento.
class Aplicacion extends ConsumerStatefulWidget {
  const Aplicacion({super.key});

  @override
  ConsumerState<Aplicacion> createState() => _AplicacionState();
}

class _AplicacionState extends ConsumerState<Aplicacion> {
  late final ValueNotifier<int> _refrescadorEnrutador;
  late final GoRouter _enrutador;
  late final ProviderSubscription<dynamic> _suscripcionAutenticacion;
  late final ProviderSubscription<dynamic> _suscripcionExamenActivo;

  @override
  void initState() {
    super.initState();
    _refrescadorEnrutador = ValueNotifier<int>(0);
    _enrutador = _crearEnrutador();
    _suscripcionAutenticacion = ref.listenManual(
      autenticacionEstadoProvider,
      (_, __) => _refrescadorEnrutador.value++,
    );
    _suscripcionExamenActivo = ref.listenManual(
      examenActivoProvider,
      (_, __) => _refrescadorEnrutador.value++,
    );
  }

  @override
  void dispose() {
    _suscripcionAutenticacion.close();
    _suscripcionExamenActivo.close();
    _enrutador.dispose();
    _refrescadorEnrutador.dispose();
    super.dispose();
  }

  GoRouter _crearEnrutador() {
    return GoRouter(
      initialLocation: Rutas.iniciarSesion,
      refreshListenable: _refrescadorEnrutador,
      redirect: (contexto, estado) {
        final estadoAutenticacion = ref.read(autenticacionEstadoProvider);
        final examenActivo = ref.read(examenActivoProvider);
        final rol = estadoAutenticacion.usuario?.rol;
        final esEstudiante = rol == RolUsuario.ESTUDIANTE;
        if (!estadoAutenticacion.inicializado) {
          return estado.matchedLocation == Rutas.iniciarSesion
              ? null
              : Rutas.iniciarSesion;
        }

        final enPantallaLogin = estado.matchedLocation == Rutas.iniciarSesion;
        final esRutaExamen = estado.matchedLocation.startsWith('/examen/');
        final esRutaResultadosEstudiante =
            estado.matchedLocation == Rutas.resultadosEstudiante;
        final esRutaExamenFlujo = esRutaExamen && !esRutaResultadosEstudiante;
        final esRutaGestion = estado.matchedLocation.startsWith('/gestion/');

        if (!estadoAutenticacion.estaAutenticado) {
          return enPantallaLogin ? null : Rutas.iniciarSesion;
        }

        if (enPantallaLogin) {
          return Rutas.inicio;
        }

        if (esEstudiante &&
            esRutaExamenFlujo &&
            examenActivo == null &&
            estado.matchedLocation != Rutas.unirseExamen) {
          return Rutas.unirseExamen;
        }

        if (!esEstudiante && esRutaExamen) {
          return Rutas.inicio;
        }

        if (esEstudiante && esRutaGestion) {
          return Rutas.inicio;
        }

        return null;
      },
      routes: <GoRoute>[
        GoRoute(
          path: Rutas.iniciarSesion,
          builder: (contexto, estado) => const IniciarSesionPantalla(),
        ),
        GoRoute(
          path: Rutas.inicio,
          builder: (contexto, estado) => const InicioPantalla(),
        ),
        GoRoute(
          path: Rutas.unirseExamen,
          builder: (contexto, estado) => const UnirseASesionPantalla(),
        ),
        GoRoute(
          path: Rutas.resultadosEstudiante,
          builder: (contexto, estado) => const ResultadosEstudiantePantalla(),
        ),
        GoRoute(
          path: Rutas.examenActivo,
          builder: (contexto, estado) => const ExamenActivoPantalla(),
        ),
        GoRoute(
          path: Rutas.hojaRespuestas,
          builder: (contexto, estado) => const HojaRespuestasPantalla(),
        ),
        GoRoute(
          path: Rutas.resumenExamen,
          builder: (contexto, estado) => const ResumenExamenPantalla(),
        ),
        GoRoute(
          path: Rutas.examenEnviado,
          builder: (contexto, estado) => const ExamenEnviadoPantalla(),
        ),
        GoRoute(
          path: Rutas.gestionSesiones,
          builder: (contexto, estado) => const SesionesGestionPantalla(),
        ),
        GoRoute(
          path: Rutas.gestionExamenes,
          builder: (contexto, estado) => const ExamenesGestionPantalla(),
        ),
        GoRoute(
          path: Rutas.gestionInstituciones,
          builder: (contexto, estado) => const InstitucionesGestionPantalla(),
        ),
        GoRoute(
          path: Rutas.gestionUsuarios,
          builder: (contexto, estado) => const UsuariosGestionPantalla(),
        ),
        GoRoute(
          path: Rutas.gestionGrupos,
          builder: (contexto, estado) => const GruposGestionPantalla(),
        ),
        GoRoute(
          path: Rutas.gestionPeriodos,
          builder: (contexto, estado) => const PeriodosGestionPantalla(),
        ),
        GoRoute(
          path: Rutas.gestionReclamos,
          builder: (contexto, estado) => const ReclamosGestionPantalla(),
        ),
        GoRoute(
          path: Rutas.gestionCalificacionManual,
          builder: (contexto, estado) => const CalificacionManualPantalla(),
        ),
        GoRoute(
          path: Rutas.reporteSesion,
          builder: (contexto, estado) {
            final idSesion = estado.pathParameters['idSesion'];
            if (idSesion == null || idSesion.isEmpty) {
              return const SinConexionPantalla();
            }
            return ReporteSesionPantalla(idSesion: idSesion);
          },
        ),
        GoRoute(
          path: Rutas.sinConexion,
          builder: (contexto, estado) => const SinConexionPantalla(),
        ),
        GoRoute(
          path: Rutas.sesionInvalidada,
          builder: (contexto, estado) => const SesionInvalidadaPantalla(),
        ),
      ],
    );
  }

  /// Construye la aplicacion usando estado autenticado y enrutador estable.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EvalPro Movil',
      debugShowCheckedModeBanner: false,
      theme: Tema.obtenerTema(),
      routerConfig: _enrutador,
    );
  }
}
