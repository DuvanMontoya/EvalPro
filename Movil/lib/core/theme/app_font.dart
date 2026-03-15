/**
 * @archivo   app_font.dart
 * @descripcion Centraliza la familia tipografica local para evitar dependencias de red en runtime y pruebas.
 * @modulo    core/theme
 * @autor     EvalPro
 * @fecha     2026-03-15
 */
import 'package:flutter/material.dart';

const String familiaFuenteApp = 'PlusJakartaSans';

TextStyle estiloFuenteApp({
  double? fontSize,
  FontWeight? fontWeight,
  double? letterSpacing,
  double? height,
  Color? color,
}) {
  return TextStyle(
    fontFamily: familiaFuenteApp,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
  );
}
