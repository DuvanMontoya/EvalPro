/// @archivo   ExamenesGestionPantalla.dart
/// @descripcion Lista examenes y permite publicar/archivar segun rol.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoExamen.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Modelos/ExamenGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';

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
      body: FutureBuilder<List<ExamenGestion>>(
        future: _futuroExamenes,
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

          final examenes = snapshot.data ?? <ExamenGestion>[];
          if (examenes.isEmpty) {
            return const Center(child: Text(Textos.sinDatos));
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: examenes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (contexto, indice) {
                final examen = examenes[indice];
                final habilitaPublicar =
                    puedePublicar && examen.estado == EstadoExamen.BORRADOR;
                final habilitaArchivar =
                    puedeArchivar && examen.estado != EstadoExamen.ARCHIVADO;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          examen.titulo,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text('Estado: ${examen.estado.name}'),
                        Text('Modalidad: ${examen.modalidad.name}'),
                        Text('Preguntas: ${examen.totalPreguntas}'),
                        Text(
                          'Puntaje maximo: ${examen.puntajeMaximo.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
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
                              ElevatedButton(
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
              },
            ),
          );
        },
      ),
    );
  }
}
