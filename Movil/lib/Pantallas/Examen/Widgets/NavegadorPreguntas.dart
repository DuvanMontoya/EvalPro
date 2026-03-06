/// @archivo   NavegadorPreguntas.dart
/// @descripcion Ofrece botones de navegacion anterior/siguiente en examen digital.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavegadorPreguntas extends StatelessWidget {
  final bool mostrarAnterior;
  final bool esUltima;
  final VoidCallback? alAnterior;
  final VoidCallback alSiguiente;

  const NavegadorPreguntas({
    super.key,
    required this.mostrarAnterior,
    required this.esUltima,
    required this.alAnterior,
    required this.alSiguiente,
  });

  /// Construye navegacion inferior para avanzar o retroceder preguntas.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (mostrarAnterior)
          Expanded(
            child: OutlinedButton(
              key: const Key('exam_previous_button'),
              onPressed: alAnterior == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      alAnterior!.call();
                    },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Anterior'),
            ),
          ),
        if (mostrarAnterior) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            key: const Key('exam_next_button'),
            onPressed: () {
              HapticFeedback.selectionClick();
              alSiguiente();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(esUltima ? 'Revisar y Enviar' : 'Siguiente'),
          ),
        ),
      ],
    );
  }
}
