/// @archivo   CampoPreguntaAbierta.dart
/// @descripcion Renderiza un campo multilinea para respuestas abiertas sin copiar/pegar.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

class CampoPreguntaAbierta extends StatefulWidget {
  final String? valorInicial;
  final ValueChanged<String> alCambiar;

  const CampoPreguntaAbierta({
    super.key,
    required this.valorInicial,
    required this.alCambiar,
  });

  @override
  State<CampoPreguntaAbierta> createState() => _CampoPreguntaAbiertaState();
}

class _CampoPreguntaAbiertaState extends State<CampoPreguntaAbierta> {
  late final TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController(text: widget.valorInicial ?? '');
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controlador,
      maxLines: 6,
      contextMenuBuilder: (_, __) => const SizedBox.shrink(),
      enableInteractiveSelection: false,
      onChanged: widget.alCambiar,
      decoration: const InputDecoration(hintText: 'Escribe tu respuesta...'),
    );
  }
}
