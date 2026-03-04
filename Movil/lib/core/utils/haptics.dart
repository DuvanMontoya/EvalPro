import 'package:flutter/services.dart';

/// Centralized haptic-feedback helpers.
///
/// Wrap [HapticFeedback] calls so every interaction point uses the same
/// abstraction.  This makes it trivial to disable haptics globally or swap
/// the underlying implementation (e.g., on web).
abstract final class Haptics {
  /// Light tap — buttons, toggles.
  static void light() => HapticFeedback.lightImpact();

  /// Medium tap — pull-to-refresh, timer warnings.
  static void medium() => HapticFeedback.mediumImpact();

  /// Heavy tap — destructive or critical actions.
  static void heavy() => HapticFeedback.heavyImpact();

  /// Selection click — tab switch, option pick.
  static void selection() => HapticFeedback.selectionClick();
}
