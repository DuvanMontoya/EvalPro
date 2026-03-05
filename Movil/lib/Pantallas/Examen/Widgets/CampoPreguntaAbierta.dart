/// @archivo   CampoPreguntaAbierta.dart
/// @descripcion Renderiza un campo multilinea para respuestas abiertas sin copiar/pegar.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'dart:async';

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
  late final FocusNode _focusNode;
  Timer? _temporizadorGuardado;
  String _ultimoValorEmitido = '';

  static const _duracionDebounce = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    final inicial = widget.valorInicial ?? '';
    _controlador = TextEditingController(text: inicial);
    _focusNode = FocusNode();
    _ultimoValorEmitido = inicial;
    _focusNode.addListener(_alCambiarFoco);
  }

  @override
  void didUpdateWidget(covariant CampoPreguntaAbierta oldWidget) {
    super.didUpdateWidget(oldWidget);
    final valorActualizado = widget.valorInicial ?? '';
    if (valorActualizado == _controlador.text) {
      return;
    }

    _temporizadorGuardado?.cancel();
    _controlador.value = TextEditingValue(
      text: valorActualizado,
      selection: TextSelection.collapsed(offset: valorActualizado.length),
    );
    _ultimoValorEmitido = valorActualizado;
  }

  void _alCambiarFoco() {
    if (_focusNode.hasFocus) {
      return;
    }
    _emitirSiCambio();
  }

  void _programarEmision(String valor) {
    _temporizadorGuardado?.cancel();
    _temporizadorGuardado = Timer(_duracionDebounce, _emitirSiCambio);
  }

  void _emitirSiCambio() {
    final valor = _controlador.text;
    if (valor == _ultimoValorEmitido) {
      return;
    }
    _ultimoValorEmitido = valor;
    widget.alCambiar(valor);
  }

  @override
  void dispose() {
    _temporizadorGuardado?.cancel();
    _emitirSiCambio();
    _focusNode
      ..removeListener(_alCambiarFoco)
      ..dispose();
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controlador,
      focusNode: _focusNode,
      maxLines: 6,
      contextMenuBuilder: (_, __) => const SizedBox.shrink(),
      enableInteractiveSelection: false,
      onChanged: _programarEmision,
      onSubmitted: (_) => _emitirSiCambio(),
      decoration: const InputDecoration(hintText: 'Escribe tu respuesta...'),
    );
  }
}
