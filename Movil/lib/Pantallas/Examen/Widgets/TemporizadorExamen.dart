/// @archivo   TemporizadorExamen.dart
/// @descripcion Implementa cuenta regresiva MM:SS con alertas por umbral y envio automatico.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

class TemporizadorExamen extends StatefulWidget {
  const TemporizadorExamen({
    super.key,
    required this.duracionMinutos,
    required this.alFinalizar,
  });

  final int duracionMinutos;
  final VoidCallback alFinalizar;

  @override
  State<TemporizadorExamen> createState() => _TemporizadorExamenState();
}

class _TemporizadorExamenState extends State<TemporizadorExamen> {
  Timer? _timer;
  late int _segundosRestantes;
  late bool _sinLimite;
  bool _alertoCinco = false;
  bool _alertoUno = false;

  @override
  void initState() {
    super.initState();
    _sinLimite = widget.duracionMinutos <= 0;
    _segundosRestantes = widget.duracionMinutos * 60;
    if (_sinLimite) {
      return;
    }
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
    if (_sinLimite || total <= 0) {
      return AppColors.success;
    }
    final porcentaje = _segundosRestantes / total;
    if (porcentaje <= 0.10) return AppColors.error;
    if (porcentaje <= 0.20) return AppColors.warning;
    return AppColors.primary;
  }

  Color _obtenerFondo(Color color) {
    return color.withValues(alpha: 0.12);
  }

  @override
  Widget build(BuildContext context) {
    final color = _obtenerColor();
    final texto = _sinLimite ? 'Sin limite' : _formatearTiempo();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _obtenerFondo(color),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compacto = constraints.maxWidth.isFinite && constraints.maxWidth < 92;
          final textoVisible = compacto && _sinLimite ? 'Libre' : texto;
          final estilo = (compacto
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).textTheme.titleMedium)
              ?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              );

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!compacto) ...<Widget>[
                Icon(Icons.timer_outlined, size: 18, color: color),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  textoVisible,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: estilo,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatearTiempo() {
    final minutos = (_segundosRestantes ~/ 60).toString().padLeft(2, '0');
    final segundos = (_segundosRestantes % 60).toString().padLeft(2, '0');
    return '$minutos:$segundos';
  }
}
