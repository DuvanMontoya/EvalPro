/// @archivo   SesionesGestionPantalla.dart
/// @descripcion Lista sesiones y acciones de ciclo de vida para docente/administrador.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoSesion.dart';
import '../../Modelos/Enums/RolUsuario.dart';
import '../../Modelos/SesionGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';

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
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<SesionGestion>>(
        future: _futuroSesiones,
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

          final sesiones = snapshot.data ?? <SesionGestion>[];
          if (sesiones.isEmpty) {
            return const Center(child: Text(Textos.sinDatos));
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: sesiones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (contexto, indice) {
                final sesion = sesiones[indice];
                final puedeActivar =
                    esDocente && sesion.estado == EstadoSesion.PENDIENTE;
                final puedeFinalizar =
                    puedeCerrarSesion && sesion.estado == EstadoSesion.ACTIVA;
                final puedeCancelar = puedeCerrarSesion &&
                    (sesion.estado == EstadoSesion.PENDIENTE ||
                        sesion.estado == EstadoSesion.ACTIVA);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          sesion.codigoAcceso ?? 'Sin codigo',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text('Estado: ${sesion.estado.name}'),
                        Text('Examen: ${sesion.examenId}'),
                        if (sesion.fechaInicio != null)
                          Text(
                              'Inicio: ${FormateadorFecha.fechaHora(sesion.fechaInicio!)}'),
                        if (sesion.fechaFin != null)
                          Text(
                              'Fin: ${FormateadorFecha.fechaHora(sesion.fechaFin!)}'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            OutlinedButton.icon(
                              onPressed: () => context.go(
                                Rutas.reporteSesionPorId(sesion.id),
                              ),
                              icon: const Icon(Icons.analytics_outlined),
                              label: const Text(Textos.verReporte),
                            ),
                            if (puedeActivar)
                              ElevatedButton(
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
                              ElevatedButton(
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
              },
            ),
          );
        },
      ),
    );
  }
}
