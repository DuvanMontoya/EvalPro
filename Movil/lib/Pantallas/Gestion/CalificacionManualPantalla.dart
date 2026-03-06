/// @archivo   CalificacionManualPantalla.dart
/// @descripcion Permite calificar manualmente respuestas abiertas pendientes.
/// @modulo    Pantallas/Gestion
/// @autor     EvalPro
/// @fecha     2026-03-03

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/RespuestaPendienteCalificacion.dart';
import '../../Providers/AutenticacionProvider.dart';
import '../../Servicios/CalificacionManualServicio.dart';
import '../../Utilidades/FormateadorFecha.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../../core/widgets/common/eval_empty_state.dart';
import '../../core/widgets/common/eval_error_state.dart';
import '../../core/widgets/common/eval_surface.dart';

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
                const SizedBox(height: Dimensiones.espaciadoMd),
                TextField(
                  controller: puntajeControlador,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration:
                      const InputDecoration(labelText: 'Puntaje obtenido'),
                ),
                const SizedBox(height: Dimensiones.espaciadoMd),
                TextField(
                  controller: observacionControlador,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observacion (opcional)',
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

    final puntaje = double.tryParse(puntajeControlador.text.trim());
    if (puntaje == null) {
      _mostrarError('Debes indicar un puntaje valido.');
      return;
    }
    if (puntaje < 0 || puntaje > respuesta.puntajeMaximo) {
      _mostrarError('El puntaje debe estar entre 0 y ${respuesta.puntajeMaximo}.');
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
      body: EvalPageBackground(
        child: FutureBuilder<List<RespuestaPendienteCalificacion>>(
          future: _futuroPendientes,
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

            final pendientes =
                snapshot.data ?? <RespuestaPendienteCalificacion>[];
            if (pendientes.isEmpty) {
              return EvalEmptyState(
                icon: Icons.rate_review_outlined,
                title: 'No hay respuestas pendientes',
                subtitle:
                    'Cuando existan preguntas abiertas por calificar apareceran en esta vista.',
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
                    eyebrow: 'Revision humana',
                    title: 'Calificacion manual',
                    subtitle:
                        'Resuelve respuestas abiertas con contexto completo del estudiante y del examen.',
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  ...pendientes.map((respuesta) {
                    final contenido = (respuesta.valorTexto ?? '').trim();
                    final opciones = respuesta.opcionesSeleccionadas.join(', ');
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: Dimensiones.espaciadoLg),
                      child: EvalSectionCard(
                        title: respuesta.tituloExamen ?? 'Examen',
                        subtitle: respuesta.estudianteNombreCompleto,
                        child: Column(
                          children: <Widget>[
                            if (respuesta.codigoSesion != null)
                              EvalInfoRow(
                                label: 'Sesion',
                                value: respuesta.codigoSesion!,
                                icon: Icons.confirmation_number_outlined,
                              ),
                            if (respuesta.guardadoEn != null)
                              EvalInfoRow(
                                label: 'Respondido',
                                value: FormateadorFecha.fechaHora(
                                  respuesta.guardadoEn!,
                                ),
                                icon: Icons.schedule_rounded,
                              ),
                            EvalInfoRow(
                              label: 'Puntaje maximo',
                              value: respuesta.puntajeMaximo.toStringAsFixed(2),
                              icon: Icons.stars_outlined,
                              compact: true,
                            ),
                            const SizedBox(height: Dimensiones.espaciadoSm),
                            EvalNotice(
                              title: 'Pregunta',
                              message: respuesta.enunciadoPregunta,
                            ),
                            const SizedBox(height: Dimensiones.espaciadoSm),
                            EvalNotice(
                              title: contenido.isNotEmpty ? 'Respuesta' : 'Opciones',
                              message: contenido.isNotEmpty ? contenido : opciones,
                              variant: EvalNoticeVariant.success,
                            ),
                            const SizedBox(height: Dimensiones.espaciadoMd),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _calificar(respuesta),
                                child: const Text('Calificar'),
                              ),
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
