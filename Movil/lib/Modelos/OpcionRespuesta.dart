/// @archivo   OpcionRespuesta.dart
/// @descripcion Modela una opcion de respuesta para preguntas cerradas.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

class OpcionRespuesta {
  final String id;
  final String letra;
  final String contenido;
  final int orden;
  final String preguntaId;
  final bool? esCorrecta;

  const OpcionRespuesta({
    required this.id,
    required this.letra,
    required this.contenido,
    required this.orden,
    required this.preguntaId,
    this.esCorrecta,
  });

  /// Crea una opcion desde un mapa JSON.
  factory OpcionRespuesta.fromJson(Map<String, dynamic> json) {
    return OpcionRespuesta(
      id: json['id'] as String,
      letra: json['letra'] as String,
      contenido: json['contenido'] as String,
      orden: (json['orden'] as num?)?.toInt() ?? 0,
      preguntaId: (json['preguntaId'] as String?) ?? '',
      esCorrecta: json['esCorrecta'] as bool?,
    );
  }

  /// Convierte la opcion a JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'letra': letra,
      'contenido': contenido,
      'orden': orden,
      'preguntaId': preguntaId,
      'esCorrecta': esCorrecta,
    };
  }

  /// Retorna una copia modificada de la opcion.
  OpcionRespuesta copyWith({
    String? id,
    String? letra,
    String? contenido,
    int? orden,
    String? preguntaId,
    bool? esCorrecta,
  }) {
    return OpcionRespuesta(
      id: id ?? this.id,
      letra: letra ?? this.letra,
      contenido: contenido ?? this.contenido,
      orden: orden ?? this.orden,
      preguntaId: preguntaId ?? this.preguntaId,
      esCorrecta: esCorrecta ?? this.esCorrecta,
    );
  }
}
