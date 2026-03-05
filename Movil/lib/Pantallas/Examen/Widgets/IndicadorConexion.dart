/// @archivo   IndicadorConexion.dart
/// @descripcion Muestra estado de red con transicion suave durante el examen.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Constantes/Colores.dart';
import '../../../Providers/ConectividadProvider.dart';

class IndicadorConexion extends ConsumerWidget {
  const IndicadorConexion({super.key});

  /// Construye banner de conectividad segun estado de red actual.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conectado = ref.watch(conectividadEstadoProvider);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: conectado
            ? Colores.verdeExito.withValues(alpha: 0.12)
            : Colores.amarilloAlerta.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            conectado ? Icons.wifi : Icons.wifi_off,
            color: conectado ? Colores.verdeExito : Colores.amarilloAlerta,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            conectado ? 'En linea' : 'Sin red',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
