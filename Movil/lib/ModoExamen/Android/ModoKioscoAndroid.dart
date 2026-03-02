/// @archivo   ModoKioscoAndroid.dart
/// @descripcion Envoltura de integracion para identificar soporte de modo kiosco en Android.
/// @modulo    ModoExamen/Android
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/foundation.dart';

/// Utilidad para validaciones especificas de Android.
abstract class ModoKioscoAndroid {
  /// Retorna true si la plataforma actual corresponde a Android.
  static bool esCompatible() => defaultTargetPlatform == TargetPlatform.android;
}
