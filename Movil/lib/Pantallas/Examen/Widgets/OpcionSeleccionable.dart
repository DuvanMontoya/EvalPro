/// @archivo   OpcionSeleccionable.dart
/// @descripcion Muestra una opcion seleccionable para preguntas de seleccion unica o multiple.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

class OpcionSeleccionable extends StatelessWidget {
  final String etiqueta;
  final String contenido;
  final bool seleccionada;
  final bool seleccionMultiple;
  final VoidCallback alPresionar;

  const OpcionSeleccionable({
    super.key,
    required this.etiqueta,
    required this.contenido,
    required this.seleccionada,
    this.seleccionMultiple = false,
    required this.alPresionar,
  });

  /// Construye contenedor interactivo para opcion de respuesta.
  @override
  Widget build(BuildContext context) {
    final colorPrimario = Theme.of(context).colorScheme.primary;
    final colorBorde = seleccionada ? colorPrimario : Colors.grey.shade300;
    final colorFondo =
        seleccionada ? colorPrimario.withValues(alpha: 0.11) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: alPresionar,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minHeight: 62),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorFondo,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorBorde),
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: colorPrimario.withValues(alpha: 0.16),
                  child: Text(
                    etiqueta,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorPrimario,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    contenido,
                    style: const TextStyle(fontSize: 17, height: 1.2),
                  ),
                ),
                Icon(
                  seleccionMultiple
                      ? (seleccionada
                          ? Icons.check_box
                          : Icons.check_box_outline_blank)
                      : (seleccionada
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off),
                  color: seleccionada ? colorPrimario : Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
