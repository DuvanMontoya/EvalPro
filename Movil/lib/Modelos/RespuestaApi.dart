/// @archivo   RespuestaApi.dart
/// @descripcion Representa el sobre estandar de respuestas del backend EvalPro.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

class RespuestaApi<T> {
  final bool exito;
  final T? datos;
  final String mensaje;
  final String? codigoError;
  final String marcaTiempo;

  const RespuestaApi({
    required this.exito,
    required this.datos,
    required this.mensaje,
    required this.codigoError,
    required this.marcaTiempo,
  });

  /// Crea una respuesta API mapeando los datos con el parseador recibido.
  factory RespuestaApi.fromJson(
    Map<String, dynamic> json,
    T Function(Object? valor) mapear,
  ) {
    return RespuestaApi<T>(
      exito: (json['exito'] as bool?) ?? false,
      datos: mapear(json['datos']),
      mensaje: (json['mensaje'] as String?) ?? '',
      codigoError: json['codigoError'] as String?,
      marcaTiempo: (json['marcaTiempo'] as String?) ?? '',
    );
  }
}
