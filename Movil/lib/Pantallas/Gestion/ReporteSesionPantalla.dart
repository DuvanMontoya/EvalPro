/// @archivo   ReporteSesionPantalla.dart
/// @descripcion Muestra metricas y lista de estudiantes para un reporte de sesion.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Textos.dart';
import '../../Modelos/ReporteSesionGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/ReporteServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';

class ReporteSesionPantalla extends ConsumerStatefulWidget {
  final String idSesion;

  const ReporteSesionPantalla({
    super.key,
    required this.idSesion,
  });

  @override
  ConsumerState<ReporteSesionPantalla> createState() =>
      _ReporteSesionPantallaState();
}

class _ReporteSesionPantallaState extends ConsumerState<ReporteSesionPantalla> {
  late Future<ReporteSesionGestion> _futuroReporte;

  @override
  void initState() {
    super.initState();
    _futuroReporte = _cargarReporte();
  }

  Future<ReporteSesionGestion> _cargarReporte() {
    final servicio = ReporteServicio(ref.read(apiServicioProvider));
    return servicio.obtenerReporteSesion(widget.idSesion);
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroReporte = _cargarReporte();
    });
    await _futuroReporte;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de sesion'),
        actions: <Widget>[
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: FutureBuilder<ReporteSesionGestion>(
        future: _futuroReporte,
        builder: (contexto, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  MapeadorErroresNegocio.mapear(
                    snapshot.error!,
                    mensajePorDefecto: Textos.errorGestion,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final reporte = snapshot.data;
          if (reporte == null) {
            return const Center(child: Text(Textos.sinDatos));
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: <Widget>[
                Card(
                  key: const Key('session_report_summary_card'),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Sesion ${reporte.sesion.codigoAcceso ?? reporte.sesion.id}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text('Estado: ${reporte.sesion.estado.name}'),
                        if (reporte.sesion.fechaInicio != null)
                          Text(
                            'Inicio: ${FormateadorFecha.fechaHora(reporte.sesion.fechaInicio!)}',
                          ),
                        if (reporte.sesion.fechaFin != null)
                          Text(
                            'Fin: ${FormateadorFecha.fechaHora(reporte.sesion.fechaFin!)}',
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _tarjetaMetrica(
                  'Total estudiantes',
                  reporte.totalEstudiantes.toString(),
                  clavePrueba:
                      const Key('session_report_metric_total_students'),
                ),
                _tarjetaMetrica(
                  'Entregados',
                  reporte.estudiantesQueEnviaron.toString(),
                  clavePrueba: const Key('session_report_metric_submitted'),
                ),
                _tarjetaMetrica(
                  'Sospechosos',
                  reporte.estudiantesSospechosos.toString(),
                  clavePrueba: const Key('session_report_metric_suspicious'),
                ),
                _tarjetaMetrica(
                  'Promedio',
                  reporte.puntajePromedio?.toStringAsFixed(2) ?? '-',
                  clavePrueba: const Key('session_report_metric_average'),
                ),
                _tarjetaMetrica(
                  'Maximo',
                  reporte.puntajeMaximo?.toStringAsFixed(2) ?? '-',
                  clavePrueba: const Key('session_report_metric_maximum'),
                ),
                _tarjetaMetrica(
                  'Minimo',
                  reporte.puntajeMinimo?.toStringAsFixed(2) ?? '-',
                  clavePrueba: const Key('session_report_metric_minimum'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Detalle por estudiante',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (reporte.listaEstudiantes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(Textos.sinDatos),
                  ),
                ...reporte.listaEstudiantes.map(_tarjetaEstudiante),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tarjetaMetrica(
    String titulo,
    String valor, {
    Key? clavePrueba,
  }) {
    return Card(
      key: clavePrueba,
      child: ListTile(
        title: Text(titulo),
        trailing: Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _tarjetaEstudiante(EstudianteReporteSesion estudiante) {
    return Card(
      key: ValueKey<String>(
        'session_report_student_${estudiante.nombre}_${estudiante.apellidos}',
      ),
      child: ListTile(
        title: Text('${estudiante.nombre} ${estudiante.apellidos}'),
        subtitle: Text(
            'Estado: ${estudiante.estado.name} | %: ${estudiante.porcentaje?.toStringAsFixed(2) ?? '-'}'),
        trailing: estudiante.esSospechoso
            ? const Icon(Icons.warning_amber_rounded, color: Colors.orange)
            : null,
      ),
    );
  }
}
