import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xl2 = 32.0;
  static const xl3 = 40.0;
  static const xl4 = 48.0;
  static const xl5 = 64.0;

  static const screenH = 16.0;
  static const screenV = 20.0;

  static const radiusXs = 6.0;
  static const radiusSm = 10.0;
  static const radiusMd = 14.0;
  static const radiusLg = 18.0;
  static const radiusXl = 24.0;
  static const radiusFull = 999.0;

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: AppColors.slate900.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: AppColors.slate900.withValues(alpha: 0.03),
          blurRadius: 2,
          offset: const Offset(0, 0),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: AppColors.slate900.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.slate900.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: AppColors.slate900.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.slate900.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowXl => [
        BoxShadow(
          color: AppColors.slate900.withValues(alpha: 0.16),
          blurRadius: 48,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: AppColors.slate900.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowPrimary => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.30),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.15),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
}
