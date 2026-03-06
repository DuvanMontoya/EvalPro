/// @archivo   MapaProgreso.dart
/// @descripcion Muestra avance del examen con circulos navegables por pregunta.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MapaProgreso extends StatelessWidget {
  const MapaProgreso({
    super.key,
    required this.totalPreguntas,
    required this.indiceActual,
    required this.respondidas,
    required this.permitirNavegacion,
    required this.alSeleccionar,
  });

  final int totalPreguntas;
  final int indiceActual;
  final Set<int> respondidas;
  final bool permitirNavegacion;
  final ValueChanged<int> alSeleccionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalPreguntas,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, indice) {
          final esActual = indice == indiceActual;
          final respondida = respondidas.contains(indice);
          final color = esActual
              ? AppColors.primary
              : respondida
                  ? AppColors.success
                  : AppColors.slate300;
          final texto = esActual || respondida ? Colors.white : AppColors.slate600;

          return InkWell(
            onTap: permitirNavegacion ? () => alSeleccionar(indice) : null,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: esActual ? 54 : 42,
              decoration: BoxDecoration(
                color: esActual
                    ? color
                    : respondida
                        ? color.withValues(alpha: 0.88)
                        : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color, width: esActual ? 0 : 1.4),
                boxShadow: esActual
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${indice + 1}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: texto,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
