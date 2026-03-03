/// @archivo   PeriodosGestionPantalla.dart
/// @descripcion Gestiona periodos academicos desde app movil administrativa.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Modelos/PeriodoGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/PeriodoGestionServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';

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
    final institucionControlador = TextEditingController();
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
                    if (esSuperadmin)
                      TextField(
                        controller: institucionControlador,
                        decoration: const InputDecoration(
                          labelText: 'ID institucion',
                        ),
                      ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
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
                      contentPadding: EdgeInsets.zero,
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
                          initialDate:
                              fechaFin ?? fechaInicio ?? DateTime.now(),
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
                      contentPadding: EdgeInsets.zero,
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
        (esSuperadmin && institucionControlador.text.trim().isEmpty)) {
      _mostrarError(Textos.errorFormularioInvalido);
      return;
    }

    try {
      await _servicio.crear(
        nombre: nombreControlador.text,
        fechaInicio: fechaInicio!,
        fechaFin: fechaFin!,
        activo: activo,
        idInstitucion: esSuperadmin ? institucionControlador.text.trim() : null,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Periodo creado correctamente.')),
      );
      await _recargar();
    } catch (error) {
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
    }
  }

  Future<void> _actualizarEstado(
      PeriodoGestion periodo, bool nuevoEstado) async {
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
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
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
      body: FutureBuilder<List<PeriodoGestion>>(
        future: _futuroPeriodos,
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

          final periodos = snapshot.data ?? <PeriodoGestion>[];
          if (periodos.isEmpty) {
            return const Center(child: Text(Textos.sinDatos));
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: periodos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (contexto, indice) {
                final periodo = periodos[indice];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          periodo.nombre,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('ID institucion: ${periodo.idInstitucion}'),
                        Text(
                            'Inicio: ${FormateadorFecha.fechaHora(periodo.fechaInicio)}'),
                        Text(
                            'Fin: ${FormateadorFecha.fechaHora(periodo.fechaFin)}'),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
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
              },
            ),
          );
        },
      ),
    );
  }
}
