import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

abstract class Tema {
  static ThemeData obtenerTema() => AppTheme.lightTheme;
}
