/// @archivo   SesionInvalidadaPantalla.dart
/// @descripcion Notifica que la sesion fue invalidada por evento critico de fraude.
/// @modulo    Pantallas/Error
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';

class SesionInvalidadaPantalla extends StatelessWidget {
  const SesionInvalidadaPantalla({super.key});

  /// Construye vista de sesion invalidada.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sesion invalidada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.gpp_bad, size: 56),
              const SizedBox(height: 16),
              const Text('Tu intento fue invalidado. Contacta al docente.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(Rutas.inicio),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
