/// @archivo   Dimensiones.dart
/// @descripcion Declara medidas estandar para espaciados, radios y tamanos minimos.
/// @modulo    Constantes
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../core/theme/app_spacing.dart';

/// Dimensiones reutilizables para consistencia visual.
abstract class Dimensiones {
  static const double espaciadoXs = AppSpacing.xs;
  static const double espaciadoSm = AppSpacing.sm;
  static const double espaciadoMd = AppSpacing.md;
  static const double espaciadoLg = AppSpacing.base;
  static const double espaciadoXl = AppSpacing.xl;
  static const double espaciado2xl = AppSpacing.xl2;
  static const double espaciado3xl = AppSpacing.xl3;

  static const double radioSm = AppSpacing.radiusXs;
  static const double radioMd = AppSpacing.radiusSm;
  static const double radioLg = AppSpacing.radiusLg;
  static const double radioXl = AppSpacing.radiusXl;
  static const double radio2xl = AppSpacing.xl2;

  static const double alturaBoton = 56;
  static const double tamanoIcono = 20;
  static const double tamanoMinimoBotonOmar = 44;
  static const double elevacionTarjeta = 0;
}
