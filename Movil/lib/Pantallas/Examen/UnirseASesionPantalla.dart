/// @archivo   UnirseASesionPantalla.dart
/// @descripcion Permite buscar una sesion por codigo y unirse segun estado y modalidad.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoSesion.dart';
import '../../Modelos/Enums/ModalidadExamen.dart';
import '../../Providers/ExamenProvider.dart';
import '../../Providers/SesionProvider.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../Inicio/Widgets/TarjetaSesionDisponible.dart';

class UnirseASesionPantalla extends ConsumerStatefulWidget {
  const UnirseASesionPantalla({super.key});

  @override
  ConsumerState<UnirseASesionPantalla> createState() =>
      _UnirseASesionPantallaState();
}

class _UnirseASesionPantallaState extends ConsumerState<UnirseASesionPantalla> {
  final _controladorCodigo = TextEditingController();
  bool _uniendo = false;

  @override
  void dispose() {
    _controladorCodigo.dispose();
    super.dispose();
  }

  Future<void> _buscarSesion() async {
    final codigo = _controladorCodigo.text.trim();
    if (codigo.isEmpty) {
      return;
    }
    await ref.read(sesionActualProvider.notifier).buscarPorCodigo(codigo);
  }

  Future<void> _unirse() async {
    final sesion = ref.read(sesionActualProvider).sesion;
    if (sesion == null) {
      return;
    }

    setState(() => _uniendo = true);
    try {
      await ref.read(examenActivoProvider.notifier).iniciarExamen(sesion);
      if (!mounted) {
        return;
      }

      if (sesion.examen.modalidad == ModalidadExamen.HOJA_RESPUESTAS) {
        context.go(Rutas.hojaRespuestas);
        return;
      }
      context.go(Rutas.examenActivo);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MapeadorErroresNegocio.mapear(
              error,
              mensajePorDefecto: Textos.errorGeneral,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _uniendo = false);
      }
    }
  }

  String? _mensajeEstado(EstadoSesion estado) {
    if (estado == EstadoSesion.PENDIENTE) return Textos.sesionPendiente;
    if (estado == EstadoSesion.FINALIZADA) return Textos.sesionFinalizada;
    if (estado == EstadoSesion.CANCELADA) return Textos.sesionCancelada;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(sesionActualProvider);
    final sesion = estado.sesion;
    final mensaje = sesion == null ? null : _mensajeEstado(sesion.estado);

    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a sesion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controladorCodigo,
              maxLength: 9,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-]')),
                TextInputFormatter.withFunction((anterior, nuevo) {
                  return nuevo.copyWith(text: nuevo.text.toUpperCase());
                }),
              ],
              decoration: const InputDecoration(
                labelText: Textos.codigoSesion,
                hintText: 'MATE-7823',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: estado.cargando ? null : _buscarSesion,
              child: estado.cargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text(Textos.buscarSesion),
            ),
            const SizedBox(height: 14),
            if (estado.error != null)
              Text(estado.error!, style: const TextStyle(color: Colors.red)),
            if (mensaje != null) Text(mensaje),
            if (sesion != null && sesion.estado == EstadoSesion.ACTIVA)
              TarjetaSesionDisponible(
                sesion: sesion,
                alUnirse: _uniendo ? () {} : _unirse,
              ),
          ],
        ),
      ),
    );
  }
}
