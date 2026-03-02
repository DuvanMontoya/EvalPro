/// @archivo   ModoKioscoIOS.dart
/// @descripcion Envoltura de integracion para identificar soporte de modo examen en iOS.
/// @modulo    ModoExamen/iOS
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/foundation.dart';

/// Utilidad para validaciones especificas de iOS.
abstract class ModoKioscoIOS {
  /// Retorna true si la plataforma actual corresponde a iOS.
  static bool esCompatible() => defaultTargetPlatform == TargetPlatform.iOS;
}
