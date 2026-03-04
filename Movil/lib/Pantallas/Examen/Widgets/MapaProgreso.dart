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
      height: 56,
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
                  : Colors.grey.shade400;
          final colorTexto =
              esActual || respondida ? Colors.white : Colors.black54;

          return InkWell(
            onTap: permitirNavegacion ? () => alSeleccionar(indice) : null,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: esActual
                    ? color
                    : color.withValues(alpha: respondida ? 1 : 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: esActual ? 2 : 1),
              ),
              child: Center(
                child: Text(
                  '${indice + 1}',
                  style:
                      TextStyle(color: colorTexto, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
