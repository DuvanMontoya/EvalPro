/// @archivo   SesionesGestionPantalla.dart
/// @descripcion Lista sesiones y acciones de ciclo de vida para docente/administrador.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoSesion.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Modelos/SesionGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_empty_state.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

class SesionesGestionPantalla extends ConsumerStatefulWidget {
  const SesionesGestionPantalla({super.key});

  @override
  ConsumerState<SesionesGestionPantalla> createState() =>
      _SesionesGestionPantallaState();
}

class _SesionesGestionPantallaState
    extends ConsumerState<SesionesGestionPantalla> {
  late Future<List<SesionGestion>> _futuroSesiones;

  @override
  void initState() {
    super.initState();
    _futuroSesiones = _cargarSesiones();
  }

  Future<List<SesionGestion>> _cargarSesiones() {
    return ref.read(sesionServicioProvider).listarSesionesGestion();
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroSesiones = _cargarSesiones();
    });
    await _futuroSesiones;
  }

  Future<void> _ejecutarAccion({
    required Future<void> Function() accion,
    required String mensajeExito,
  }) async {
    try {
      await accion();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeExito)));
      await _recargar();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MapeadorErroresNegocio.mapear(
              error,
              mensajePorDefecto: Textos.errorGestion,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rol = ref.watch(autenticacionEstadoProvider).usuario?.rol;
    final esDocente = rol == RolUsuario.DOCENTE;
    final puedeCerrarSesion = rol == RolUsuario.DOCENTE ||
        rol == RolUsuario.ADMINISTRADOR ||
        rol == RolUsuario.SUPERADMINISTRADOR;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.gestionarSesiones),
        actions: <Widget>[
          IconButton(
            key: const Key('sessions_refresh_button'),
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: EvalPageBackground(
        child: FutureBuilder<List<SesionGestion>>(
          future: _futuroSesiones,
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

            final sesiones = snapshot.data ?? <SesionGestion>[];
            if (sesiones.isEmpty) {
              return EvalEmptyState(
                icon: Icons.event_busy_outlined,
                title: 'No hay sesiones para mostrar',
                subtitle:
                    'Cuando existan sesiones de evaluacion activas o pendientes, apareceran aqui.',
                actionLabel: 'Actualizar',
                onAction: _recargar,
              );
            }

            final activas = sesiones
                .where((sesion) => sesion.estado == EstadoSesion.ACTIVA)
                .length;
            final pendientes = sesiones
                .where((sesion) => sesion.estado == EstadoSesion.PENDIENTE)
                .length;

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
                    eyebrow: 'Operacion en vivo',
                    title: 'Sesiones',
                    subtitle:
                        'Supervisa el ciclo de vida completo de cada sesion y actua rapido cuando sea necesario.',
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
                              label: 'Total',
                              value: sesiones.length.toString(),
                              icon: const Icon(
                                Icons.layers_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            EvalMetricTile(
                              label: 'Activas',
                              value: activas.toString(),
                              highlightColor: AppColors.success,
                              icon: const Icon(
                                Icons.play_circle_outline_rounded,
                                color: AppColors.success,
                              ),
                            ),
                            EvalMetricTile(
                              label: 'Pendientes',
                              value: pendientes.toString(),
                              highlightColor: AppColors.warning,
                              icon: const Icon(
                                Icons.schedule_rounded,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  ...sesiones.map((sesion) {
                    final puedeActivar =
                        esDocente && sesion.estado == EstadoSesion.PENDIENTE;
                    final puedeFinalizar = puedeCerrarSesion &&
                        sesion.estado == EstadoSesion.ACTIVA;
                    final puedeCancelar = puedeCerrarSesion &&
                        (sesion.estado == EstadoSesion.PENDIENTE ||
                            sesion.estado == EstadoSesion.ACTIVA);

                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensiones.espaciadoLg),
                      child: EvalSectionCard(
                        key: ValueKey<String>('session_card_${sesion.id}'),
                        title: sesion.codigoAcceso ?? 'Sin codigo',
                        subtitle:
                            sesion.descripcion ?? 'Sesion lista para gestion.',
                        trailing: EvalBadge(
                          sesion.estado.name,
                          variant: _badgeEstado(sesion.estado),
                        ),
                        child: Column(
                          children: <Widget>[
                            EvalInfoRow(
                              label: 'Examen',
                              value: sesion.examenId,
                              icon: Icons.menu_book_outlined,
                            ),
                            if (sesion.fechaInicio != null)
                              EvalInfoRow(
                                label: 'Inicio',
                                value: FormateadorFecha.fechaHora(
                                    sesion.fechaInicio!),
                                icon: Icons.schedule_rounded,
                              ),
                            if (sesion.fechaFin != null)
                              EvalInfoRow(
                                label: 'Fin',
                                value: FormateadorFecha.fechaHora(
                                    sesion.fechaFin!),
                                icon: Icons.event_available_outlined,
                                compact: true,
                              ),
                            const SizedBox(height: Dimensiones.espaciadoSm),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                OutlinedButton.icon(
                                  key: ValueKey<String>(
                                    'session_management_report_button_${sesion.id}',
                                  ),
                                  onPressed: () => context
                                      .go(Rutas.reporteSesionPorId(sesion.id)),
                                  icon: const Icon(Icons.analytics_outlined),
                                  label: const Text(Textos.verReporte),
                                ),
                                if (puedeActivar)
                                  ElevatedButton(
                                    key: ValueKey<String>(
                                      'session_management_activate_button_${sesion.id}',
                                    ),
                                    onPressed: () => _ejecutarAccion(
                                      accion: () async {
                                        await ref
                                            .read(sesionServicioProvider)
                                            .activarSesion(sesion.id);
                                      },
                                      mensajeExito:
                                          'Sesion activada correctamente.',
                                    ),
                                    child: const Text(Textos.activarSesion),
                                  ),
                                if (puedeFinalizar)
                                  ElevatedButton(
                                    key: ValueKey<String>(
                                      'session_management_finalize_button_${sesion.id}',
                                    ),
                                    onPressed: () => _ejecutarAccion(
                                      accion: () async {
                                        await ref
                                            .read(sesionServicioProvider)
                                            .finalizarSesion(sesion.id);
                                      },
                                      mensajeExito:
                                          'Sesion finalizada correctamente.',
                                    ),
                                    child: const Text(Textos.finalizarSesion),
                                  ),
                                if (puedeCancelar)
                                  OutlinedButton(
                                    key: ValueKey<String>(
                                      'session_management_cancel_button_${sesion.id}',
                                    ),
                                    onPressed: () => _ejecutarAccion(
                                      accion: () async {
                                        await ref
                                            .read(sesionServicioProvider)
                                            .cancelarSesion(sesion.id);
                                      },
                                      mensajeExito:
                                          'Sesion cancelada correctamente.',
                                    ),
                                    child: const Text(Textos.cancelarSesion),
                                  ),
                              ],
                            ),
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

  EvalBadgeVariant _badgeEstado(EstadoSesion estado) {
    return switch (estado) {
      EstadoSesion.ACTIVA => EvalBadgeVariant.success,
      EstadoSesion.PENDIENTE => EvalBadgeVariant.warning,
      EstadoSesion.CANCELADA => EvalBadgeVariant.error,
      EstadoSesion.FINALIZADA => EvalBadgeVariant.primary,
    };
  }
}
