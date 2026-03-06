/// @archivo   PeriodosGestionPantalla.dart
/// @descripcion Gestiona periodos academicos desde app movil administrativa.
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
import '../../Modelos/PeriodoGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/InstitucionServicio.dart';
import '../../Servicios/PeriodoGestionServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_empty_state.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

class PeriodosGestionPantalla extends ConsumerStatefulWidget {
  const PeriodosGestionPantalla({super.key});

  @override
  ConsumerState<PeriodosGestionPantalla> createState() =>
      _PeriodosGestionPantallaState();
}

class _PeriodosGestionPantallaState
    extends ConsumerState<PeriodosGestionPantalla> {
  late PeriodoGestionServicio _servicio;
  late Future<List<PeriodoGestion>> _futuroPeriodos;

  @override
  void initState() {
    super.initState();
    _servicio = PeriodoGestionServicio(ref.read(apiServicioProvider));
    _futuroPeriodos = _servicio.listar();
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroPeriodos = _servicio.listar();
    });
    await _futuroPeriodos;
  }

  Future<void> _mostrarCrearPeriodo(bool esSuperadmin) async {
    final nombreControlador = TextEditingController();
    List<InstitucionGestion> instituciones = <InstitucionGestion>[];
    InstitucionGestion? institucionSeleccionada;
    if (esSuperadmin) {
      try {
        instituciones =
            await InstitucionServicio(ref.read(apiServicioProvider)).listar();
        instituciones = instituciones
            .where(
              (institucion) => institucion.estado == EstadoInstitucion.ACTIVA,
            )
            .toList();
        institucionSeleccionada =
            instituciones.isNotEmpty ? instituciones.first : null;
      } catch (error) {
        _mostrarError(
          MapeadorErroresNegocio.mapear(
            error,
            mensajePorDefecto: Textos.errorGestion,
          ),
        );
        return;
      }
    }
    DateTime? fechaInicio;
    DateTime? fechaFin;
    bool activo = true;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return StatefulBuilder(
          builder: (contexto, setEstado) {
            return AlertDialog(
              title: const Text('Crear periodo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nombreControlador,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    if (esSuperadmin) ...<Widget>[
                      const SizedBox(height: Dimensiones.espaciadoMd),
                      DropdownButtonFormField<String>(
                        initialValue: institucionSeleccionada?.id,
                        items: instituciones
                            .map(
                              (institucion) => DropdownMenuItem<String>(
                                value: institucion.id,
                                child: Text(institucion.nombre),
                              ),
                            )
                            .toList(),
                        onChanged: (valor) {
                          if (valor == null) {
                            return;
                          }
                          final seleccion = instituciones.firstWhere(
                            (institucion) => institucion.id == valor,
                            orElse: () =>
                                institucionSeleccionada ?? instituciones.first,
                          );
                          setEstado(() {
                            institucionSeleccionada = seleccion;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Institucion destino',
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    ListTile(
                      title: const Text('Fecha inicio'),
                      subtitle: Text(
                        fechaInicio == null
                            ? 'Seleccionar'
                            : FormateadorFecha.fechaHora(fechaInicio!),
                      ),
                      trailing: const Icon(Icons.calendar_month_outlined),
                      onTap: () async {
                        final seleccion = await showDatePicker(
                          context: contexto,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: fechaInicio ?? DateTime.now(),
                        );
                        if (seleccion != null) {
                          setEstado(() {
                            fechaInicio = DateTime(
                              seleccion.year,
                              seleccion.month,
                              seleccion.day,
                              8,
                            );
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Fecha fin'),
                      subtitle: Text(
                        fechaFin == null
                            ? 'Seleccionar'
                            : FormateadorFecha.fechaHora(fechaFin!),
                      ),
                      trailing: const Icon(Icons.calendar_month_outlined),
                      onTap: () async {
                        final seleccion = await showDatePicker(
                          context: contexto,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: fechaFin ?? fechaInicio ?? DateTime.now(),
                        );
                        if (seleccion != null) {
                          setEstado(() {
                            fechaFin = DateTime(
                              seleccion.year,
                              seleccion.month,
                              seleccion.day,
                              18,
                            );
                          });
                        }
                      },
                    ),
                    SwitchListTile(
                      value: activo,
                      title: const Text('Activo al crear'),
                      onChanged: (valor) => setEstado(() {
                        activo = valor;
                      }),
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
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmado != true) {
      return;
    }

    if (nombreControlador.text.trim().isEmpty ||
        fechaInicio == null ||
        fechaFin == null ||
        (esSuperadmin && institucionSeleccionada == null)) {
      _mostrarError(Textos.errorFormularioInvalido);
      return;
    }

    try {
      await _servicio.crear(
        nombre: nombreControlador.text,
        fechaInicio: fechaInicio!,
        fechaFin: fechaFin!,
        activo: activo,
        idInstitucion: esSuperadmin ? institucionSeleccionada?.id : null,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Periodo creado correctamente.')),
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

  Future<void> _actualizarEstado(PeriodoGestion periodo, bool nuevoEstado) async {
    try {
      await _servicio.actualizarEstado(
        idPeriodo: periodo.id,
        activo: nuevoEstado,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado de periodo actualizado.')),
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
    final rol = ref.watch(autenticacionEstadoProvider).usuario?.rol;
    final puedeCrear =
        rol == RolUsuario.ADMINISTRADOR || rol == RolUsuario.SUPERADMINISTRADOR;
    final esSuperadmin = rol == RolUsuario.SUPERADMINISTRADOR;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.gestionarPeriodos),
        actions: <Widget>[
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: puedeCrear
          ? FloatingActionButton.extended(
              onPressed: () => _mostrarCrearPeriodo(esSuperadmin),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      body: EvalPageBackground(
        child: FutureBuilder<List<PeriodoGestion>>(
          future: _futuroPeriodos,
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

            final periodos = snapshot.data ?? <PeriodoGestion>[];
            if (periodos.isEmpty) {
              return EvalEmptyState(
                icon: Icons.calendar_month_rounded,
                title: 'No hay periodos creados',
                subtitle:
                    'Crea un nuevo periodo academico para ordenar la operacion institucional.',
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
                    eyebrow: 'Calendario academico',
                    title: 'Periodos',
                    subtitle:
                        'Activa, consulta y organiza ventanas academicas vigentes para toda la institucion.',
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  ...periodos.map((periodo) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: Dimensiones.espaciadoLg),
                      child: EvalSectionCard(
                        title: periodo.nombre,
                        subtitle: 'Institucion ${periodo.idInstitucion}',
                        trailing: EvalBadge(
                          periodo.activo ? 'Activo' : 'Inactivo',
                          variant: periodo.activo
                              ? EvalBadgeVariant.success
                              : EvalBadgeVariant.neutral,
                        ),
                        child: Column(
                          children: <Widget>[
                            EvalInfoRow(
                              label: 'Inicio',
                              value: FormateadorFecha.fechaHora(periodo.fechaInicio),
                              icon: Icons.event_available_outlined,
                            ),
                            EvalInfoRow(
                              label: 'Fin',
                              value: FormateadorFecha.fechaHora(periodo.fechaFin),
                              icon: Icons.event_busy_outlined,
                              compact: true,
                            ),
                            const SizedBox(height: Dimensiones.espaciadoSm),
                            SwitchListTile(
                              title: const Text('Activo'),
                              value: periodo.activo,
                              onChanged: puedeCrear
                                  ? (valor) => _actualizarEstado(periodo, valor)
                                  : null,
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
}
