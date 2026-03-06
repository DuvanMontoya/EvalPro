/// @archivo   ResultadosEstudiantePantalla.dart
/// @descripcion Muestra historial de intentos del estudiante y permite presentar reclamos.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/ReporteEstudianteGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/ReclamoServicio.dart';
import '../../Servicios/ReporteServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_empty_state.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

class ResultadosEstudiantePantalla extends ConsumerStatefulWidget {
  const ResultadosEstudiantePantalla({super.key});

  @override
  ConsumerState<ResultadosEstudiantePantalla> createState() =>
      _ResultadosEstudiantePantallaState();
}

class _ResultadosEstudiantePantallaState
    extends ConsumerState<ResultadosEstudiantePantalla> {
  late ReporteServicio _reporteServicio;
  late ReclamoServicio _reclamoServicio;
  Future<ReporteEstudianteGestion>? _futuroReporte;

  @override
  void initState() {
    super.initState();
    _reporteServicio = ReporteServicio(ref.read(apiServicioProvider));
    _reclamoServicio = ReclamoServicio(ref.read(apiServicioProvider));
    _futuroReporte = _cargarReporte();
  }

  Future<ReporteEstudianteGestion> _cargarReporte() {
    final idEstudiante =
        ref.read(autenticacionEstadoProvider).usuario?.id ?? '';
    return _reporteServicio.obtenerReporteEstudiante(idEstudiante);
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroReporte = _cargarReporte();
    });
    await _futuroReporte;
  }

  Future<void> _presentarReclamo(IntentoReporteEstudiante intento) async {
    if (intento.idResultado == null || intento.idResultado!.isEmpty) {
      _mostrarError('Este intento no tiene resultado asociado para reclamo.');
      return;
    }

    final motivoControlador = TextEditingController();
    final preguntaControlador = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return AlertDialog(
          title: const Text('Presentar reclamo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: motivoControlador,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    hintText: 'Describe por que solicitas revision',
                  ),
                ),
                const SizedBox(height: Dimensiones.espaciadoMd),
                TextField(
                  controller: preguntaControlador,
                  decoration: const InputDecoration(
                    labelText: 'ID pregunta (opcional)',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(contexto).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(contexto).pop(true),
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) {
      return;
    }

    if (motivoControlador.text.trim().isEmpty) {
      _mostrarError(Textos.errorFormularioInvalido);
      return;
    }

    try {
      await _reclamoServicio.crear(
        idResultado: intento.idResultado!,
        motivo: motivoControlador.text,
        idPregunta: preguntaControlador.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Textos.reclamoCreado)),
      );
      await _recargar();
    } catch (error) {
      _mostrarError(
        MapeadorErroresNegocio.mapear(
          error,
          mensajePorDefecto: Textos.errorGestion,
        ),
      );
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.misResultados),
        actions: <Widget>[
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: EvalPageBackground(
        child: FutureBuilder<ReporteEstudianteGestion>(
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
            if (reporte == null || reporte.intentos.isEmpty) {
              return EvalEmptyState(
                icon: Icons.insights_rounded,
                title: 'Aun no hay resultados',
                subtitle:
                    'Cuando completes examenes y se publiquen los resultados, apareceran aqui.',
                actionLabel: 'Actualizar',
                onAction: _recargar,
              );
            }

            final publicados = reporte.intentos
                .where((intento) => intento.resultadoPublicadoEn != null)
                .length;
            final sospechosos =
                reporte.intentos.where((intento) => intento.esSospechoso).length;

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
                    eyebrow: 'Seguimiento personal',
                    title: reporte.nombreCompleto.isEmpty
                        ? 'Tus resultados'
                        : reporte.nombreCompleto,
                    subtitle:
                        'Consulta el historial de intentos, los estados publicados y presenta reclamos cuando aplique.',
                  ),
                  const SizedBox(height: Dimensiones.espaciadoXl),
                  EvalSectionCard(
                    child: LayoutBuilder(
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
                              label: 'Intentos',
                              value: reporte.intentos.length.toString(),
                              icon: const Icon(
                                Icons.fact_check_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            EvalMetricTile(
                              label: 'Publicados',
                              value: publicados.toString(),
                              highlightColor: AppColors.success,
                              icon: const Icon(
                                Icons.task_alt_rounded,
                                color: AppColors.success,
                              ),
                            ),
                            EvalMetricTile(
                              label: 'En revision',
                              value: sospechosos.toString(),
                              highlightColor: AppColors.warning,
                              icon: const Icon(
                                Icons.shield_outlined,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  ...reporte.intentos.map(_construirTarjetaIntento),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _construirTarjetaIntento(IntentoReporteEstudiante intento) {
    final puntaje = intento.puntajeObtenido?.toStringAsFixed(2) ?? '-';
    final porcentaje = intento.porcentaje?.toStringAsFixed(2) ?? '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensiones.espaciadoLg),
      child: EvalSectionCard(
        title: intento.tituloExamen,
        subtitle: 'Sesion ${intento.codigoAcceso ?? intento.idSesion}',
        trailing: EvalBadge(
          intento.estado.name,
          variant: _badgeIntento(intento),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (intento.estadoResultado != null) ...<Widget>[
              Row(
                children: <Widget>[
                  EvalBadge(
                    intento.estadoResultado!.name,
                    variant: intento.pendienteCalificacionManual == true
                        ? EvalBadgeVariant.warning
                        : EvalBadgeVariant.primary,
                  ),
                  if (intento.esSospechoso) ...<Widget>[
                    const SizedBox(width: Dimensiones.espaciadoSm),
                    const EvalBadge(
                      'Revision',
                      variant: EvalBadgeVariant.warning,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Dimensiones.espaciadoLg),
            ],
            EvalInfoRow(
              label: 'Puntaje',
              value: puntaje,
              icon: Icons.stars_outlined,
              valueColor: AppColors.primary,
            ),
            EvalInfoRow(
              label: 'Porcentaje',
              value: porcentaje == '-' ? '-' : '$porcentaje%',
              icon: Icons.percent_rounded,
              valueColor: AppColors.success,
            ),
            if (intento.resultadoPublicadoEn != null)
              EvalInfoRow(
                label: 'Publicado',
                value: FormateadorFecha.fechaHora(intento.resultadoPublicadoEn!),
                icon: Icons.schedule_rounded,
                compact: true,
              ),
            const SizedBox(height: Dimensiones.espaciadoSm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: intento.idResultado == null
                    ? null
                    : () => _presentarReclamo(intento),
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Presentar reclamo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  EvalBadgeVariant _badgeIntento(IntentoReporteEstudiante intento) {
    if (intento.esSospechoso) {
      return EvalBadgeVariant.warning;
    }
    if ((intento.estadoResultado?.name ?? '').contains('RECTIFICADO')) {
      return EvalBadgeVariant.success;
    }
    return switch (intento.estado.name) {
      'ENVIADO' => EvalBadgeVariant.success,
      'ANULADO' => EvalBadgeVariant.error,
      _ => EvalBadgeVariant.primary,
    };
  }
}
