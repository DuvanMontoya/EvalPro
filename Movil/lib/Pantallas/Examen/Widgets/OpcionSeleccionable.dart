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
  final VoidCallback alPresionar;

  const OpcionSeleccionable({
    super.key,
    required this.etiqueta,
    required this.contenido,
    required this.seleccionada,
    required this.alPresionar,
  });

  /// Construye contenedor interactivo para opcion de respuesta.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alPresionar,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: seleccionada
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionada
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(radius: 14, child: Text(etiqueta)),
            const SizedBox(width: 10),
            Expanded(child: Text(contenido)),
            Icon(seleccionada ? Icons.check_circle : Icons.circle_outlined),
          ],
        ),
      ),
    );
  }
}
