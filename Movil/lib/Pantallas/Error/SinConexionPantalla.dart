/// @archivo   SinConexionPantalla.dart
/// @descripcion Informa al estudiante que no hay conectividad disponible temporalmente.
/// @modulo    Pantallas/Error
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

class SinConexionPantalla extends StatelessWidget {
  const SinConexionPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sin conexion')),
      body: const EvalPageBackground(
        child: EvalErrorState(
          title: 'No hay internet disponible',
          message:
              'Revisa la conectividad del dispositivo y vuelve al inicio para continuar.',
          icon: Icons.wifi_off_rounded,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Rutas.inicio),
        icon: const Icon(Icons.home_rounded),
        label: const Text('Volver al inicio'),
      ),
    );
  }
}
