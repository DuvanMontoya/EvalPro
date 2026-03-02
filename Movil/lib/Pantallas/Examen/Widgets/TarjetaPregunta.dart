/// @archivo   TarjetaPregunta.dart
/// @descripcion Renderiza una pregunta segun su tipo y delega guardado de respuesta.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

import '../../../Modelos/Enums/TipoPregunta.dart';
import '../../../Modelos/Pregunta.dart';
import '../../../Modelos/RespuestaLocal.dart';
import 'CampoPreguntaAbierta.dart';
import 'OpcionSeleccionable.dart';

class TarjetaPregunta extends StatelessWidget {
  final Pregunta pregunta;
  final RespuestaLocal? respuesta;
  final ValueChanged<Object> alResponder;

  const TarjetaPregunta({
    super.key,
    required this.pregunta,
    required this.respuesta,
    required this.alResponder,
  });

  /// Construye el contenido de la tarjeta segun tipo de pregunta.
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              pregunta.enunciado,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            _construirEntrada(context),
          ],
        ),
      ),
    );
  }

  Widget _construirEntrada(BuildContext context) {
    switch (pregunta.tipo) {
      case TipoPregunta.OPCION_MULTIPLE:
        return _opcionesUnicas();
      case TipoPregunta.SELECCION_MULTIPLE:
        return _opcionesMultiples();
      case TipoPregunta.RESPUESTA_ABIERTA:
        return CampoPreguntaAbierta(
          valorInicial: respuesta?.valorTexto,
          alCambiar: (texto) => alResponder(texto),
        );
      case TipoPregunta.VERDADERO_FALSO:
        return _verdaderoFalso(context);
    }
  }

  Widget _opcionesUnicas() {
    final seleccionada = (respuesta?.opcionesSeleccionadas.isNotEmpty ?? false)
        ? respuesta!.opcionesSeleccionadas.first
        : null;
    return Column(
      children: pregunta.opciones.map((opcion) {
        return OpcionSeleccionable(
          etiqueta: opcion.letra,
          contenido: opcion.contenido,
          seleccionada: opcion.letra == seleccionada,
          alPresionar: () => alResponder(opcion.letra),
        );
      }).toList(),
    );
  }

  Widget _opcionesMultiples() {
    final seleccionadas = respuesta?.opcionesSeleccionadas ?? <String>[];
    return Column(
      children: pregunta.opciones.map((opcion) {
        final activa = seleccionadas.contains(opcion.letra);
        return OpcionSeleccionable(
          etiqueta: opcion.letra,
          contenido: opcion.contenido,
          seleccionada: activa,
          alPresionar: () {
            final nuevas = List<String>.from(seleccionadas);
            if (activa) {
              nuevas.remove(opcion.letra);
            } else {
              nuevas.add(opcion.letra);
            }
            alResponder(nuevas);
          },
        );
      }).toList(),
    );
  }

  Widget _verdaderoFalso(BuildContext context) {
    final seleccionada = (respuesta?.opcionesSeleccionadas.isNotEmpty ?? false)
        ? respuesta!.opcionesSeleccionadas.first
        : null;
    final opciones = pregunta.opciones.isEmpty
        ? <Map<String, String>>[
            <String, String>{'letra': 'A', 'contenido': 'Verdadero'},
            <String, String>{'letra': 'B', 'contenido': 'Falso'},
          ]
        : pregunta.opciones
            .map((opcion) => <String, String>{
                  'letra': opcion.letra,
                  'contenido': opcion.contenido
                })
            .toList();

    return Row(
      children: opciones.map((opcion) {
        final esActual = opcion['letra'] == seleccionada;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: ElevatedButton(
              onPressed: () => alResponder(opcion['letra']!),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 52),
                backgroundColor:
                    esActual ? Theme.of(context).colorScheme.primary : null,
              ),
              child: Text(opcion['contenido']!),
            ),
          ),
        );
      }).toList(),
    );
  }
}
