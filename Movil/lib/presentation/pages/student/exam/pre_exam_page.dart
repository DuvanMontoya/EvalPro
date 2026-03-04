import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../widgets/common/eval_badge.dart';
import '../../../widgets/common/eval_button.dart';
import '../../../widgets/common/eval_card.dart';
import '../../../widgets/common/eval_text_field.dart';

class PreExamPage extends StatefulWidget {
  const PreExamPage({super.key});

  @override
  State<PreExamPage> createState() => _PreExamPageState();
}

class _PreExamPageState extends State<PreExamPage> {
  final _sessionCodeController = TextEditingController();
  bool _searching = false;
  SessionCodeStatus _status = SessionCodeStatus.idle;

  @override
  void dispose() {
    _sessionCodeController.dispose();
    super.dispose();
  }

  Future<void> _validateCode(String value) async {
    if (value.length < 6) {
      setState(() {
        _status = SessionCodeStatus.idle;
      });
      return;
    }
    setState(() {
      _searching = true;
      _status = SessionCodeStatus.idle;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) {
      return;
    }

    setState(() {
      _searching = false;
      _status = value.toUpperCase() == 'AB3X9F'
          ? SessionCodeStatus.valid
          : SessionCodeStatus.invalid;
    });
  }

  Future<void> _startExam() async {
    if (_status != SessionCodeStatus.valid) {
      return;
    }
    context.push('/student/exam');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isStartDisabled = _status != SessionCodeStatus.valid;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cálculo Diferencial e Integral',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EvalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.topRight,
                          child: EvalBadge(
                            'Pendiente',
                            variant: EvalBadgeVariant.neutral,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Cálculo Diferencial e Integral',
                            style: textTheme.headlineLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Matemáticas · Grupo A',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.slate500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        const Divider(),
                        const SizedBox(height: AppSpacing.base),
                        GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.sm,
                          crossAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 1.9,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            _InfoCell(label: '⏱ Duración', value: '60 minutos'),
                            _InfoCell(
                                label: '📝 Preguntas', value: '20 preguntas'),
                            _InfoCell(label: '🔄 Intentos', value: '1 de 1'),
                            _InfoCell(label: '📅 Cierra', value: 'Hoy 18:00'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  EvalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📋 Instrucciones',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.slate600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Lee atentamente cada pregunta antes de responder. '
                          'No salgas de la aplicación durante el intento.',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  EvalCard(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.warningSurface,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.warningBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚠️ Modo de protección activo',
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '• La app entrará en pantalla completa\n'
                            '• No podrás cambiar de aplicación\n'
                            '• Las capturas de pantalla quedarán bloqueadas\n'
                            '• Salir contará como evento de riesgo',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.slate700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Código de sesión', style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  EvalTextField(
                    controller: _sessionCodeController,
                    labelText: 'Código de sesión',
                    hintText: '------',
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      final normalized = value.toUpperCase();
                      if (normalized != value) {
                        _sessionCodeController.value = TextEditingValue(
                          text: normalized,
                          selection: TextSelection.collapsed(
                            offset: normalized.length,
                          ),
                        );
                      }
                      _validateCode(normalized);
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                  if (_searching) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const LinearProgressIndicator(minHeight: 2),
                  ],
                  if (_status == SessionCodeStatus.valid) ...[
                    const SizedBox(height: AppSpacing.base),
                    _StatusCard(
                      background: AppColors.successSurface,
                      border: AppColors.successBorder,
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.success,
                      title: 'Sesión activa encontrada',
                      subtitle: 'Docente: Dra. Ramírez · Activada hace 12 min',
                    ),
                  ],
                  if (_status == SessionCodeStatus.invalid) ...[
                    const SizedBox(height: AppSpacing.base),
                    const _StatusCard(
                      background: AppColors.errorSurface,
                      border: AppColors.errorBorder,
                      icon: Icons.cancel_rounded,
                      iconColor: AppColors.error,
                      title: 'Código inválido o sesión inactiva',
                      subtitle: 'Verifica el código e intenta nuevamente.',
                    ),
                  ],
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EvalButton(
                        label: 'Comenzar examen →',
                        onPressed: isStartDisabled ? null : _startExam,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Al iniciar, aceptas las condiciones de evaluación de tu institución.',
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.slate400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum SessionCodeStatus { idle, valid, invalid }

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: AppColors.slate400),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.background,
    required this.border,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final Color background;
  final Color border;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
