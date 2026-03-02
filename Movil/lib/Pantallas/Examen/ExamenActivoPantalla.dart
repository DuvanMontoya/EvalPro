/// @archivo   ExamenActivoPantalla.dart
/// @descripcion Presenta preguntas digitales una a una con temporizador y bloqueo de retroceso.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../Providers/ExamenProvider.dart';
import 'Widgets/IndicadorConexion.dart';
import 'Widgets/MapaProgreso.dart';
import 'Widgets/NavegadorPreguntas.dart';
import 'Widgets/TarjetaPregunta.dart';
import 'Widgets/TemporizadorExamen.dart';

class ExamenActivoPantalla extends ConsumerWidget {
  const ExamenActivoPantalla({super.key});

  /// Construye la experiencia de examen digital completo.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: TemporizadorExamen(
            duracionMinutos: estado.examen.duracionMinutos,
            alFinalizar: () async {
              final resultado = await ref
                  .read(examenActivoProvider.notifier)
                  .finalizarYEnviar();
              if (context.mounted) {
                context.go(Rutas.examenEnviado, extra: resultado);
              }
            },
          ),
          actions: const <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: IndicadorConexion())
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              MapaProgreso(
                totalPreguntas: estado.preguntasAleatorizadas.length,
                indiceActual: estado.indicePreguntaActual,
                respondidas: respondidas,
                permitirNavegacion: estado.examen.permitirNavegacion,
                alSeleccionar: (indice) {
                  ref.read(examenActivoProvider.notifier).irAPregunta(indice);
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TarjetaPregunta(
                  pregunta: pregunta,
                  respuesta: estado.respuestasLocales[pregunta.id],
                  alResponder: (valor) async {
                    await ref
                        .read(examenActivoProvider.notifier)
                        .registrarRespuesta(pregunta.id, valor);
                  },
                ),
              ),
              NavegadorPreguntas(
                mostrarAnterior: estado.examen.permitirNavegacion,
                alAnterior: () => ref
                    .read(examenActivoProvider.notifier)
                    .retrocederPregunta(),
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
    );
  }
}
