/// @archivo   ResumenExamenPantalla.dart
/// @descripcion Presenta resumen de respuestas y confirma envio final del examen.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Rutas.dart';
import '../../Providers/ExamenProvider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_surface.dart';

class ResumenExamenPantalla extends ConsumerWidget {
  const ResumenExamenPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(examenActivoProvider);
    if (estado == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final total = estado.preguntasAleatorizadas.length;
    final respondidas = estado.respuestasLocales.length;
    final pendientes = total - respondidas;

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del examen')),
      body: EvalPageBackground(
        child: ListView(
          padding: const EdgeInsets.all(Dimensiones.espaciadoLg),
          children: <Widget>[
            EvalHeroCard(
              eyebrow: 'Revision final',
              title: estado.examen.titulo,
              subtitle:
                  'Verifica tu progreso antes de enviar. Despues del envio no podras modificar respuestas.',
              icon: const Icon(
                Icons.fact_check_rounded,
                color: Colors.white,
                size: 28,
              ),
              footer: Row(
                children: <Widget>[
                  EvalBadge(
                    '$respondidas respondidas',
                    variant: EvalBadgeVariant.success,
                  ),
                  const SizedBox(width: Dimensiones.espaciadoSm),
                  EvalBadge(
                    '$pendientes pendientes',
                    variant: pendientes > 0
                        ? EvalBadgeVariant.warning
                        : EvalBadgeVariant.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensiones.espaciadoLg),
            EvalSectionCard(
              title: 'Estado del intento',
              subtitle: 'Un ultimo vistazo antes del envio final.',
              child: Column(
                children: <Widget>[
                  EvalInfoRow(
                    label: 'Total de preguntas',
                    value: '$total',
                    icon: Icons.layers_outlined,
                  ),
                  EvalInfoRow(
                    label: 'Respondidas',
                    value: '$respondidas',
                    icon: Icons.check_circle_outline_rounded,
                    valueColor: AppColors.success,
                  ),
                  EvalInfoRow(
                    label: 'Pendientes',
                    value: '$pendientes',
                    icon: Icons.pending_actions_outlined,
                    valueColor: pendientes > 0
                        ? AppColors.warning
                        : AppColors.primary,
                    compact: true,
                  ),
                ],
              ),
            ),
            if (estado.errorEnvio != null) ...<Widget>[
              const SizedBox(height: Dimensiones.espaciadoLg),
              EvalNotice(
                title: 'No fue posible enviar el examen',
                message: estado.errorEnvio!,
                variant: EvalNoticeVariant.error,
              ),
            ],
            if (pendientes > 0) ...<Widget>[
              const SizedBox(height: Dimensiones.espaciadoLg),
              EvalNotice(
                title: 'Todavia hay preguntas pendientes',
                message:
                    'Puedes volver a revisar tu examen o enviarlo de todos modos.',
                variant: EvalNoticeVariant.warning,
              ),
            ],
            const SizedBox(height: Dimensiones.espaciadoXl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('exam_submit_button'),
                onPressed: estado.estaEnviando
                    ? null
                    : () async {
                        if (pendientes > 0) {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (contextoDialogo) {
                              return AlertDialog(
                                title: const Text(
                                  'Aun tienes preguntas pendientes',
                                ),
                                content: Text(
                                  'Tienes $pendientes pregunta(s) sin responder. '
                                  'Si envias ahora, no podras modificarlas despues.',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(contextoDialogo).pop(false),
                                    child: const Text('Revisar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(contextoDialogo).pop(true),
                                    child: const Text('Enviar de todos modos'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmar != true) {
                            return;
                          }
                        }

                        final resultado = await ref
                            .read(examenActivoProvider.notifier)
                            .finalizarYEnviar();
                        final estadoPosterior = ref.read(examenActivoProvider);
                        if (context.mounted) {
                          if (estadoPosterior != null) {
                            final mensaje = estadoPosterior.errorEnvio ??
                                'No fue posible enviar el examen. Revisa la conexion e intenta nuevamente.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(mensaje)),
                            );
                            return;
                          }
                          HapticFeedback.mediumImpact();
                          context.go(Rutas.examenEnviado, extra: resultado);
                        }
                      },
                icon: estado.estaEnviando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  estado.estaEnviando ? 'Enviando examen...' : 'Enviar examen',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
