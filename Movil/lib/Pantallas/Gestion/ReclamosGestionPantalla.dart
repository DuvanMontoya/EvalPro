/// @archivo   ReclamosGestionPantalla.dart
/// @descripcion Gestiona reclamos de calificacion para roles docentes y administrativos.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoReclamo.dart';
import '../../Modelos/ReclamoGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/ReclamoServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_empty_state.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

class ReclamosGestionPantalla extends ConsumerStatefulWidget {
  const ReclamosGestionPantalla({super.key});

  @override
  ConsumerState<ReclamosGestionPantalla> createState() =>
      _ReclamosGestionPantallaState();
}

class _ReclamosGestionPantallaState
    extends ConsumerState<ReclamosGestionPantalla> {
  late ReclamoServicio _servicio;
  late Future<List<ReclamoGestion>> _futuroReclamos;

  @override
  void initState() {
    super.initState();
    _servicio = ReclamoServicio(ref.read(apiServicioProvider));
    _futuroReclamos = _servicio.listar();
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroReclamos = _servicio.listar();
    });
    await _futuroReclamos;
  }

  Future<void> _resolverReclamo(ReclamoGestion reclamo, bool aprobar) async {
    final resolucionControlador = TextEditingController();
    final puntajeControlador = TextEditingController(
      text: reclamo.puntajeNuevo?.toStringAsFixed(2) ??
          reclamo.puntajeAnterior?.toStringAsFixed(2) ??
          '',
    );

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return AlertDialog(
          title: Text(aprobar ? 'Aprobar reclamo' : 'Rechazar reclamo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  key: const Key('claims_resolution_field'),
                  controller: resolucionControlador,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Resolucion'),
                ),
                if (aprobar) ...<Widget>[
                  const SizedBox(height: Dimensiones.espaciadoMd),
                  TextField(
                    key: const Key('claims_score_field'),
                    controller: puntajeControlador,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nuevo puntaje total',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('claims_resolution_cancel_button'),
              onPressed: () => Navigator.of(contexto).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              key: const Key('claims_resolution_submit_button'),
              onPressed: () => Navigator.of(contexto).pop(true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) {
      return;
    }

    final resolucion = resolucionControlador.text.trim();
    if (resolucion.isEmpty) {
      _mostrarError(Textos.errorFormularioInvalido);
      return;
    }

    double? puntajeNuevo;
    if (aprobar) {
      puntajeNuevo = double.tryParse(puntajeControlador.text.trim());
      if (puntajeNuevo == null) {
        _mostrarError('Debes indicar un puntaje valido para aprobar.');
        return;
      }
    }

    try {
      await _servicio.resolver(
        idReclamo: reclamo.id,
        aprobar: aprobar,
        resolucion: resolucion,
        puntajeNuevo: puntajeNuevo,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Textos.reclamoResuelto)),
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
        title: const Text(Textos.gestionarReclamos),
        actions: <Widget>[
          IconButton(
            key: const Key('claims_refresh_button'),
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: EvalPageBackground(
        child: FutureBuilder<List<ReclamoGestion>>(
          future: _futuroReclamos,
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

            final reclamos = snapshot.data ?? <ReclamoGestion>[];
            if (reclamos.isEmpty) {
              return EvalEmptyState(
                icon: Icons.support_agent_outlined,
                title: 'No hay reclamos registrados',
                subtitle:
                    'Los reclamos apareceran aqui cuando los estudiantes soliciten revision.',
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
                  const EvalPageHeader(
                    eyebrow: 'Mesa de revision',
                    title: 'Reclamos',
                    subtitle:
                        'Gestiona solicitudes de recalificacion con contexto de estudiante, sesion y trazabilidad de puntaje.',
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  ...reclamos.map((reclamo) {
                    final resoluble =
                        reclamo.estado == EstadoReclamo.PRESENTADO ||
                            reclamo.estado == EstadoReclamo.EN_REVISION;
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensiones.espaciadoLg),
                      child: EvalSectionCard(
                        key: ValueKey<String>('claim_card_${reclamo.id}'),
                        title: reclamo.tituloExamen ?? 'Examen sin titulo',
                        subtitle:
                            '${reclamo.estudiante?.nombre ?? ''} ${reclamo.estudiante?.apellidos ?? ''}'
                                .trim(),
                        trailing: EvalBadge(
                          reclamo.estado.name,
                          variant: _badgeEstado(reclamo.estado),
                        ),
                        child: Column(
                          children: <Widget>[
                            if (reclamo.presentadoEn != null)
                              EvalInfoRow(
                                label: 'Presentado',
                                value: FormateadorFecha.fechaHora(
                                  reclamo.presentadoEn!,
                                ),
                                icon: Icons.schedule_rounded,
                              ),
                            if (reclamo.codigoSesion != null)
                              EvalInfoRow(
                                label: 'Sesion',
                                value: reclamo.codigoSesion!,
                                icon: Icons.confirmation_number_outlined,
                              ),
                            if (reclamo.puntajeAnterior != null ||
                                reclamo.puntajeNuevo != null)
                              EvalInfoRow(
                                label: 'Puntaje',
                                value:
                                    '${reclamo.puntajeAnterior?.toStringAsFixed(2) ?? '-'} -> ${reclamo.puntajeNuevo?.toStringAsFixed(2) ?? '-'}',
                                icon: Icons.stars_outlined,
                                compact: true,
                              ),
                            const SizedBox(height: Dimensiones.espaciadoSm),
                            EvalNotice(
                              title: 'Motivo',
                              message: reclamo.motivo,
                              variant: EvalNoticeVariant.info,
                            ),
                            if ((reclamo.resolucion ?? '')
                                .trim()
                                .isNotEmpty) ...<Widget>[
                              const SizedBox(height: Dimensiones.espaciadoSm),
                              EvalNotice(
                                title: 'Resolucion',
                                message: reclamo.resolucion!,
                                variant: EvalNoticeVariant.success,
                              ),
                            ],
                            if (resoluble) ...<Widget>[
                              const SizedBox(height: Dimensiones.espaciadoMd),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  ElevatedButton(
                                    key: ValueKey<String>(
                                      'claim_approve_button_${reclamo.id}',
                                    ),
                                    onPressed: () =>
                                        _resolverReclamo(reclamo, true),
                                    child: const Text('Aprobar'),
                                  ),
                                  OutlinedButton(
                                    key: ValueKey<String>(
                                      'claim_reject_button_${reclamo.id}',
                                    ),
                                    onPressed: () =>
                                        _resolverReclamo(reclamo, false),
                                    child: const Text('Rechazar'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  EvalBadgeVariant _badgeEstado(EstadoReclamo estado) {
    return switch (estado) {
      EstadoReclamo.PRESENTADO => EvalBadgeVariant.warning,
      EstadoReclamo.EN_REVISION => EvalBadgeVariant.primary,
      EstadoReclamo.RESUELTO => EvalBadgeVariant.success,
      EstadoReclamo.RECHAZADO => EvalBadgeVariant.error,
    };
  }
}
