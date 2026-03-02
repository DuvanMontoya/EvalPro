/// @archivo   CuadriculaOMR.dart
/// @descripcion Renderiza la cuadrilla OMR con opciones A/B/C/D/E por pregunta.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

import 'BotonRespuestaOMR.dart';

class CuadriculaOMR extends StatelessWidget {
  static const _letras = <String>['A', 'B', 'C', 'D', 'E'];

  final int totalPreguntas;
  final Map<int, String?> respuestas;
  final void Function(int numeroPregunta, String letra) alSeleccionar;

  const CuadriculaOMR({
    super.key,
    required this.totalPreguntas,
    required this.respuestas,
    required this.alSeleccionar,
  });

  /// Construye filas OMR con selector por pregunta.
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: totalPreguntas,
      itemBuilder: (context, indice) {
        final numero = indice + 1;
        final actual = respuestas[numero];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                SizedBox(
                    width: 36,
                    child: Text('$numero',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _letras.map((letra) {
                      final seleccionada = actual == letra;
                      return BotonRespuestaOMR(
                        letra: letra,
                        seleccionada: seleccionada,
                        alPresionar: () => alSeleccionar(numero, letra),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
