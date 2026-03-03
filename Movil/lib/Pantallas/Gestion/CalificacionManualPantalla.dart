/// @archivo   CalificacionManualPantalla.dart
/// @descripcion Permite calificar manualmente respuestas abiertas pendientes.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Textos.dart';
import '../../Modelos/RespuestaPendienteCalificacion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/CalificacionManualServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';

class CalificacionManualPantalla extends ConsumerStatefulWidget {
  const CalificacionManualPantalla({super.key});

  @override
  ConsumerState<CalificacionManualPantalla> createState() =>
      _CalificacionManualPantallaState();
}

class _CalificacionManualPantallaState
    extends ConsumerState<CalificacionManualPantalla> {
  late CalificacionManualServicio _servicio;
  late Future<List<RespuestaPendienteCalificacion>> _futuroPendientes;

  @override
  void initState() {
    super.initState();
    _servicio = CalificacionManualServicio(ref.read(apiServicioProvider));
    _futuroPendientes = _servicio.listarPendientes();
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroPendientes = _servicio.listarPendientes();
    });
    await _futuroPendientes;
  }

  Future<void> _calificar(RespuestaPendienteCalificacion respuesta) async {
    final puntajeControlador = TextEditingController();
    final observacionControlador = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return AlertDialog(
          title: const Text('Calificar respuesta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Puntaje maximo: ${respuesta.puntajeMaximo.toStringAsFixed(2)}',
                ),
                TextField(
                  controller: puntajeControlador,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration:
                      const InputDecoration(labelText: 'Puntaje obtenido'),
                ),
                TextField(
                  controller: observacionControlador,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Observacion (opcional)'),
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

    final puntaje = double.tryParse(puntajeControlador.text.trim());
    if (puntaje == null) {
      _mostrarError('Debes indicar un puntaje valido.');
      return;
    }
    if (puntaje < 0 || puntaje > respuesta.puntajeMaximo) {
      _mostrarError(
          'El puntaje debe estar entre 0 y ${respuesta.puntajeMaximo}.');
      return;
    }

    try {
      await _servicio.calificar(
        idRespuesta: respuesta.id,
        puntajeObtenido: puntaje,
        observacion: observacionControlador.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Textos.respuestaCalificada)),
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
        title: const Text(Textos.calificacionManual),
        actions: <Widget>[
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<RespuestaPendienteCalificacion>>(
        future: _futuroPendientes,
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

          final pendientes =
              snapshot.data ?? <RespuestaPendienteCalificacion>[];
          if (pendientes.isEmpty) {
            return const Center(child: Text(Textos.sinDatos));
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: pendientes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (contexto, indice) {
                final respuesta = pendientes[indice];
                final contenido = (respuesta.valorTexto ?? '').trim();
                final opciones = respuesta.opcionesSeleccionadas.join(', ');
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          respuesta.tituloExamen ?? 'Examen',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                            'Estudiante: ${respuesta.estudianteNombreCompleto}'),
                        if (respuesta.codigoSesion != null)
                          Text('Sesion: ${respuesta.codigoSesion}'),
                        if (respuesta.guardadoEn != null)
                          Text(
                            'Respondido: ${FormateadorFecha.fechaHora(respuesta.guardadoEn!)}',
                          ),
                        const SizedBox(height: 8),
                        Text('Pregunta: ${respuesta.enunciadoPregunta}'),
                        const SizedBox(height: 6),
                        Text(
                          contenido.isNotEmpty
                              ? 'Respuesta: $contenido'
                              : 'Opciones: $opciones',
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _calificar(respuesta),
                          child: const Text('Calificar'),
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
