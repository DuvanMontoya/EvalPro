/// @archivo   MapaProgreso.dart
/// @descripcion Muestra avance del examen con circulos navegables por pregunta.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

import '../../../Constantes/Colores.dart';

class MapaProgreso extends StatelessWidget {
  final int totalPreguntas;
  final int indiceActual;
  final Set<int> respondidas;
  final bool permitirNavegacion;
  final ValueChanged<int> alSeleccionar;

  const MapaProgreso({
    super.key,
    required this.totalPreguntas,
    required this.indiceActual,
    required this.respondidas,
    required this.permitirNavegacion,
    required this.alSeleccionar,
  });

  /// Construye mapa horizontal con estado visual por pregunta.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalPreguntas,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, indice) {
          final esActual = indice == indiceActual;
          final respondida = respondidas.contains(indice);
          final color = esActual
              ? Colores.azulPrimario
              : respondida
                  ? Colores.verdeExito
                  : Colors.grey;

          return InkWell(
            onTap: permitirNavegacion ? () => alSeleccionar(indice) : null,
            child: CircleAvatar(
              backgroundColor: color,
              radius: 18,
              child: Text('${indice + 1}',
                  style: const TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }
}
