/// @archivo   SesionAutenticada.dart
/// @descripcion Agrupa tokens JWT y datos del usuario autenticado.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'Usuario.dart';

class SesionAutenticada {
  final String tokenAcceso;
  final String tokenRefresh;
  final Usuario usuario;

  const SesionAutenticada({
    required this.tokenAcceso,
    required this.tokenRefresh,
    required this.usuario,
  });

  /// Crea la sesion desde JSON.
  factory SesionAutenticada.fromJson(Map<String, dynamic> json) {
    return SesionAutenticada(
      tokenAcceso: json['tokenAcceso'] as String,
      tokenRefresh: json['tokenRefresh'] as String,
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }

  /// Convierte el modelo a JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tokenAcceso': tokenAcceso,
      'tokenRefresh': tokenRefresh,
      'usuario': usuario.toJson(),
    };
  }
}
