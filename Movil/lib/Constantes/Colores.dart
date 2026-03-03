/// @archivo   Colores.dart
/// @descripcion Centraliza la paleta de colores usada por la app movil.
/// @modulo    Constantes
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';

/// Colores institucionales y estados visuales de EvalPro.
abstract class Colores {
  static const azulPrimario = Color(0xFF1A56DB);
  static const azulSecundario = Color(0xFF4F8DF8);
  static const azulProfundo = Color(0xFF0B1B3B);
  static const turquesaAcento = Color(0xFF0EA5A2);

  static const verdeExito = Color(0xFF0F9F6E);
  static const amarilloAlerta = Color(0xFFD49707);
  static const rojoError = Color(0xFFB42318);

  static const grisFondo = Color(0xFFF2F5FA);
  static const grisFondoSecundario = Color(0xFFE7EDF7);
  static const grisBorde = Color(0xFFD7E0ED);
  static const grisBordeFuerte = Color(0xFFB8C7DC);

  static const blanco = Color(0xFFFFFFFF);
  static const negro = Color(0xFF111827);
  static const sombra = Color(0x1A10203C);

  static const textoPrincipal = Color(0xFF102A43);
  static const textoSecundario = Color(0xFF3E5671);
  static const textoTerciario = Color(0xFF64748B);
}
