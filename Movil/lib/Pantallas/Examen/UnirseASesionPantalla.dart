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
      await Future<void>.delayed(Duration.zero);
      if (ref.read(examenActivoProvider) == null) {
        throw StateError('No fue posible preparar el examen.');
      }
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a sesion')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFE4EEFF), Color(0xFFF2F5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ingresa el codigo compartido por tu docente',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Buscamos la sesion en tiempo real y validamos si esta activa.',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
              prefixIcon: Icon(Icons.confirmation_number_outlined),
            ),
            onSubmitted: (_) => _buscarSesion(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: estado.cargando ? null : _buscarSesion,
              icon: estado.cargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search_rounded),
              label:
                  Text(estado.cargando ? 'Buscando...' : Textos.buscarSesion),
            ),
          ),
          const SizedBox(height: 14),
          if (estado.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEECEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                estado.error!,
                style:
                    textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
              ),
            ),
          if (mensaje != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                mensaje,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (sesion != null &&
              sesion.estado == EstadoSesion.ACTIVA) ...<Widget>[
            const SizedBox(height: 14),
            TarjetaSesionDisponible(
              sesion: sesion,
              alUnirse: _uniendo ? () {} : _unirse,
            ),
            if (_uniendo)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ],
      ),
    );
  }
}
