/// @archivo   RespuestaPendienteCalificacion.dart
/// @descripcion Modela respuestas abiertas pendientes de calificacion manual.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-03

class RespuestaPendienteCalificacion {
  final String id;
  final String idIntento;
  final String idPregunta;
  final String? valorTexto;
  final List<String> opcionesSeleccionadas;
  final DateTime? guardadoEn;
  final int? tiempoRespuesta;
  final String enunciadoPregunta;
  final double puntajeMaximo;
  final String estudianteId;
  final String estudianteNombreCompleto;
  final String estudianteCorreo;
  final String sesionId;
  final String? codigoSesion;
  final String? tituloExamen;

  const RespuestaPendienteCalificacion({
    required this.id,
    required this.idIntento,
    required this.idPregunta,
    required this.valorTexto,
    required this.opcionesSeleccionadas,
    required this.guardadoEn,
    required this.tiempoRespuesta,
    required this.enunciadoPregunta,
    required this.puntajeMaximo,
    required this.estudianteId,
    required this.estudianteNombreCompleto,
    required this.estudianteCorreo,
    required this.sesionId,
    required this.codigoSesion,
    required this.tituloExamen,
  });

  factory RespuestaPendienteCalificacion.fromJson(Map<String, dynamic> json) {
    final pregunta =
        json['pregunta'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final estudiante =
        json['estudiante'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final sesion =
        json['sesion'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final examen =
        sesion['examen'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final nombre = (estudiante['nombre'] as String?) ?? '';
    final apellidos = (estudiante['apellidos'] as String?) ?? '';
    return RespuestaPendienteCalificacion(
      id: json['id'] as String,
      idIntento: (json['idIntento'] as String?) ?? '',
      idPregunta: (json['idPregunta'] as String?) ?? '',
      valorTexto: json['valorTexto'] as String?,
      opcionesSeleccionadas:
          (json['opcionesSeleccionadas'] as List<dynamic>? ?? <dynamic>[])
              .map((dato) => dato.toString())
              .toList(),
      guardadoEn: _parsearFecha(json['guardadoEn']),
      tiempoRespuesta: (json['tiempoRespuesta'] as num?)?.toInt(),
      enunciadoPregunta: (pregunta['enunciado'] as String?) ?? '',
      puntajeMaximo: (pregunta['puntaje'] as num?)?.toDouble() ?? 0,
      estudianteId: (estudiante['id'] as String?) ?? '',
      estudianteNombreCompleto: '$nombre $apellidos'.trim(),
      estudianteCorreo: (estudiante['correo'] as String?) ?? '',
      sesionId: (sesion['id'] as String?) ?? '',
      codigoSesion: sesion['codigoAcceso'] as String?,
      tituloExamen: examen['titulo'] as String?,
    );
  }
}

DateTime? _parsearFecha(Object? valor) {
  final texto = valor as String?;
  if (texto == null || texto.isEmpty) {
    return null;
  }
  return DateTime.tryParse(texto);
}
