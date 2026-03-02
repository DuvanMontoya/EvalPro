/// @archivo   Tema.dart
/// @descripcion Configura la apariencia global de la aplicacion movil.
/// @modulo    Configuracion
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

import '../Constantes/Colores.dart';
import '../Constantes/Dimensiones.dart';

/// Fabrica de tema para EvalPro Movil.
abstract class Tema {
  /// Retorna el ThemeData principal.
  static ThemeData obtenerTema() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colores.azulPrimario,
        primary: Colores.azulPrimario,
        secondary: Colores.azulSecundario,
        error: Colores.rojoError,
        surface: Colores.blanco,
      ),
      scaffoldBackgroundColor: Colores.grisFondo,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        foregroundColor: Colores.blanco,
        backgroundColor: Colores.azulPrimario,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(Dimensiones.alturaBoton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensiones.radioMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colores.blanco,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioMd),
          borderSide: const BorderSide(color: Colores.grisBorde),
        ),
      ),
    );
  }
}
