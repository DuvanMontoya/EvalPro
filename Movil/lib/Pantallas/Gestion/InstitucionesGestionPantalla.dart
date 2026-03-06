/// @archivo   InstitucionesGestionPantalla.dart
/// @descripcion Gestion de instituciones para superadministrador y consulta para otros roles.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoInstitucion.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Modelos/InstitucionGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/InstitucionServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_empty_state.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

class InstitucionesGestionPantalla extends ConsumerStatefulWidget {
  const InstitucionesGestionPantalla({super.key});

  @override
  ConsumerState<InstitucionesGestionPantalla> createState() =>
      _InstitucionesGestionPantallaState();
}

class _InstitucionesGestionPantallaState
    extends ConsumerState<InstitucionesGestionPantalla> {
  late InstitucionServicio _servicio;
  late Future<List<InstitucionGestion>> _futuroInstituciones;

  @override
  void initState() {
    super.initState();
    _servicio = InstitucionServicio(ref.read(apiServicioProvider));
    _futuroInstituciones = _servicio.listar();
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroInstituciones = _servicio.listar();
    });
    await _futuroInstituciones;
  }

  Future<void> _mostrarCrearInstitucion() async {
    final nombreControlador = TextEditingController();
    final dominioControlador = TextEditingController();
    final respuesta = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return AlertDialog(
          title: const Text('Crear institucion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                key: const Key('institutions_create_name_field'),
                controller: nombreControlador,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: Dimensiones.espaciadoMd),
              TextField(
                key: const Key('institutions_create_domain_field'),
                controller: dominioControlador,
                decoration:
                    const InputDecoration(labelText: 'Dominio (opcional)'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('institutions_create_cancel_button'),
              onPressed: () => Navigator.of(contexto).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              key: const Key('institutions_create_submit_button'),
              onPressed: () => Navigator.of(contexto).pop(true),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (respuesta != true) {
      return;
    }

    if (nombreControlador.text.trim().isEmpty) {
      _mostrarError(Textos.errorFormularioInvalido);
      return;
    }

    try {
      await _servicio.crear(
        nombre: nombreControlador.text,
        dominio: dominioControlador.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Institucion creada correctamente.')),
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

  Future<void> _cambiarEstado(
    InstitucionGestion institucion,
    EstadoInstitucion nuevoEstado,
  ) async {
    final razonControlador = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return AlertDialog(
          title: const Text('Cambiar estado'),
          content: TextField(
            key: const Key('institution_state_reason_field'),
            controller: razonControlador,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Razon',
              hintText: 'Describe por que se cambia el estado',
            ),
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('institution_state_cancel_button'),
              onPressed: () => Navigator.of(contexto).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              key: const Key('institution_state_save_button'),
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

    if (razonControlador.text.trim().isEmpty) {
      _mostrarError(Textos.errorFormularioInvalido);
      return;
    }

    try {
      await _servicio.cambiarEstado(
        idInstitucion: institucion.id,
        estado: nuevoEstado,
        razon: razonControlador.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado de institucion actualizado.')),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rol = ref.watch(autenticacionEstadoProvider).usuario?.rol;
    final esSuperadmin = rol == RolUsuario.SUPERADMINISTRADOR;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.gestionarInstituciones),
        actions: <Widget>[
          IconButton(
            key: const Key('institutions_refresh_button'),
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: esSuperadmin
          ? FloatingActionButton.extended(
              key: const Key('institutions_create_fab'),
              onPressed: _mostrarCrearInstitucion,
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            )
          : null,
      body: EvalPageBackground(
        child: FutureBuilder<List<InstitucionGestion>>(
          future: _futuroInstituciones,
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

            final instituciones = snapshot.data ?? <InstitucionGestion>[];
            if (instituciones.isEmpty) {
              return EvalEmptyState(
                icon: Icons.apartment_rounded,
                title: 'No hay instituciones registradas',
                subtitle:
                    'Crea una nueva institucion o vuelve a sincronizar para ver la operacion disponible.',
                actionLabel: 'Actualizar',
                onAction: _recargar,
              );
            }

            final activas = instituciones
                .where((institucion) =>
                    institucion.estado == EstadoInstitucion.ACTIVA)
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
                    eyebrow: 'Multitenancy',
                    title: 'Instituciones',
                    subtitle:
                        'Consulta el estado de cada tenant y aplica cambios administrativos con trazabilidad.',
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
                              value: instituciones.length.toString(),
                            ),
                            EvalMetricTile(
                              label: 'Activas',
                              value: activas.toString(),
                              highlightColor: Colors.green,
                            ),
                            EvalMetricTile(
                              label: 'No activas',
                              value:
                                  (instituciones.length - activas).toString(),
                              highlightColor: Colors.orange,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  ...instituciones.map((institucion) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensiones.espaciadoLg),
                      child: EvalSectionCard(
                        key: ValueKey<String>(
                          'institution_card_${institucion.id}',
                        ),
                        title: institucion.nombre,
                        subtitle:
                            institucion.dominio ?? 'Sin dominio configurado',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            EvalBadge(
                              institucion.estado.name,
                              variant: _badgeEstado(institucion.estado),
                            ),
                            if (esSuperadmin) ...<Widget>[
                              const SizedBox(width: 8),
                              PopupMenuButton<EstadoInstitucion>(
                                key: ValueKey<String>(
                                  'institution_actions_button_${institucion.id}',
                                ),
                                onSelected: (estado) =>
                                    _cambiarEstado(institucion, estado),
                                itemBuilder: (contexto) {
                                  return EstadoInstitucion.values
                                      .where(
                                        (estado) =>
                                            estado != institucion.estado,
                                      )
                                      .map(
                                        (estado) =>
                                            PopupMenuItem<EstadoInstitucion>(
                                          key: ValueKey<String>(
                                            'institution_change_state_${institucion.id}_${estado.name}',
                                          ),
                                          value: estado,
                                          child: Text(estado.name),
                                        ),
                                      )
                                      .toList();
                                },
                                icon: const Icon(Icons.more_horiz),
                              ),
                            ],
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            if (institucion.fechaCreacion != null)
                              EvalInfoRow(
                                label: 'Creada',
                                value: FormateadorFecha.fechaHora(
                                  institucion.fechaCreacion!,
                                ),
                                icon: Icons.event_available_outlined,
                                compact: true,
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

  EvalBadgeVariant _badgeEstado(EstadoInstitucion estado) {
    return switch (estado) {
      EstadoInstitucion.ACTIVA => EvalBadgeVariant.success,
      EstadoInstitucion.SUSPENDIDA => EvalBadgeVariant.warning,
      EstadoInstitucion.ARCHIVADA => EvalBadgeVariant.error,
    };
  }
}
