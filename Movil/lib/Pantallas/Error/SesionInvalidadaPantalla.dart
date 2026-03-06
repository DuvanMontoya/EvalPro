/// @archivo   SesionInvalidadaPantalla.dart
/// @descripcion Notifica que la sesion fue invalidada por evento critico de fraude.
/// @modulo    Pantallas/Error
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

class SesionInvalidadaPantalla extends StatelessWidget {
  const SesionInvalidadaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sesion invalidada')),
      body: const EvalPageBackground(
        child: EvalErrorState(
          title: 'Tu intento fue invalidado',
          message:
              'Se detecto un evento critico durante la sesion. Contacta al docente o a la institucion para revisar el caso.',
          icon: Icons.gpp_bad_rounded,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Rutas.inicio),
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text('Ir al inicio'),
      ),
    );
  }
}
