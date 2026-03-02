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
import 'Pantallas/Autenticacion/IniciarSesionPantalla.dart';
import 'Pantallas/Error/SesionInvalidadaPantalla.dart';
import 'Pantallas/Error/SinConexionPantalla.dart';
import 'Pantallas/Examen/ExamenActivoPantalla.dart';
import 'Pantallas/Examen/ExamenEnviadoPantalla.dart';
import 'Pantallas/Examen/HojaRespuestasPantalla.dart';
import 'Pantallas/Examen/ResumenExamenPantalla.dart';
import 'Pantallas/Examen/UnirseASesionPantalla.dart';
import 'Pantallas/Inicio/InicioPantalla.dart';
import 'Providers/AutenticacionProvider.dart';
import 'Providers/ExamenProvider.dart';

/// Widget raiz que configura tema y enrutamiento.
class Aplicacion extends ConsumerWidget {
  const Aplicacion({super.key});

  /// Construye la aplicacion usando el estado de autenticacion y examen activo.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoAutenticacion = ref.watch(autenticacionEstadoProvider);
    final examenActivo = ref.watch(examenActivoProvider);

    final enrutador = GoRouter(
      initialLocation: Rutas.iniciarSesion,
      redirect: (contexto, estado) {
        if (!estadoAutenticacion.inicializado) {
          return estado.matchedLocation == Rutas.iniciarSesion
              ? null
              : Rutas.iniciarSesion;
        }

        final enPantallaLogin = estado.matchedLocation == Rutas.iniciarSesion;
        final esRutaExamen = estado.matchedLocation.startsWith('/examen/');

        if (!estadoAutenticacion.estaAutenticado) {
          return enPantallaLogin ? null : Rutas.iniciarSesion;
        }

        if (enPantallaLogin) {
          return Rutas.inicio;
        }

        if (esRutaExamen &&
            examenActivo == null &&
            estado.matchedLocation != Rutas.unirseExamen) {
          return Rutas.unirseExamen;
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
          path: Rutas.sinConexion,
          builder: (contexto, estado) => const SinConexionPantalla(),
        ),
        GoRoute(
          path: Rutas.sesionInvalidada,
          builder: (contexto, estado) => const SesionInvalidadaPantalla(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'EvalPro Movil',
      debugShowCheckedModeBanner: false,
      theme: Tema.obtenerTema(),
      routerConfig: enrutador,
    );
  }
}
