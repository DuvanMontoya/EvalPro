/// @archivo   CuadriculaOMR.dart
/// @descripcion Renderiza la cuadrilla OMR con opciones A/B/C/D/E por pregunta.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

import 'BotonRespuestaOMR.dart';

class OpcionOmr {
  final String valor;
  final String etiqueta;

  const OpcionOmr({
    required this.valor,
    required this.etiqueta,
  });
}

class CuadriculaOMR extends StatelessWidget {
  static const _opciones = <OpcionOmr>[
    OpcionOmr(valor: 'A', etiqueta: 'A'),
    OpcionOmr(valor: 'B', etiqueta: 'B'),
    OpcionOmr(valor: 'C', etiqueta: 'C'),
    OpcionOmr(valor: 'D', etiqueta: 'D'),
    OpcionOmr(valor: 'E', etiqueta: 'No lo sé'),
  ];

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
                    children: _opciones.map((opcion) {
                      final seleccionada = actual == opcion.valor;
                      return BotonRespuestaOMR(
                        valor: opcion.valor,
                        etiqueta: opcion.etiqueta,
                        seleccionada: seleccionada,
                        alPresionar: () => alSeleccionar(numero, opcion.valor),
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
