/// @archivo   ReporteSesionGestion.dart
/// @descripcion Modela reporte agregado de sesion para vistas moviles de gestion.
/// @modulo    Modelos
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'Enums/EstadoIntento.dart';
import 'Enums/EstadoSesion.dart';

class ResumenSesionReporte {
  final String id;
  final String? codigoAcceso;
  final EstadoSesion estado;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const ResumenSesionReporte({
    required this.id,
    required this.codigoAcceso,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory ResumenSesionReporte.fromJson(Map<String, dynamic> json) {
    return ResumenSesionReporte(
      id: json['id'] as String,
      codigoAcceso: json['codigoAcceso'] as String?,
      estado: EstadoSesionTransformador.desdeNombre(
          (json['estado'] as String?) ?? 'PENDIENTE'),
      fechaInicio: _parsearFecha(json['fechaInicio']),
      fechaFin: _parsearFecha(json['fechaFin']),
    );
  }
}

class EstudianteReporteSesion {
  final String nombre;
  final String apellidos;
  final double? puntaje;
  final double? porcentaje;
  final EstadoIntento estado;
  final bool esSospechoso;

  const EstudianteReporteSesion({
    required this.nombre,
    required this.apellidos,
    required this.puntaje,
    required this.porcentaje,
    required this.estado,
    required this.esSospechoso,
  });

  factory EstudianteReporteSesion.fromJson(Map<String, dynamic> json) {
    return EstudianteReporteSesion(
      nombre: (json['nombre'] as String?) ?? '',
      apellidos: (json['apellidos'] as String?) ?? '',
      puntaje: (json['puntaje'] as num?)?.toDouble(),
      porcentaje: (json['porcentaje'] as num?)?.toDouble(),
      estado: EstadoIntentoTransformador.desdeNombre(
          (json['estado'] as String?) ?? 'INICIADO'),
      esSospechoso: (json['esSospechoso'] as bool?) ?? false,
    );
  }
}

class ReporteSesionGestion {
  final ResumenSesionReporte sesion;
  final int totalEstudiantes;
  final int estudiantesQueEnviaron;
  final int estudiantesSospechosos;
  final double? puntajePromedio;
  final double? puntajeMaximo;
  final double? puntajeMinimo;
  final List<EstudianteReporteSesion> listaEstudiantes;

  const ReporteSesionGestion({
    required this.sesion,
    required this.totalEstudiantes,
    required this.estudiantesQueEnviaron,
    required this.estudiantesSospechosos,
    required this.puntajePromedio,
    required this.puntajeMaximo,
    required this.puntajeMinimo,
    required this.listaEstudiantes,
  });

  factory ReporteSesionGestion.fromJson(Map<String, dynamic> json) {
    return ReporteSesionGestion(
      sesion: ResumenSesionReporte.fromJson(
        (json['sesion'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      totalEstudiantes: (json['totalEstudiantes'] as num?)?.toInt() ?? 0,
      estudiantesQueEnviaron:
          (json['estudiantesQueEnviaron'] as num?)?.toInt() ?? 0,
      estudiantesSospechosos:
          (json['estudiantesSospechosos'] as num?)?.toInt() ?? 0,
      puntajePromedio: (json['puntajePromedio'] as num?)?.toDouble(),
      puntajeMaximo: (json['puntajeMaximo'] as num?)?.toDouble(),
      puntajeMinimo: (json['puntajeMinimo'] as num?)?.toDouble(),
      listaEstudiantes: (json['listaEstudiantes'] as List<dynamic>? ??
              <dynamic>[])
          .map((dato) =>
              EstudianteReporteSesion.fromJson(dato as Map<String, dynamic>))
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
