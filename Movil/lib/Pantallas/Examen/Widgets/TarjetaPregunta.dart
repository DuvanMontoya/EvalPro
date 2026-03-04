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
  final int? indiceActual;
  final int? totalPreguntas;

  const TarjetaPregunta({
    super.key,
    required this.pregunta,
    required this.respuesta,
    required this.alResponder,
    this.indiceActual,
    this.totalPreguntas,
  });

  /// Construye el contenido de la tarjeta segun tipo de pregunta.
  @override
  Widget build(BuildContext context) {
    final colorPrimario = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (indiceActual != null && totalPreguntas != null) ...<Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorPrimario.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Pregunta $indiceActual de $totalPreguntas',
                  style: TextStyle(
                    color: colorPrimario,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              pregunta.enunciado,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: _construirEntrada(context),
              ),
            ),
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
          seleccionMultiple: false,
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
          seleccionMultiple: true,
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
