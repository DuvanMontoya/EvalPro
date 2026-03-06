/// @archivo   ExamenesGestionPantalla.dart
/// @descripcion Lista examenes y permite publicar/archivar segun rol.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoExamen.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Modelos/ExamenGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_empty_state.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

class ExamenesGestionPantalla extends ConsumerStatefulWidget {
  const ExamenesGestionPantalla({super.key});

  @override
  ConsumerState<ExamenesGestionPantalla> createState() =>
      _ExamenesGestionPantallaState();
}

class _ExamenesGestionPantallaState
    extends ConsumerState<ExamenesGestionPantalla> {
  late Future<List<ExamenGestion>> _futuroExamenes;

  @override
  void initState() {
    super.initState();
    _futuroExamenes = _cargarExamenes();
  }

  Future<List<ExamenGestion>> _cargarExamenes() {
    return ref.read(examenServicioProvider).listarExamenesGestion();
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroExamenes = _cargarExamenes();
    });
    await _futuroExamenes;
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
    final puedePublicar = rol == RolUsuario.DOCENTE;
    final puedeArchivar = rol == RolUsuario.DOCENTE ||
        rol == RolUsuario.ADMINISTRADOR ||
        rol == RolUsuario.SUPERADMINISTRADOR;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.gestionarExamenes),
        actions: <Widget>[
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: EvalPageBackground(
        child: FutureBuilder<List<ExamenGestion>>(
          future: _futuroExamenes,
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

            final examenes = snapshot.data ?? <ExamenGestion>[];
            if (examenes.isEmpty) {
              return EvalEmptyState(
                icon: Icons.menu_book_rounded,
                title: 'No hay examenes disponibles',
                subtitle:
                    'Publica o sincroniza examenes para visualizarlos desde esta vista de gestion.',
                actionLabel: 'Actualizar',
                onAction: _recargar,
              );
            }

            final publicados = examenes
                .where((examen) => examen.estado == EstadoExamen.PUBLICADO)
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
                    eyebrow: 'Biblioteca academica',
                    title: 'Examenes',
                    subtitle:
                        'Controla el estado de publicacion y mantén cada evaluacion lista para sus sesiones.',
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
                              value: examenes.length.toString(),
                              icon: const Icon(
                                Icons.layers_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            EvalMetricTile(
                              label: 'Publicados',
                              value: publicados.toString(),
                              highlightColor: AppColors.success,
                              icon: const Icon(
                                Icons.public_rounded,
                                color: AppColors.success,
                              ),
                            ),
                            EvalMetricTile(
                              label: 'Borradores',
                              value: (examenes.length - publicados).toString(),
                              highlightColor: AppColors.warning,
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  ...examenes.map((examen) {
                    final habilitaPublicar =
                        puedePublicar && examen.estado == EstadoExamen.BORRADOR;
                    final habilitaArchivar =
                        puedeArchivar && examen.estado != EstadoExamen.ARCHIVADO;

                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: Dimensiones.espaciadoLg),
                      child: EvalSectionCard(
                        title: examen.titulo,
                        subtitle: examen.modalidad.name,
                        trailing: EvalBadge(
                          examen.estado.name,
                          variant: _badgeEstado(examen.estado),
                        ),
                        child: Column(
                          children: <Widget>[
                            EvalInfoRow(
                              label: 'Preguntas',
                              value: examen.totalPreguntas.toString(),
                              icon: Icons.quiz_outlined,
                            ),
                            EvalInfoRow(
                              label: 'Puntaje maximo',
                              value: examen.puntajeMaximo.toStringAsFixed(2),
                              icon: Icons.stars_outlined,
                              valueColor: AppColors.primary,
                              compact: true,
                            ),
                            const SizedBox(height: Dimensiones.espaciadoSm),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                if (habilitaPublicar)
                                  ElevatedButton(
                                    onPressed: () => _ejecutarAccion(
                                      accion: () async {
                                        await ref
                                            .read(examenServicioProvider)
                                            .publicarExamen(examen.id);
                                      },
                                      mensajeExito:
                                          'Examen publicado correctamente.',
                                    ),
                                    child: const Text(Textos.publicarExamen),
                                  ),
                                if (habilitaArchivar)
                                  OutlinedButton(
                                    onPressed: () => _ejecutarAccion(
                                      accion: () async {
                                        await ref
                                            .read(examenServicioProvider)
                                            .archivarExamen(examen.id);
                                      },
                                      mensajeExito:
                                          'Examen archivado correctamente.',
                                    ),
                                    child: const Text(Textos.archivarExamen),
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

  EvalBadgeVariant _badgeEstado(EstadoExamen estado) {
    return switch (estado) {
      EstadoExamen.PUBLICADO => EvalBadgeVariant.success,
      EstadoExamen.BORRADOR => EvalBadgeVariant.warning,
      EstadoExamen.ARCHIVADO => EvalBadgeVariant.error,
    };
  }
}
