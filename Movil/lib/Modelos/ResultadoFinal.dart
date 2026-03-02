/// @archivo   ResultadoFinal.dart
/// @descripcion Modela el resultado final devuelto al finalizar un intento.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

class ResultadoFinal {
  final String idIntento;
  final bool mostrarPuntaje;
  final double? puntajeObtenido;
  final double? porcentaje;

  const ResultadoFinal({
    required this.idIntento,
    required this.mostrarPuntaje,
    required this.puntajeObtenido,
    required this.porcentaje,
  });

  /// Construye resultado final desde JSON.
  factory ResultadoFinal.fromJson(Map<String, dynamic> json) {
    return ResultadoFinal(
      idIntento: json['idIntento'] as String,
      mostrarPuntaje: json['mostrarPuntaje'] as bool,
      puntajeObtenido: (json['puntajeObtenido'] as num?)?.toDouble(),
      porcentaje: (json['porcentaje'] as num?)?.toDouble(),
    );
  }

  /// Convierte resultado final a JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'idIntento': idIntento,
      'mostrarPuntaje': mostrarPuntaje,
      'puntajeObtenido': puntajeObtenido,
      'porcentaje': porcentaje,
    };
  }
}
