import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_font.dart';

class AppTypography {
  static TextTheme get textTheme => TextTheme(
        displayLarge: estiloFuenteApp(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.1,
          color: AppColors.slate900,
        ),
        displayMedium: estiloFuenteApp(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          height: 1.15,
          color: AppColors.slate900,
        ),
        displaySmall: estiloFuenteApp(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.2,
          color: AppColors.slate900,
        ),
        headlineLarge: estiloFuenteApp(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.25,
          color: AppColors.slate900,
        ),
        headlineMedium: estiloFuenteApp(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.3,
          color: AppColors.slate900,
        ),
        headlineSmall: estiloFuenteApp(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.3,
          color: AppColors.slate900,
        ),
        titleLarge: estiloFuenteApp(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          height: 1.4,
          color: AppColors.slate900,
        ),
        titleMedium: estiloFuenteApp(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.4,
          color: AppColors.slate900,
        ),
        titleSmall: estiloFuenteApp(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
          color: AppColors.slate600,
        ),
        bodyLarge: estiloFuenteApp(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.6,
          color: AppColors.slate800,
        ),
        bodyMedium: estiloFuenteApp(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.5,
          color: AppColors.slate700,
        ),
        bodySmall: estiloFuenteApp(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.5,
          color: AppColors.slate500,
        ),
        labelLarge: estiloFuenteApp(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.2,
          color: AppColors.slate900,
        ),
        labelMedium: estiloFuenteApp(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.2,
          color: AppColors.slate600,
        ),
        labelSmall: estiloFuenteApp(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.2,
          color: AppColors.slate500,
        ),
      );
}
