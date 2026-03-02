/// @archivo   ExamenActivoEstado.dart
/// @descripcion Define el estado inmutable del examen activo en Riverpod.
/// @modulo    Providers/Modelos
/// @autor     EvalPro
/// @fecha     2026-03-02

import '../../Modelos/Examen.dart';
import '../../Modelos/Pregunta.dart';
import '../../Modelos/RespuestaLocal.dart';

class ExamenActivoEstado {
  final Examen examen;
  final List<Pregunta> preguntasAleatorizadas;
  final int indicePreguntaActual;
  final Map<String, RespuestaLocal> respuestasLocales;
  final DateTime tiempoInicioExamen;
  final DateTime tiempoInicioPreguntaActual;
  final bool estaEnviando;
  final String? errorEnvio;
  final String idIntento;

  const ExamenActivoEstado({
    required this.examen,
    required this.preguntasAleatorizadas,
    required this.indicePreguntaActual,
    required this.respuestasLocales,
    required this.tiempoInicioExamen,
    required this.tiempoInicioPreguntaActual,
    required this.estaEnviando,
    required this.errorEnvio,
    required this.idIntento,
  });

  /// Retorna la pregunta actualmente visible para el estudiante.
  Pregunta get preguntaActual => preguntasAleatorizadas[indicePreguntaActual];

  /// Crea una copia parcial del estado conservando el resto de campos.
  ExamenActivoEstado copyWith({
    int? indicePreguntaActual,
    Map<String, RespuestaLocal>? respuestasLocales,
    DateTime? tiempoInicioPreguntaActual,
    bool? estaEnviando,
    String? errorEnvio,
    bool limpiarErrorEnvio = false,
  }) {
    return ExamenActivoEstado(
      examen: examen,
      preguntasAleatorizadas: preguntasAleatorizadas,
      indicePreguntaActual: indicePreguntaActual ?? this.indicePreguntaActual,
      respuestasLocales: respuestasLocales ?? this.respuestasLocales,
      tiempoInicioExamen: tiempoInicioExamen,
      tiempoInicioPreguntaActual:
          tiempoInicioPreguntaActual ?? this.tiempoInicioPreguntaActual,
      estaEnviando: estaEnviando ?? this.estaEnviando,
      errorEnvio: limpiarErrorEnvio ? null : (errorEnvio ?? this.errorEnvio),
      idIntento: idIntento,
    );
  }
}
