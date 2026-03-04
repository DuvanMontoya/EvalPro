import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../widgets/animated/count_up_text.dart';
import '../../../widgets/common/eval_badge.dart';
import '../../../widgets/common/eval_button.dart';
import '../../../widgets/common/eval_card.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    this.percentage = 85,
    this.totalPoints = 100,
    this.correct = 16,
    this.incorrect = 3,
    this.unanswered = 1,
    this.showCorrectAnswers = true,
    super.key,
  });

  final int percentage;
  final int totalPoints;
  final int correct;
  final int incorrect;
  final int unanswered;
  final bool showCorrectAnswers;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  EvalBadgeVariant get _resultVariant {
    if (widget.percentage >= 70) {
      return EvalBadgeVariant.success;
    }
    if (widget.percentage >= 40) {
      return EvalBadgeVariant.warning;
    }
    return EvalBadgeVariant.error;
  }

  String get _resultLabel {
    if (widget.percentage >= 70) {
      return 'Aprobado';
    }
    if (widget.percentage >= 40) {
      return 'Revisar';
    }
    return 'Reprobado';
  }

  List<Color> get _headerGradient {
    if (widget.percentage >= 70) {
      return [AppColors.successSurface, AppColors.surface];
    }
    if (widget.percentage >= 40) {
      return [AppColors.warningSurface, AppColors.surface];
    }
    return [AppColors.errorSurface, AppColors.surface];
  }

  IconData get _resultIcon {
    if (widget.percentage >= 70) {
      return Icons.check_circle_rounded;
    }
    if (widget.percentage >= 40) {
      return Icons.warning_amber_rounded;
    }
    return Icons.cancel_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.base,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _headerGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Icon(_resultIcon,
                      size: 80, color: _badgeColor(_resultVariant)),
                  const SizedBox(height: AppSpacing.base),
                  Text('PUNTAJE TOTAL', style: textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  CountUpText(
                    value: widget.percentage.toDouble(),
                    suffix: '%',
                    style: textTheme.displayMedium?.copyWith(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                    duration: const Duration(milliseconds: 2500),
                  ),
                  Text(
                    'de ${widget.totalPoints} puntos posibles',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: AppColors.slate500),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  EvalBadge(_resultLabel, variant: _resultVariant),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.base),
                children: [
                  EvalCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryMetric(
                          label: 'Correctas',
                          value: '${widget.correct}/20',
                          color: AppColors.success,
                        ),
                        _SummaryMetric(
                          label: 'Incorrectas',
                          value: '${widget.incorrect}/20',
                          color: AppColors.error,
                        ),
                        _SummaryMetric(
                          label: 'Sin responder',
                          value: '${widget.unanswered}/20',
                          color: AppColors.slate600,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  EvalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Examen', style: textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Cálculo Diferencial e Integral',
                            style: textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Docente: Dra. Ramírez',
                            style: textTheme.bodySmall),
                        Text('Grupo: A-2026', style: textTheme.bodySmall),
                        Text('Enviado: 2026-03-03 10:32',
                            style: textTheme.bodySmall),
                        Text('Duración real: 42 min',
                            style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (widget.showCorrectAnswers) ...[
                    const SizedBox(height: AppSpacing.base),
                    EvalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Respuestas', style: textTheme.titleLarge),
                          const SizedBox(height: AppSpacing.base),
                          _AnswerTile(
                            number: 1,
                            question: '¿Derivada de sin(x)?',
                            yourAnswer: 'cos(x)',
                            correctAnswer: 'cos(x)',
                            correct: true,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _AnswerTile(
                            number: 2,
                            question: 'Área triángulo 3-4-5',
                            yourAnswer: '8',
                            correctAnswer: '6',
                            correct: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EvalButton(
                      label: 'Volver al inicio',
                      variant: EvalButtonVariant.outlined,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    EvalButton(
                      label: 'Presentar reclamo',
                      variant: EvalButtonVariant.ghost,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _badgeColor(EvalBadgeVariant variant) {
    return switch (variant) {
      EvalBadgeVariant.success => AppColors.success,
      EvalBadgeVariant.warning => AppColors.warning,
      EvalBadgeVariant.error => AppColors.error,
      EvalBadgeVariant.primary => AppColors.primary,
      EvalBadgeVariant.neutral => AppColors.slate600,
    };
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final parsed = double.tryParse(value.split('/').first) ?? 0;
    return Column(
      children: [
        CountUpText(
          value: parsed,
          suffix: '/20',
          style: textTheme.titleLarge
              ?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: textTheme.bodySmall),
      ],
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.number,
    required this.question,
    required this.yourAnswer,
    required this.correctAnswer,
    required this.correct,
  });

  final int number;
  final String question;
  final String yourAnswer;
  final String correctAnswer;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderColor =
        correct ? AppColors.successBorder : AppColors.errorBorder;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pregunta $number: $question',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              EvalBadge(
                correct ? 'Correcto' : 'Incorrecto',
                variant:
                    correct ? EvalBadgeVariant.success : EvalBadgeVariant.error,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Tu respuesta: $yourAnswer', style: textTheme.bodySmall),
          if (!correct) ...[
            const SizedBox(height: AppSpacing.xs),
            Text('Respuesta correcta: $correctAnswer',
                style: textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
