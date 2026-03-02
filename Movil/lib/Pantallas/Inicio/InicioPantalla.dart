/// @archivo   InicioPantalla.dart
/// @descripcion Muestra accesos principales para unirse a sesiones y cerrar sesion.
/// @modulo    Pantallas/Inicio
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Providers/AutenticacionProvider.dart';

class InicioPantalla extends ConsumerWidget {
  const InicioPantalla({super.key});

  /// Construye panel de inicio para estudiante autenticado.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(autenticacionEstadoProvider).usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.inicio),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await ref
                  .read(autenticacionEstadoProvider.notifier)
                  .cerrarSesion();
              if (context.mounted) context.go(Rutas.iniciarSesion);
            },
            icon: const Icon(Icons.logout),
            tooltip: Textos.cerrarSesion,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Hola, ${usuario?.nombre ?? ''}',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => context.go(Rutas.unirseExamen),
                icon: const Icon(Icons.how_to_reg),
                label: const Text('Unirse a una sesion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
