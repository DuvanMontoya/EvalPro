/// @archivo   Colores.dart
/// @descripcion Centraliza la paleta de colores usada por la app movil.
/// @modulo    Constantes
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Colores institucionales y estados visuales de EvalPro.
abstract class Colores {
  static const azulPrimario = AppColors.primary;
  static const azulSecundario = AppColors.primaryLight;
  static const azulProfundo = AppColors.primaryDark;
  static const turquesaAcento = AppColors.info;

  static const verdeExito = AppColors.success;
  static const amarilloAlerta = AppColors.warning;
  static const rojoError = AppColors.error;

  static const grisFondo = AppColors.background;
  static const grisFondoSecundario = AppColors.surfaceVariant;
  static const grisBorde = AppColors.border;
  static const grisBordeFuerte = AppColors.primaryBorder;

  static const blanco = AppColors.surface;
  static const negro = AppColors.slate900;
  static const sombra = Color(0x14101A2B);

  static const textoPrincipal = AppColors.onSurface;
  static const textoSecundario = AppColors.slate600;
  static const textoTerciario = AppColors.slate500;
}
