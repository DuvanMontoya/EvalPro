/// @archivo   ExamenEnviadoPantalla.dart
/// @descripcion Confirma envio exitoso del examen y muestra puntaje cuando aplica.
/// @modulo    Pantallas/Examen
/// @autor     EvalPro
/// @fecha     2026-03-02

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../Constantes/Dimensiones.dart';
import '../../Constantes/Rutas.dart';
import '../../Constantes/Textos.dart';
import '../../Modelos/ResultadoFinal.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common/eval_badge.dart';
import '../../core/widgets/common/eval_surface.dart';

class ExamenEnviadoPantalla extends StatelessWidget {
  const ExamenEnviadoPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final resultado = extra is ResultadoFinal ? extra : null;

    return Scaffold(
      appBar: AppBar(title: const Text(Textos.examenEnviado)),
      body: EvalPageBackground(
        child: ListView(
          padding: const EdgeInsets.all(Dimensiones.espaciadoLg),
          children: <Widget>[
            const EvalHeroCard(
              eyebrow: 'Entrega completada',
              title: 'Tu examen fue enviado',
              subtitle:
                  'El intento quedo registrado correctamente en la plataforma y ya no admite cambios.',
              icon: Icon(
                Icons.check_circle_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: Dimensiones.espaciadoLg),
            EvalSectionCard(
              title: 'Confirmacion',
              subtitle: 'Resumen del cierre del intento.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const EvalBadge(
                    'Registrado',
                    variant: EvalBadgeVariant.success,
                  ),
                  const SizedBox(height: Dimensiones.espaciadoLg),
                  if (resultado != null && resultado.mostrarPuntaje) ...<Widget>[
                    EvalInfoRow(
                      label: 'Puntaje',
                      value: '${resultado.puntajeObtenido ?? 0}',
                      icon: Icons.stars_outlined,
                      valueColor: AppColors.primary,
                    ),
                    EvalInfoRow(
                      label: 'Porcentaje',
                      value: '${resultado.porcentaje ?? 0}%',
                      icon: Icons.percent_rounded,
                      valueColor: AppColors.success,
                      compact: true,
                    ),
                  ] else
                    const EvalNotice(
                      title: 'Resultado pendiente',
                      message: Textos.examenSinPuntaje,
                      variant: EvalNoticeVariant.info,
                    ),
                  const SizedBox(height: Dimensiones.espaciadoXl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('exam_back_home_button'),
                      onPressed: () => context.go(Rutas.inicio),
                      child: const Text('Volver al inicio'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
