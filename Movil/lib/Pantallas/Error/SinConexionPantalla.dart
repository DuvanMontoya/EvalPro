/// @archivo   SinConexionPantalla.dart
/// @descripcion Informa al estudiante que no hay conectividad disponible temporalmente.
/// @modulo    Pantallas/Error
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';

class SinConexionPantalla extends StatelessWidget {
  const SinConexionPantalla({super.key});

  /// Construye vista de error sin conexion.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sin conexion')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.wifi_off, size: 56),
              const SizedBox(height: 16),
              const Text('No hay internet disponible en este momento.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(Rutas.inicio),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
