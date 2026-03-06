/// @archivo   ReporteSesionPantalla.dart
/// @descripcion Muestra metricas y lista de estudiantes para un reporte de sesion.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/ReporteSesionGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/ReporteServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_empty_state.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

class ReporteSesionPantalla extends ConsumerStatefulWidget {
  const ReporteSesionPantalla({
    super.key,
    required this.idSesion,
  });

  final String idSesion;

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
      body: EvalPageBackground(
        child: FutureBuilder<ReporteSesionGestion>(
          future: _futuroReporte,
          builder: (contexto, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return EvalErrorState(
                message: MapeadorErroresNegocio.mapear(
                  snapshot.error!,
                  mensajePorDefecto: Textos.errorGestion,
                ),
                onRetry: _recargar,
              );
            }

            final reporte = snapshot.data;
            if (reporte == null) {
              return EvalEmptyState(
                icon: Icons.analytics_outlined,
                title: 'No hay datos disponibles',
                subtitle:
                    'El reporte se mostrara cuando exista informacion consolidada de la sesion.',
                actionLabel: 'Actualizar',
                onAction: _recargar,
              );
            }

            return RefreshIndicator(
              onRefresh: _recargar,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Dimensiones.espaciadoLg,
                  Dimensiones.espaciadoSm,
                  Dimensiones.espaciadoLg,
                  Dimensiones.espaciado2xl,
                ),
                children: <Widget>[
                  EvalPageHeader(
                    eyebrow: 'Analitica operativa',
                    title:
                        'Sesion ${reporte.sesion.codigoAcceso ?? reporte.sesion.id}',
                    subtitle:
                        'Consulta desempeno, entregas y alertas de riesgo con una lectura clara por estudiante.',
                  ),
                  const SizedBox(height: Dimensiones.espaciadoXl),
                  EvalSectionCard(
                    key: const Key('session_report_summary_card'),
                    title: 'Resumen de sesion',
                    trailing: EvalBadge(
                      reporte.sesion.estado.name,
                      variant: reporte.sesion.estado.name == 'ACTIVA'
                          ? EvalBadgeVariant.success
                          : EvalBadgeVariant.primary,
                    ),
                    child: Column(
                      children: <Widget>[
                        if (reporte.sesion.fechaInicio != null)
                          EvalInfoRow(
                            label: 'Inicio',
                            value: FormateadorFecha.fechaHora(
                              reporte.sesion.fechaInicio!,
                            ),
                            icon: Icons.event_available_outlined,
                          ),
                        if (reporte.sesion.fechaFin != null)
                          EvalInfoRow(
                            label: 'Fin',
                            value: FormateadorFecha.fechaHora(
                              reporte.sesion.fechaFin!,
                            ),
                            icon: Icons.event_busy_outlined,
                            compact: true,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columnas = constraints.maxWidth > 640 ? 3 : 1;
                      return GridView.count(
                        crossAxisCount: columnas,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: Dimensiones.espaciadoMd,
                        mainAxisSpacing: Dimensiones.espaciadoMd,
                        childAspectRatio: columnas == 1 ? 2.7 : 1.5,
                        children: <Widget>[
                          EvalMetricTile(
                            label: 'Total estudiantes',
                            value: reporte.totalEstudiantes.toString(),
                            key: const Key('session_report_metric_total_students'),
                          ),
                          EvalMetricTile(
                            label: 'Entregados',
                            value: reporte.estudiantesQueEnviaron.toString(),
                            key: const Key('session_report_metric_submitted'),
                            highlightColor: Colors.green,
                          ),
                          EvalMetricTile(
                            label: 'Sospechosos',
                            value: reporte.estudiantesSospechosos.toString(),
                            key: const Key('session_report_metric_suspicious'),
                            highlightColor: Colors.orange,
                          ),
                          EvalMetricTile(
                            label: 'Promedio',
                            value: reporte.puntajePromedio?.toStringAsFixed(2) ?? '-',
                            key: const Key('session_report_metric_average'),
                          ),
                          EvalMetricTile(
                            label: 'Maximo',
                            value: reporte.puntajeMaximo?.toStringAsFixed(2) ?? '-',
                            key: const Key('session_report_metric_maximum'),
                          ),
                          EvalMetricTile(
                            label: 'Minimo',
                            value: reporte.puntajeMinimo?.toStringAsFixed(2) ?? '-',
                            key: const Key('session_report_metric_minimum'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  const EvalPageHeader(
                    title: 'Detalle por estudiante',
                    subtitle:
                        'Cada fila muestra estado del intento, porcentaje obtenido y alertas de riesgo.',
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  if (reporte.listaEstudiantes.isEmpty)
                    const EvalEmptyState(
                      icon: Icons.people_outline_rounded,
                      title: 'Sin estudiantes en el reporte',
                      subtitle:
                          'Todavia no hay informacion individual disponible para esta sesion.',
                    ),
                  ...reporte.listaEstudiantes.map(_tarjetaEstudiante),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tarjetaEstudiante(EstudianteReporteSesion estudiante) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensiones.espaciadoLg),
      child: EvalSectionCard(
        key: ValueKey<String>(
          'session_report_student_${estudiante.nombre}_${estudiante.apellidos}',
        ),
        title: '${estudiante.nombre} ${estudiante.apellidos}',
        trailing: EvalBadge(
          estudiante.estado.name,
          variant: estudiante.esSospechoso
              ? EvalBadgeVariant.warning
              : EvalBadgeVariant.primary,
        ),
        child: Column(
          children: <Widget>[
            EvalInfoRow(
              label: 'Puntaje',
              value: estudiante.puntaje?.toStringAsFixed(2) ?? '-',
              icon: Icons.stars_outlined,
            ),
            EvalInfoRow(
              label: 'Porcentaje',
              value: estudiante.porcentaje?.toStringAsFixed(2) ?? '-',
              icon: Icons.percent_rounded,
              compact: !estudiante.esSospechoso,
            ),
            if (estudiante.esSospechoso)
              const EvalNotice(
                message: 'Marcado para revision por indicadores de riesgo.',
                variant: EvalNoticeVariant.warning,
              ),
          ],
        ),
      ),
    );
  }
}
