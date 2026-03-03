/// @archivo   ResultadosEstudiantePantalla.dart
/// @descripcion Muestra historial de intentos del estudiante y permite presentar reclamos.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Textos.dart';
import '../../Modelos/ReporteEstudianteGestion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/ReclamoServicio.dart';
import '../../Servicios/ReporteServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';

class ResultadosEstudiantePantalla extends ConsumerStatefulWidget {
  const ResultadosEstudiantePantalla({super.key});

  @override
  ConsumerState<ResultadosEstudiantePantalla> createState() =>
      _ResultadosEstudiantePantallaState();
}

class _ResultadosEstudiantePantallaState
    extends ConsumerState<ResultadosEstudiantePantalla> {
  late ReporteServicio _reporteServicio;
  late ReclamoServicio _reclamoServicio;
  Future<ReporteEstudianteGestion>? _futuroReporte;

  @override
  void initState() {
    super.initState();
    _reporteServicio = ReporteServicio(ref.read(apiServicioProvider));
    _reclamoServicio = ReclamoServicio(ref.read(apiServicioProvider));
    _futuroReporte = _cargarReporte();
  }

  Future<ReporteEstudianteGestion> _cargarReporte() {
    final idEstudiante =
        ref.read(autenticacionEstadoProvider).usuario?.id ?? '';
    return _reporteServicio.obtenerReporteEstudiante(idEstudiante);
  }

  Future<void> _recargar() async {
    setState(() {
      _futuroReporte = _cargarReporte();
    });
    await _futuroReporte;
  }

  Future<void> _presentarReclamo(IntentoReporteEstudiante intento) async {
    if (intento.idResultado == null || intento.idResultado!.isEmpty) {
      _mostrarError('Este intento no tiene resultado asociado para reclamo.');
      return;
    }

    final motivoControlador = TextEditingController();
    final preguntaControlador = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) {
        return AlertDialog(
          title: const Text('Presentar reclamo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: motivoControlador,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    hintText: 'Describe por que solicitas revision',
                  ),
                ),
                TextField(
                  controller: preguntaControlador,
                  decoration: const InputDecoration(
                    labelText: 'ID pregunta (opcional)',
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
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) {
      return;
    }

    if (motivoControlador.text.trim().isEmpty) {
      _mostrarError(Textos.errorFormularioInvalido);
      return;
    }

    try {
      await _reclamoServicio.crear(
        idResultado: intento.idResultado!,
        motivo: motivoControlador.text,
        idPregunta: preguntaControlador.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Textos.reclamoCreado)),
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
        title: const Text(Textos.misResultados),
        actions: <Widget>[
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<ReporteEstudianteGestion>(
        future: _futuroReporte,
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

          final reporte = snapshot.data;
          if (reporte == null || reporte.intentos.isEmpty) {
            return const Center(child: Text(Textos.sinDatos));
          }

          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: reporte.intentos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (contexto, indice) {
                final intento = reporte.intentos[indice];
                final puntaje =
                    intento.puntajeObtenido?.toStringAsFixed(2) ?? '-';
                final porcentaje =
                    intento.porcentaje?.toStringAsFixed(2) ?? '-';
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          intento.tituloExamen,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                            'Sesion: ${intento.codigoAcceso ?? intento.idSesion}'),
                        Text('Estado intento: ${intento.estado.name}'),
                        if (intento.estadoResultado != null)
                          Text(
                              'Estado resultado: ${intento.estadoResultado!.name}'),
                        if (intento.resultadoPublicadoEn != null)
                          Text(
                            'Publicado: ${FormateadorFecha.fechaHora(intento.resultadoPublicadoEn!)}',
                          ),
                        Text('Puntaje: $puntaje'),
                        Text('Porcentaje: $porcentaje'),
                        const SizedBox(height: 10),
                        if (intento.idResultado != null)
                          ElevatedButton(
                            onPressed: () => _presentarReclamo(intento),
                            child: const Text('Presentar reclamo'),
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
