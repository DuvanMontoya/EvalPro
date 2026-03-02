/// @archivo   FormateadorFecha.dart
/// @descripcion Convierte fechas en formatos legibles para la interfaz movil.
/// @modulo    Utilidades
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:intl/intl.dart';

/// Funciones de formateo para fecha y hora.
abstract class FormateadorFecha {
  static final DateFormat _formatoFechaHora = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _formatoTiempo = DateFormat('mm:ss');

  /// Formatea fecha y hora completas en estilo latino.
  static String fechaHora(DateTime fecha) => _formatoFechaHora.format(fecha);

  /// Formatea una duracion en minutos/segundos.
  static String minutosSegundos(Duration duracion) {
    final fecha = DateTime.fromMillisecondsSinceEpoch(duracion.inMilliseconds,
        isUtc: true);
    return _formatoTiempo.format(fecha);
  }
}
