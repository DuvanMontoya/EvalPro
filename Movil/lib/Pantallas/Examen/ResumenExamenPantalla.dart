/// @archivo   ResumenExamenPantalla.dart
/// @descripcion Presenta resumen de respuestas y confirma envio final del examen.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../Constantes/Colores.dart';
import '../../Constantes/Dimensiones.dart';
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
    final pendientes = total - respondidas;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del examen')),
      body: ListView(
        padding: const EdgeInsets.all(Dimensiones.espaciadoLg),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Dimensiones.espaciadoLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    estado.examen.titulo,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoMd),
                  _FilaResumen(
                    etiqueta: 'Total de preguntas',
                    valor: '$total',
                  ),
                  _FilaResumen(
                    etiqueta: 'Respondidas',
                    valor: '$respondidas',
                  ),
                  _FilaResumen(
                    etiqueta: 'Pendientes',
                    valor: '$pendientes',
                    advertencia: pendientes > 0,
                  ),
                ],
              ),
            ),
          ),
          if (estado.errorEnvio != null) ...<Widget>[
            const SizedBox(height: Dimensiones.espaciadoMd),
            Container(
              padding: const EdgeInsets.all(Dimensiones.espaciadoMd),
              decoration: BoxDecoration(
                color: const Color(0xFFFEECEC),
                borderRadius: BorderRadius.circular(Dimensiones.radioMd),
              ),
              child: Text(
                estado.errorEnvio!,
                style: textTheme.bodySmall?.copyWith(
                  color: Colores.rojoError,
                ),
              ),
            ),
          ],
          const SizedBox(height: Dimensiones.espaciadoXl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: estado.estaEnviando
                  ? null
                  : () async {
                      final resultado = await ref
                          .read(examenActivoProvider.notifier)
                          .finalizarYEnviar();
                      final estadoPosterior = ref.read(examenActivoProvider);
                      if (context.mounted) {
                        if (estadoPosterior != null) {
                          final mensaje = estadoPosterior.errorEnvio ??
                              'No fue posible enviar el examen. Revisa la conexion e intenta nuevamente.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(mensaje)),
                          );
                          return;
                        }
                        context.go(Rutas.examenEnviado, extra: resultado);
                      }
                    },
              icon: estado.estaEnviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                  estado.estaEnviando ? 'Enviando examen...' : 'Enviar examen'),
            ),
          ),
          const SizedBox(height: Dimensiones.espaciadoSm),
          Text(
            'Despues del envio no podras modificar respuestas.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: Colores.textoTerciario,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaResumen extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool advertencia;

  const _FilaResumen({
    required this.etiqueta,
    required this.valor,
    this.advertencia = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensiones.espaciadoSm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              etiqueta,
              style: textTheme.bodyMedium?.copyWith(
                color: Colores.textoSecundario,
              ),
            ),
          ),
          Text(
            valor,
            style: textTheme.titleMedium?.copyWith(
              color:
                  advertencia ? Colores.amarilloAlerta : Colores.azulPrimario,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
