/// @archivo   InstitucionesGestionPantalla.dart
/// @descripcion Gestion de instituciones para superadministrador y consulta para otros roles.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoInstitucion.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Modelos/InstitucionGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/InstitucionServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';

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
                controller: nombreControlador,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: dominioControlador,
                decoration:
                    const InputDecoration(labelText: 'Dominio (opcional)'),
              ),
            ],
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
      _mostrarError(MapeadorErroresNegocio.mapear(
        error,
        mensajePorDefecto: Textos.errorGestion,
      ));
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
            controller: razonControlador,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Razon',
              hintText: 'Describe por que se cambia el estado',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(contexto).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
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
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: esSuperadmin
          ? FloatingActionButton.extended(
              onPressed: _mostrarCrearInstitucion,
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            )
          : null,
      body: FutureBuilder<List<InstitucionGestion>>(
        future: _futuroInstituciones,
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

          final instituciones = snapshot.data ?? <InstitucionGestion>[];
          if (instituciones.isEmpty) {
            return const Center(child: Text(Textos.sinDatos));
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: instituciones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (contexto, indice) {
                final institucion = instituciones[indice];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                institucion.nombre,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (esSuperadmin)
                              PopupMenuButton<EstadoInstitucion>(
                                onSelected: (estado) =>
                                    _cambiarEstado(institucion, estado),
                                itemBuilder: (contexto) {
                                  return EstadoInstitucion.values
                                      .where((estado) =>
                                          estado != institucion.estado)
                                      .map(
                                        (estado) =>
                                            PopupMenuItem<EstadoInstitucion>(
                                          value: estado,
                                          child: Text(estado.name),
                                        ),
                                      )
                                      .toList();
                                },
                                icon: const Icon(Icons.more_horiz),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Estado: ${institucion.estado.name}'),
                        Text('Dominio: ${institucion.dominio ?? '-'}'),
                        if (institucion.fechaCreacion != null)
                          Text(
                            'Creada: ${FormateadorFecha.fechaHora(institucion.fechaCreacion!)}',
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
