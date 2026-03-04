/// @archivo   ExamenEnviadoPantalla.dart
/// @descripcion Confirma envio exitoso del examen y muestra puntaje cuando aplica.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Colores.dart';
import '../../Constantes/Dimensiones.dart';
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(Textos.examenEnviado)),
      body: ListView(
        padding: const EdgeInsets.all(Dimensiones.espaciadoLg),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Dimensiones.espaciadoXl),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colores.verdeExito.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(42),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 54,
                      color: Colores.verdeExito,
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  Text(
                    'Tu examen fue enviado correctamente',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoSm),
                  Text(
                    'El intento quedo registrado en la plataforma.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: Dimensiones.espaciadoXl),
                  if (resultado != null &&
                      resultado.mostrarPuntaje) ...<Widget>[
                    _DatoResultado(
                      etiqueta: 'Puntaje',
                      valor: '${resultado.puntajeObtenido ?? 0}',
                    ),
                    _DatoResultado(
                      etiqueta: 'Porcentaje',
                      valor: '${resultado.porcentaje ?? 0}%',
                    ),
                  ] else
                    const Text(Textos.examenSinPuntaje),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(Rutas.inicio),
                      child: const Text('Volver al inicio'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoResultado extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _DatoResultado({
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensiones.espaciadoSm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              etiqueta,
              style: textTheme.bodyMedium?.copyWith(
                color: Colores.textoSecundario,
              ),
            ),
          ),
          Text(
            valor,
            style: textTheme.titleMedium?.copyWith(
              color: Colores.azulPrimario,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
