/// @archivo   HojaRespuestasPantalla.dart
/// @descripcion Implementa captura OMR A/B/C/D/E para modalidad de hoja de respuestas.
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
import 'Widgets/CuadriculaOMR.dart';
import 'Widgets/IndicadorConexion.dart';
import 'Widgets/MapaProgreso.dart';
import 'Widgets/TemporizadorExamen.dart';

class HojaRespuestasPantalla extends ConsumerWidget {
  const HojaRespuestasPantalla({super.key});

  void _manejarIntentoSalir(WidgetRef ref, BuildContext context) {
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
            descripcion: 'Intento de retroceso bloqueado desde hoja OMR',
          ),
    );
  }

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
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _manejarIntentoSalir(ref, context);
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
              if (!context.mounted) {
                return;
              }
              if (estadoPosterior != null) {
                final mensaje = estadoPosterior.errorEnvio ??
                    'No fue posible enviar el examen automaticamente. Intenta de nuevo.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(mensaje)),
                );
                return;
              }
              context.go(Rutas.examenEnviado, extra: resultado);
            },
          ),
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
