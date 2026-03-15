/// @archivo   ReporteEstudianteGestion.dart
/// @descripcion Modela reporte historico de intentos para estudiante autenticado.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'Enums/EstadoIntento.dart';
import 'Enums/EstadoResultado.dart';

class IntentoReporteEstudiante {
  final String idIntento;
  final String? idResultado;
  final String idSesion;
  final String? codigoAcceso;
  final String tituloExamen;
  final EstadoIntento estado;
  final EstadoResultado? estadoResultado;
  final bool? pendienteCalificacionManual;
  final DateTime? resultadoPublicadoEn;
  final double? puntajeObtenido;
  final double? porcentaje;
  final bool esSospechoso;

  const IntentoReporteEstudiante({
    required this.idIntento,
    required this.idResultado,
    required this.idSesion,
    required this.codigoAcceso,
    required this.tituloExamen,
    required this.estado,
    required this.estadoResultado,
    required this.pendienteCalificacionManual,
    required this.resultadoPublicadoEn,
    required this.puntajeObtenido,
    required this.porcentaje,
    required this.esSospechoso,
  });

  factory IntentoReporteEstudiante.fromJson(Map<String, dynamic> json) {
    final estadoResultadoTexto = json['estadoResultado'] as String?;
    return IntentoReporteEstudiante(
      idIntento: (json['idIntento'] as String?) ?? '',
      idResultado: json['idResultado'] as String?,
      idSesion: (json['idSesion'] as String?) ?? '',
      codigoAcceso: json['codigoAcceso'] as String?,
      tituloExamen: (json['tituloExamen'] as String?) ?? '',
      estado: EstadoIntentoTransformador.desdeNombre(
          (json['estado'] as String?) ?? 'INICIADO'),
      estadoResultado: estadoResultadoTexto == null
          ? null
          : EstadoResultadoTransformador.desdeNombre(estadoResultadoTexto),
      pendienteCalificacionManual: json['pendienteCalificacionManual'] as bool?,
      resultadoPublicadoEn: _parsearFecha(json['resultadoPublicadoEn']),
      puntajeObtenido: (json['puntajeObtenido'] as num?)?.toDouble(),
      porcentaje: (json['porcentaje'] as num?)?.toDouble(),
      esSospechoso: (json['esSospechoso'] as bool?) ?? false,
    );
  }
}

class ReporteEstudianteGestion {
  final String idEstudiante;
  final String nombreCompleto;
  final List<IntentoReporteEstudiante> intentos;

  const ReporteEstudianteGestion({
    required this.idEstudiante,
    required this.nombreCompleto,
    required this.intentos,
  });

  factory ReporteEstudianteGestion.fromJson(Map<String, dynamic> json) {
    return ReporteEstudianteGestion(
      idEstudiante: (json['idEstudiante'] as String?) ?? '',
      nombreCompleto: (json['nombreCompleto'] as String?) ?? '',
      intentos: (json['intentos'] as List<dynamic>? ?? <dynamic>[])
          .map((dato) =>
              IntentoReporteEstudiante.fromJson(dato as Map<String, dynamic>))
          .toList(),
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
