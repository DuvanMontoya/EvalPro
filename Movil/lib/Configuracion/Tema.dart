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
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colores.azulPrimario,
      brightness: Brightness.light,
      primary: Colores.azulPrimario,
      secondary: Colores.azulSecundario,
      error: Colores.rojoError,
      surface: Colores.blanco,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colores.grisFondo,
    );
    final baseTextTheme = base.textTheme.apply(
      fontFamily: 'PlusJakartaSans',
      bodyColor: Colores.textoPrincipal,
      displayColor: Colores.textoPrincipal,
    );

    return base.copyWith(
      textTheme: baseTextTheme.copyWith(
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colores.textoPrincipal,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colores.textoPrincipal,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colores.textoPrincipal,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: Colores.textoPrincipal,
          height: 1.35,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: Colores.textoSecundario,
          height: 1.35,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        foregroundColor: Colores.textoPrincipal,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, Dimensiones.alturaBoton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensiones.radioLg),
          ),
          elevation: 0,
          backgroundColor: Colores.azulPrimario,
          foregroundColor: Colores.blanco,
          textStyle: baseTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, Dimensiones.alturaBoton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensiones.radioLg),
          ),
          textStyle: baseTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          backgroundColor: Colores.azulPrimario,
          foregroundColor: Colores.blanco,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, Dimensiones.alturaBoton),
          side: const BorderSide(color: Colores.grisBordeFuerte),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensiones.radioMd),
          ),
          foregroundColor: Colores.textoPrincipal,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colores.blanco,
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: Colores.textoTerciario,
        ),
        floatingLabelStyle: baseTextTheme.bodyMedium?.copyWith(
          color: Colores.azulPrimario,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioLg),
          borderSide: const BorderSide(color: Colores.azulPrimario, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioLg),
          borderSide: const BorderSide(color: Colores.rojoError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioLg),
          borderSide: const BorderSide(color: Colores.rojoError, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensiones.espaciadoLg,
          vertical: Dimensiones.espaciadoLg,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colores.sombra,
        surfaceTintColor: Colors.transparent,
        color: Colores.blanco,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioXl),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colores.azulProfundo,
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: Colores.blanco,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioMd),
        ),
      ),
      dividerColor: Colores.grisBorde,
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioLg),
        ),
        color: WidgetStateProperty.all(Colores.grisFondoSecundario),
        labelStyle: baseTextTheme.bodySmall?.copyWith(
          color: Colores.textoSecundario,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colores.blanco,
        indicatorColor: Colores.azulPrimario.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((estados) {
          final seleccionado = estados.contains(WidgetState.selected);
          return baseTextTheme.labelMedium?.copyWith(
            color: seleccionado ? Colores.azulPrimario : Colores.textoTerciario,
            fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
    );
  }
}
