/// @archivo   TemporizadorExamen.dart
/// @descripcion Implementa cuenta regresiva MM:SS con alertas por umbral y envio automatico.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../Constantes/Colores.dart';

class TemporizadorExamen extends StatefulWidget {
  final int duracionMinutos;
  final VoidCallback alFinalizar;

  const TemporizadorExamen({
    super.key,
    required this.duracionMinutos,
    required this.alFinalizar,
  });

  @override
  State<TemporizadorExamen> createState() => _TemporizadorExamenState();
}

class _TemporizadorExamenState extends State<TemporizadorExamen> {
  Timer? _timer;
  late int _segundosRestantes;
  bool _alertoCinco = false;
  bool _alertoUno = false;

  @override
  void initState() {
    super.initState();
    _segundosRestantes = widget.duracionMinutos * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_segundosRestantes <= 0) {
        _timer?.cancel();
        widget.alFinalizar();
        return;
      }
      setState(() => _segundosRestantes -= 1);
      _emitirAlertas();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _emitirAlertas() {
    if (_segundosRestantes <= 300 && !_alertoCinco) {
      _alertoCinco = true;
      HapticFeedback.lightImpact();
    }
    if (_segundosRestantes <= 60 && !_alertoUno) {
      _alertoUno = true;
      HapticFeedback.lightImpact();
    }
  }

  Color _obtenerColor() {
    final total = widget.duracionMinutos * 60;
    final porcentaje = _segundosRestantes / total;
    if (porcentaje <= 0.10) return Colores.rojoError;
    if (porcentaje <= 0.20) return Colores.amarilloAlerta;
    return Colores.verdeExito;
  }

  @override
  Widget build(BuildContext context) {
    final minutos = (_segundosRestantes ~/ 60).toString().padLeft(2, '0');
    final segundos = (_segundosRestantes % 60).toString().padLeft(2, '0');

    return Text(
      '$minutos:$segundos',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: _obtenerColor(),
        fontSize: 18,
      ),
    );
  }
}
