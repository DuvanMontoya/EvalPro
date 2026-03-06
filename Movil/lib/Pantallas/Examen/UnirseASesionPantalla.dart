/// @archivo   UnirseASesionPantalla.dart
/// @descripcion Permite buscar una sesion por codigo y unirse segun estado y modalidad.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/Enums/EstadoSesion.dart';
import '../../Modelos/Enums/ModalidadExamen.dart';
import '../../Providers/ExamenProvider.dart';
import '../../Providers/SesionProvider.dart';
import '../../Utilidades/MapeadorErroresNegocio.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_surface.dart';
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

  String _normalizarCodigo(String valor) {
    return valor.trim().toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(sesionActualProvider.notifier).limpiar(),
    );
  }

  @override
  void dispose() {
    _controladorCodigo.dispose();
    super.dispose();
  }

  Future<void> _buscarSesion() async {
    final codigo = _normalizarCodigo(_controladorCodigo.text);
    if (codigo.length < 4) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un codigo valido para buscar.')),
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await ref.read(sesionActualProvider.notifier).buscarPorCodigo(codigo);
  }

  Future<void> _unirse() async {
    var sesion = ref.read(sesionActualProvider).sesion;
    if (sesion == null) {
      return;
    }

    final codigoIngresado = _normalizarCodigo(_controladorCodigo.text);
    final codigoSesion = _normalizarCodigo(sesion.codigoAcceso);
    if (codigoIngresado != codigoSesion) {
      await _buscarSesion();
      sesion = ref.read(sesionActualProvider).sesion;
      if (sesion == null ||
          _normalizarCodigo(sesion.codigoAcceso) != codigoIngresado) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'El codigo cambio. Confirma la sesion nuevamente antes de unirte.',
              ),
            ),
          );
        }
        return;
      }
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

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      HapticFeedback.mediumImpact();
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
      body: EvalPageBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Dimensiones.espaciadoLg,
            Dimensiones.espaciadoSm,
            Dimensiones.espaciadoLg,
            Dimensiones.espaciado2xl,
          ),
          children: <Widget>[
            const EvalPageHeader(
              eyebrow: 'Ingreso inmediato',
              title: 'Únete a tu sesión',
              subtitle:
                  'Escribe el código compartido por tu docente y validamos en tiempo real si la sesión está lista.',
            ),
            const SizedBox(height: Dimensiones.espaciadoXl),
            EvalHeroCard(
              eyebrow: 'Acceso guiado',
              title: 'Un solo código. Todo preparado.',
              subtitle:
                  'Confirmamos estado, modalidad y disponibilidad antes de iniciar el examen.',
              icon: const Icon(
                Icons.confirmation_number_rounded,
                color: Colors.white,
                size: 28,
              ),
              footer: const Wrap(
                spacing: Dimensiones.espaciadoSm,
                runSpacing: Dimensiones.espaciadoSm,
                children: <Widget>[
                  EvalBadge('Validación segura', variant: EvalBadgeVariant.primary),
                  EvalBadge('Estado en vivo', variant: EvalBadgeVariant.success),
                ],
              ),
            ),
            const SizedBox(height: Dimensiones.espaciadoXl),
            EvalSectionCard(
              title: 'Buscar sesión',
              subtitle: 'Introduce el código y continúa cuando la sesión sea válida.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    key: const Key('session_search_code_field'),
                    controller: _controladorCodigo,
                    maxLength: 9,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.search,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-]')),
                      TextInputFormatter.withFunction((anterior, nuevo) {
                        return nuevo.copyWith(text: nuevo.text.toUpperCase());
                      }),
                    ],
                    onChanged: (valor) {
                      final codigoActual = _normalizarCodigo(valor);
                      final sesionActual = ref.read(sesionActualProvider).sesion;
                      if (sesionActual != null &&
                          _normalizarCodigo(sesionActual.codigoAcceso) !=
                              codigoActual) {
                        ref.read(sesionActualProvider.notifier).limpiar();
                      }
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: Textos.codigoSesion,
                      hintText: 'MATE-7823',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                    onSubmitted: (_) => _buscarSesion(),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoSm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      key: const Key('session_search_button'),
                      onPressed: estado.cargando ||
                              _normalizarCodigo(_controladorCodigo.text).length <
                                  4
                          ? null
                          : _buscarSesion,
                      icon: estado.cargando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search_rounded),
                      label: Text(
                        estado.cargando ? 'Buscando...' : Textos.buscarSesion,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (estado.error != null) ...<Widget>[
              const SizedBox(height: Dimensiones.espaciadoLg),
              Container(
                key: const Key('session_search_error_banner'),
                child: EvalNotice(
                  title: 'No pudimos encontrar la sesión',
                  message: estado.error!,
                  variant: EvalNoticeVariant.error,
                ),
              ),
            ],
            if (mensaje != null) ...<Widget>[
              const SizedBox(height: Dimensiones.espaciadoLg),
              EvalNotice(
                title: 'La sesión aún no está disponible',
                message: mensaje,
                variant: EvalNoticeVariant.warning,
              ),
            ],
            if (sesion != null && sesion.estado == EstadoSesion.ACTIVA) ...<Widget>[
              const SizedBox(height: Dimensiones.espaciadoLg),
              TarjetaSesionDisponible(
                sesion: sesion,
                alUnirse: _unirse,
                cargando: _uniendo,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
