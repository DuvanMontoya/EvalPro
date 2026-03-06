/// @archivo   ExamenActivoPantalla.dart
/// @descripcion Presenta preguntas digitales una a una con temporizador y bloqueo de retroceso.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../Modelos/Enums/TipoEventoTelemetria.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Providers/ExamenProvider.dart';
import '../../core/widgets/common/eval_surface.dart';
import 'Widgets/IndicadorConexion.dart';
import 'Widgets/IndicadorSeguridadExamen.dart';
import 'Widgets/MapaProgreso.dart';
import 'Widgets/NavegadorPreguntas.dart';
import 'Widgets/TarjetaPregunta.dart';
import 'Widgets/TemporizadorExamen.dart';

class ExamenActivoPantalla extends ConsumerStatefulWidget {
  const ExamenActivoPantalla({super.key});

  @override
  ConsumerState<ExamenActivoPantalla> createState() =>
      _ExamenActivoPantallaState();
}

class _ExamenActivoPantallaState extends ConsumerState<ExamenActivoPantalla> {
  void _manejarIntentoSalir() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No puedes salir durante la evaluacion en curso.'),
      ),
    );

    final estadoActual = ref.read(examenActivoProvider);
    final idIntento = estadoActual?.idIntento;
    if (idIntento == null) {
      return;
    }

    unawaited(
      ref.read(telemetriaServicioProvider).registrarEvento(
            idIntento: idIntento,
            tipo: TipoEventoTelemetria.PANTALLA_ABANDONADA,
            descripcion: 'Intento de retroceso bloqueado desde examen activo',
          ),
    );
  }

  /// Construye la experiencia de examen digital completo.
  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(examenActivoProvider);
    if (estado == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pregunta = estado.preguntaActual;
    final respondidas = <int>{};
    for (var i = 0; i < estado.preguntasAleatorizadas.length; i++) {
      final id = estado.preguntasAleatorizadas[i].id;
      if (estado.respuestasLocales.containsKey(id)) respondidas.add(i);
    }

    final esUltima =
        estado.indicePreguntaActual == estado.preguntasAleatorizadas.length - 1;
    final puedeRetroceder =
        estado.examen.permitirNavegacion && estado.indicePreguntaActual > 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _manejarIntentoSalir();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 16,
          title: TemporizadorExamen(
            duracionMinutos: estado.examen.duracionMinutos,
            alFinalizar: () async {
              final resultado = await ref
                  .read(examenActivoProvider.notifier)
                  .finalizarYEnviar();
              final estadoPosterior = ref.read(examenActivoProvider);
              if (context.mounted) {
                if (estadoPosterior != null) {
                  final mensaje = estadoPosterior.errorEnvio ??
                      'No fue posible enviar el examen automaticamente. Intenta de nuevo.';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(mensaje)),
                  );
                  return;
                }
                context.go(Rutas.examenEnviado, extra: resultado);
              }
            },
          ),
          actions: const <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: IndicadorSeguridadExamen(),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: IndicadorConexion())
          ],
        ),
        body: EvalPageBackground(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                children: <Widget>[
                  const PanelEstadoSeguridadExamen(),
                  const SizedBox(height: 8),
                  MapaProgreso(
                    totalPreguntas: estado.preguntasAleatorizadas.length,
                    indiceActual: estado.indicePreguntaActual,
                    respondidas: respondidas,
                    permitirNavegacion: estado.examen.permitirNavegacion,
                    alSeleccionar: (indice) {
                      ref.read(examenActivoProvider.notifier).irAPregunta(indice);
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TarjetaPregunta(
                      pregunta: pregunta,
                      respuesta: estado.respuestasLocales[pregunta.id],
                      indiceActual: estado.indicePreguntaActual + 1,
                      totalPreguntas: estado.preguntasAleatorizadas.length,
                      alResponder: (valor) async {
                        await ref
                            .read(examenActivoProvider.notifier)
                            .registrarRespuesta(pregunta.id, valor);
                      },
                    ),
                  ),
                  NavegadorPreguntas(
                    mostrarAnterior: estado.examen.permitirNavegacion,
                    alAnterior: puedeRetroceder
                        ? () => ref
                            .read(examenActivoProvider.notifier)
                            .retrocederPregunta()
                        : null,
                    esUltima: esUltima,
                    alSiguiente: () {
                      if (esUltima) {
                        context.go(Rutas.resumenExamen);
                      } else {
                        ref.read(examenActivoProvider.notifier).avanzarPregunta();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
