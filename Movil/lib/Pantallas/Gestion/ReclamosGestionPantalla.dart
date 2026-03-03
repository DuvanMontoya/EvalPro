/// @archivo   ReclamosGestionPantalla.dart
/// @descripcion Gestiona reclamos de calificacion para roles docentes y administrativos.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoReclamo.dart';
import '../../Modelos/ReclamoGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/ReclamoServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';

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
                  controller: resolucionControlador,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Resolucion',
                  ),
                ),
                if (aprobar)
                  TextField(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(Textos.gestionarReclamos),
        actions: <Widget>[
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<ReclamoGestion>>(
        future: _futuroReclamos,
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

          final reclamos = snapshot.data ?? <ReclamoGestion>[];
          if (reclamos.isEmpty) {
            return const Center(child: Text(Textos.sinDatos));
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: reclamos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (contexto, indice) {
                final reclamo = reclamos[indice];
                final resoluble = reclamo.estado == EstadoReclamo.PRESENTADO ||
                    reclamo.estado == EstadoReclamo.EN_REVISION;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          reclamo.tituloExamen ?? 'Examen sin titulo',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Estudiante: ${reclamo.estudiante?.nombre ?? ''} ${reclamo.estudiante?.apellidos ?? ''}',
                        ),
                        Text('Estado: ${reclamo.estado.name}'),
                        if (reclamo.presentadoEn != null)
                          Text(
                            'Presentado: ${FormateadorFecha.fechaHora(reclamo.presentadoEn!)}',
                          ),
                        if (reclamo.codigoSesion != null)
                          Text('Sesion: ${reclamo.codigoSesion}'),
                        const SizedBox(height: 6),
                        Text('Motivo: ${reclamo.motivo}'),
                        if (reclamo.resolucion != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('Resolucion: ${reclamo.resolucion}'),
                          ),
                        if (reclamo.puntajeAnterior != null ||
                            reclamo.puntajeNuevo != null)
                          Text(
                            'Puntaje: ${reclamo.puntajeAnterior?.toStringAsFixed(2) ?? '-'} -> ${reclamo.puntajeNuevo?.toStringAsFixed(2) ?? '-'}',
                          ),
                        if (resoluble) ...<Widget>[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () =>
                                    _resolverReclamo(reclamo, true),
                                child: const Text('Aprobar'),
                              ),
                              OutlinedButton(
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
              },
            ),
          );
        },
      ),
    );
  }
}
