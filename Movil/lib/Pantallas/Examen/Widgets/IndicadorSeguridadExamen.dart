/// @archivo   IndicadorSeguridadExamen.dart
/// @descripcion Muestra estado de seguridad en tiempo real y diagnostico interno.
/// @modulo    Pantallas/Examen/Widgets
/// @autor     EvalPro
/// @fecha     2026-03-05

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../Constantes/Colores.dart';
import '../../../Providers/SeguridadExamenProvider.dart';

class IndicadorSeguridadExamen extends ConsumerWidget {
  const IndicadorSeguridadExamen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(seguridadExamenProvider);
    final estilo = _resolverEstilo(estado);
    final etiqueta = estado.cargando && !estado.monitoreando
        ? 'Verificando seguridad'
        : estado.etiquetaCorta;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _abrirDiagnostico(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: estilo.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(estilo.icono, color: estilo.color, size: 18),
            const SizedBox(width: 6),
            Text(
              etiqueta,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.medical_information_outlined,
              size: 14,
              color: estilo.color,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirDiagnostico(BuildContext context, WidgetRef ref) async {
    await ref.read(seguridadExamenProvider.notifier).refrescar();
    if (!context.mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _HojaDiagnosticoSeguridad(),
    );
  }

  _EstiloSeguridad _resolverEstilo(EstadoSeguridadExamen estado) {
    switch (estado.nivel) {
      case NivelSeguridadExamen.estricto:
        return const _EstiloSeguridad(
          color: Colores.verdeExito,
          icono: Icons.verified_user_rounded,
        );
      case NivelSeguridadExamen.parcial:
        return const _EstiloSeguridad(
          color: Colores.amarilloAlerta,
          icono: Icons.shield_outlined,
        );
      case NivelSeguridadExamen.critico:
        return const _EstiloSeguridad(
          color: Colores.rojoError,
          icono: Icons.gpp_bad_rounded,
        );
    }
  }
}

class PanelEstadoSeguridadExamen extends ConsumerWidget {
  const PanelEstadoSeguridadExamen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(seguridadExamenProvider);
    final estilo = _resolverEstilo(estado);
    final subtitulo = estado.error ??
        'Modo ${estado.estadoKiosco.modo} · Integridad ${estado.puntajeIntegridad}/100';
    final actualizado = estado.actualizadoEn == null
        ? 'sin lectura reciente'
        : _formatearHora(estado.actualizadoEn!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colores.blanco,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colores.grisBorde),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: estilo.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(estilo.icono, size: 18, color: estilo.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  estado.etiquetaCorta,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colores.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colores.textoSecundario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Actualizado: $actualizado',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colores.textoTerciario,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.support_agent_outlined,
              size: 20,
              color: Colores.azulPrimario,
            ),
            tooltip: 'Diagnostico para soporte',
            onPressed: () async {
              await ref.read(seguridadExamenProvider.notifier).refrescar();
              if (!context.mounted) {
                return;
              }
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const _HojaDiagnosticoSeguridad(),
              );
            },
          ),
        ],
      ),
    );
  }

  _EstiloSeguridad _resolverEstilo(EstadoSeguridadExamen estado) {
    switch (estado.nivel) {
      case NivelSeguridadExamen.estricto:
        return const _EstiloSeguridad(
          color: Colores.verdeExito,
          icono: Icons.verified_user_rounded,
        );
      case NivelSeguridadExamen.parcial:
        return const _EstiloSeguridad(
          color: Colores.amarilloAlerta,
          icono: Icons.shield_outlined,
        );
      case NivelSeguridadExamen.critico:
        return const _EstiloSeguridad(
          color: Colores.rojoError,
          icono: Icons.gpp_bad_rounded,
        );
    }
  }

  String _formatearHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    final segundo = fecha.second.toString().padLeft(2, '0');
    return '$hora:$minuto:$segundo';
  }
}

class _HojaDiagnosticoSeguridad extends ConsumerWidget {
  const _HojaDiagnosticoSeguridad();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(seguridadExamenProvider);
    final diagnostico = estado.generarDiagnosticoSoporte();
    final razones = estado.reporteIntegridad?.razonesRiesgo ?? const <String>[];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Diagnostico de seguridad',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colores.textoPrincipal,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: () =>
                        ref.read(seguridadExamenProvider.notifier).refrescar(),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  IconButton(
                    tooltip: 'Copiar JSON',
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: jsonEncode(diagnostico)),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Diagnostico copiado. Compartelo con soporte.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.content_copy_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _FilaDiagnostico(
                etiqueta: 'Estado',
                valor: estado.etiquetaCorta,
              ),
              _FilaDiagnostico(
                etiqueta: 'Modo kiosco',
                valor: estado.estadoKiosco.modo,
              ),
              _FilaDiagnostico(
                etiqueta: 'Lock Task activo',
                valor: _siNo(estado.estadoKiosco.lockTaskActivo),
              ),
              _FilaDiagnostico(
                etiqueta: 'Device Owner',
                valor: _siNo(estado.estadoKiosco.dispositivoPropietario),
              ),
              _FilaDiagnostico(
                etiqueta: 'Bloqueo estricto disponible',
                valor: _siNo(estado.estadoKiosco.bloqueoEstrictoDisponible),
              ),
              _FilaDiagnostico(
                etiqueta: 'Bloqueo estricto activo',
                valor: _siNo(estado.estadoKiosco.bloqueoEstrictoActivo),
              ),
              _FilaDiagnostico(
                etiqueta: 'Puntaje de integridad',
                valor: '${estado.puntajeIntegridad}/100',
              ),
              _FilaDiagnostico(
                etiqueta: 'Root detectado',
                valor: _siNo(estado.reporteIntegridad?.rootDetectado ?? false),
              ),
              _FilaDiagnostico(
                etiqueta: 'App depurable',
                valor: _siNo(estado.reporteIntegridad?.appDepurable ?? false),
              ),
              _FilaDiagnostico(
                etiqueta: 'ADB activo',
                valor: _siNo(estado.reporteIntegridad?.adbActivo ?? false),
              ),
              _FilaDiagnostico(
                etiqueta: 'Emulador detectado',
                valor:
                    _siNo(estado.reporteIntegridad?.emuladorDetectado ?? false),
              ),
              if (estado.error != null)
                _FilaDiagnostico(
                  etiqueta: 'Error',
                  valor: estado.error!,
                  colorValor: Colores.rojoError,
                ),
              const SizedBox(height: 12),
              const Text(
                'Razones de riesgo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colores.textoPrincipal,
                ),
              ),
              const SizedBox(height: 6),
              if (razones.isEmpty)
                const Text(
                  'Sin razones de riesgo activas en esta lectura.',
                  style:
                      TextStyle(fontSize: 12, color: Colores.textoSecundario),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: razones
                      .map(
                        (razon) => Chip(
                          label: Text(razon),
                          backgroundColor: Colores.rojoError.withValues(
                            alpha: 0.12,
                          ),
                          labelStyle: const TextStyle(
                            fontSize: 11,
                            color: Colores.rojoError,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _siNo(bool valor) => valor ? 'SI' : 'NO';
}

class _FilaDiagnostico extends StatelessWidget {
  const _FilaDiagnostico({
    required this.etiqueta,
    required this.valor,
    this.colorValor,
  });

  final String etiqueta;
  final String valor;
  final Color? colorValor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 170,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 12,
                color: Colores.textoSecundario,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorValor ?? Colores.textoPrincipal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstiloSeguridad {
  const _EstiloSeguridad({
    required this.color,
    required this.icono,
  });

  final Color color;
  final IconData icono;
}
