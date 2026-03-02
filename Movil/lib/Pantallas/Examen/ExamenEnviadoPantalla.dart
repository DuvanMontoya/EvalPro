/// @archivo   ExamenEnviadoPantalla.dart
/// @descripcion Confirma envio exitoso del examen y muestra puntaje cuando aplica.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/ResultadoFinal.dart';

class ExamenEnviadoPantalla extends StatelessWidget {
  const ExamenEnviadoPantalla({super.key});

  /// Construye pantalla de confirmacion posterior al envio final.
  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final resultado = extra is ResultadoFinal ? extra : null;

    return Scaffold(
      appBar: AppBar(title: const Text(Textos.examenEnviado)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.check_circle, size: 72, color: Colors.green),
              const SizedBox(height: 16),
              const Text('Tu examen fue enviado correctamente.'),
              const SizedBox(height: 12),
              if (resultado != null && resultado.mostrarPuntaje) ...<Widget>[
                Text('Puntaje: ${resultado.puntajeObtenido ?? 0}'),
                Text('Porcentaje: ${resultado.porcentaje ?? 0}%'),
              ] else
                const Text(Textos.examenSinPuntaje),
              const SizedBox(height: 18),
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
