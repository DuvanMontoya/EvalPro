/// @archivo   ResumenExamenPantalla.dart
/// @descripcion Presenta resumen de respuestas y confirma envio final del examen.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../Providers/ExamenProvider.dart';

class ResumenExamenPantalla extends ConsumerWidget {
  const ResumenExamenPantalla({super.key});

  /// Construye resumen final previo al envio de respuestas.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(examenActivoProvider);
    if (estado == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final total = estado.preguntasAleatorizadas.length;
    final respondidas = estado.respuestasLocales.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del examen')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Examen: ${estado.examen.titulo}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Preguntas respondidas: $respondidas de $total'),
            const SizedBox(height: 8),
            if (estado.errorEnvio != null)
              Text(estado.errorEnvio!,
                  style: const TextStyle(color: Colors.red)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: estado.estaEnviando
                    ? null
                    : () async {
                        final resultado = await ref
                            .read(examenActivoProvider.notifier)
                            .finalizarYEnviar();
                        if (context.mounted) {
                          context.go(Rutas.examenEnviado, extra: resultado);
                        }
                      },
                icon: const Icon(Icons.send),
                label:
                    Text(estado.estaEnviando ? 'Enviando...' : 'Enviar examen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
