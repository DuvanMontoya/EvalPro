/// @archivo   IniciarSesionPantalla.dart
/// @descripcion Renderiza la pantalla de autenticacion del estudiante.
/// @modulo    Pantallas/Autenticacion
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Providers/AutenticacionProvider.dart';
import 'Widgets/FormularioLogin.dart';

class IniciarSesionPantalla extends ConsumerWidget {
  const IniciarSesionPantalla({super.key});

  /// Construye la pantalla de login y escucha cambios de autenticacion.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(autenticacionEstadoProvider);

    ref.listen(autenticacionEstadoProvider, (anterior, actual) {
      if (actual.estaAutenticado) {
        context.go(Rutas.inicio);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              margin: const EdgeInsets.all(Dimensiones.espaciadoLg),
              child: Padding(
                padding: const EdgeInsets.all(Dimensiones.espaciadoXl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(Textos.iniciarSesion,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: Dimensiones.espaciadoXl),
                    const FormularioLogin(),
                    if (estado.error != null) ...<Widget>[
                      const SizedBox(height: Dimensiones.espaciadoMd),
                      Text(estado.error!,
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
