/// @archivo   HojaRespuestasPantalla.dart
/// @descripcion Implementa captura OMR A/B/C/D/E para modalidad de hoja de respuestas.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../Providers/ExamenProvider.dart';
import 'Widgets/CuadriculaOMR.dart';
import 'Widgets/IndicadorConexion.dart';
import 'Widgets/MapaProgreso.dart';

class HojaRespuestasPantalla extends ConsumerWidget {
  const HojaRespuestasPantalla({super.key});

  /// Construye la pantalla OMR con retroceso del SO bloqueado.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(examenActivoProvider);
    if (estado == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final respuestas = <int, String?>{};
    final respondidas = <int>{};
    for (var i = 0; i < estado.preguntasAleatorizadas.length; i++) {
      final pregunta = estado.preguntasAleatorizadas[i];
      final opciones =
          estado.respuestasLocales[pregunta.id]?.opcionesSeleccionadas ??
              <String>[];
      final valor = opciones.isNotEmpty ? opciones.first : null;
      respuestas[i + 1] = valor;
      if (valor != null) respondidas.add(i);
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hoja de respuestas'),
          actions: const <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: IndicadorConexion())
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: MapaProgreso(
                totalPreguntas: estado.preguntasAleatorizadas.length,
                indiceActual: estado.indicePreguntaActual,
                respondidas: respondidas,
                permitirNavegacion: true,
                alSeleccionar: (indice) =>
                    ref.read(examenActivoProvider.notifier).irAPregunta(indice),
              ),
            ),
            Expanded(
              child: CuadriculaOMR(
                totalPreguntas: estado.preguntasAleatorizadas.length,
                respuestas: respuestas,
                alSeleccionar: (numero, letra) async {
                  final indice = numero - 1;
                  final pregunta = estado.preguntasAleatorizadas[indice];
                  final actual = respuestas[numero];
                  if (actual == letra) {
                    await ref
                        .read(examenActivoProvider.notifier)
                        .registrarRespuesta(pregunta.id, <String>[]);
                    return;
                  }
                  await ref
                      .read(examenActivoProvider.notifier)
                      .registrarRespuesta(pregunta.id, letra);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go(Rutas.resumenExamen),
          label: const Text('Enviar'),
          icon: const Icon(Icons.send),
        ),
      ),
    );
  }
}
