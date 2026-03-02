/// @archivo   ValidadorConectividad.dart
/// @descripcion Expone validaciones simples sobre el estado de conectividad.
/// @modulo    Utilidades
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:connectivity_plus/connectivity_plus.dart';

/// Utilidad para evaluar conectividad con reglas del proyecto.
abstract class ValidadorConectividad {
  /// Retorna true si hay al menos una interfaz con acceso potencial a red.
  static bool estaConectado(List<ConnectivityResult> resultados) {
    return resultados.any((resultado) => resultado != ConnectivityResult.none);
  }
}
