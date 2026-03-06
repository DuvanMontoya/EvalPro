/// @archivo   NavegadorPreguntas.dart
/// @descripcion Ofrece botones de navegacion anterior/siguiente en examen digital.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavegadorPreguntas extends StatelessWidget {
  const NavegadorPreguntas({
    super.key,
    required this.mostrarAnterior,
    required this.esUltima,
    required this.alAnterior,
    required this.alSiguiente,
  });

  final bool mostrarAnterior;
  final bool esUltima;
  final VoidCallback? alAnterior;
  final VoidCallback alSiguiente;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
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
                child: const Text('Anterior'),
              ),
            ),
          if (mostrarAnterior) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              key: const Key('exam_next_button'),
              onPressed: () {
                HapticFeedback.selectionClick();
                alSiguiente();
              },
              child: Text(esUltima ? 'Revisar y enviar' : 'Siguiente'),
            ),
          ),
        ],
      ),
    );
  }
}
