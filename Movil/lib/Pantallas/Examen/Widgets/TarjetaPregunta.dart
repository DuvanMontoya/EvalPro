/// @archivo   TarjetaPregunta.dart
/// @descripcion Renderiza una pregunta segun su tipo y delega guardado de respuesta.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../Modelos/Enums/TipoPregunta.dart';
import '../../../Modelos/Pregunta.dart';
import '../../../Modelos/RespuestaLocal.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common/eval_badge.dart';
import '../../../core/widgets/common/eval_surface.dart';
import 'CampoPreguntaAbierta.dart';
import 'OpcionSeleccionable.dart';

class TarjetaPregunta extends StatelessWidget {
  const TarjetaPregunta({
    super.key,
    required this.pregunta,
    required this.respuesta,
    required this.alResponder,
    this.indiceActual,
    this.totalPreguntas,
  });

  final Pregunta pregunta;
  final RespuestaLocal? respuesta;
  final ValueChanged<Object> alResponder;
  final int? indiceActual;
  final int? totalPreguntas;

  @override
  Widget build(BuildContext context) {
    return EvalSectionCard(
      key: ValueKey<String>('exam_question_card_${pregunta.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (indiceActual != null && totalPreguntas != null) ...<Widget>[
            Row(
              children: <Widget>[
                EvalBadge(
                  'Pregunta $indiceActual de $totalPreguntas',
                  variant: EvalBadgeVariant.primary,
                ),
                const SizedBox(width: 8),
                EvalBadge(
                  pregunta.tipo.name.replaceAll('_', ' '),
                  variant: EvalBadgeVariant.neutral,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Text(
            pregunta.enunciado,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Responde con atencion. Cada cambio se guarda durante el intento.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate500,
                ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: _construirEntrada(context),
            ),
          ),
        ],
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
          key: ValueKey<String>('campo-abierto-${pregunta.id}'),
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
          clavePrueba:
              ValueKey<String>('exam_option_${pregunta.id}_${opcion.letra}'),
          etiqueta: opcion.letra,
          contenido: opcion.contenido,
          seleccionada: opcion.letra == seleccionada,
          seleccionMultiple: false,
          alPresionar: () => _responderConFeedback(opcion.letra),
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
          clavePrueba:
              ValueKey<String>('exam_option_${pregunta.id}_${opcion.letra}'),
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
            _responderConFeedback(nuevas);
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
                  'contenido': opcion.contenido,
                })
            .toList();

    return Row(
      children: opciones.map((opcion) {
        final esActual = opcion['letra'] == seleccionada;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: esActual
                ? FilledButton(
                    key: ValueKey<String>(
                      'exam_option_${pregunta.id}_${opcion['letra']}',
                    ),
                    onPressed: () => _responderConFeedback(opcion['letra']!),
                    child: Text(opcion['contenido']!),
                  )
                : OutlinedButton(
                    key: ValueKey<String>(
                      'exam_option_${pregunta.id}_${opcion['letra']}',
                    ),
                    onPressed: () => _responderConFeedback(opcion['letra']!),
                    child: Text(opcion['contenido']!),
                  ),
          ),
        );
      }).toList(),
    );
  }

  void _responderConFeedback(Object respuesta) {
    HapticFeedback.selectionClick();
    alResponder(respuesta);
  }
}
