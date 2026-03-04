import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../widgets/animated/staggered_list.dart';
import '../../../widgets/common/eval_avatar.dart';
import '../../../widgets/common/eval_badge.dart';
import '../../../widgets/common/eval_button.dart';
import '../../../widgets/common/eval_card.dart';

class SessionPanelPage extends StatelessWidget {
  const SessionPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: Row(
          children: const [
            Text('Sesión activa'),
            SizedBox(width: AppSpacing.sm),
            EvalBadge('AB3X9F', variant: EvalBadgeVariant.primary),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.base),
            child: EvalButton(
              label: 'Finalizar sesión',
              size: EvalButtonSize.small,
              fullWidth: false,
              variant: EvalButtonVariant.destructive,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primaryDark,
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.sm,
              children: [
                Text('Conectados: 23', style: _stripTextStyle(textTheme)),
                Text('Enviados: 8', style: _stripTextStyle(textTheme)),
                Text('En curso: 15', style: _stripTextStyle(textTheme)),
                Text('Con alerta: 2', style: _stripTextStyle(textTheme)),
                Text('Tiempo restante: 00:38:44',
                    style: _stripTextStyle(textTheme)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.base),
              itemCount: _students.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final student = _students[index];
                return StaggeredListItem(
                  index: index,
                  child: EvalCard(
                    onTap: () => _showStudentDetail(context, student),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            EvalAvatar(
                              name: student.name,
                              size: EvalAvatarSize.sm,
                              isOnline: student.status !=
                                  SessionAttemptStatus.notStarted,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                student.name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            EvalBadge(
                              student.status.label,
                              variant: student.status.badgeVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value: student.progress,
                            backgroundColor: AppColors.slate200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              student.status == SessionAttemptStatus.highRisk
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${(student.progress * 20).round()}/20 preguntas',
                          style: textTheme.bodySmall,
                        ),
                        if (student.riskScore >= 30) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Riesgo: ${student.riskLabel}',
                            style: textTheme.bodySmall?.copyWith(
                              color: student.riskScore >= 70
                                  ? AppColors.error
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  TextStyle? _stripTextStyle(TextTheme textTheme) {
    return textTheme.bodySmall?.copyWith(
      color: AppColors.surface.withValues(alpha: 0.9),
      fontWeight: FontWeight.w600,
    );
  }

  Future<void> _showStudentDetail(
      BuildContext context, StudentSession student) async {
    final textTheme = Theme.of(context).textTheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text('Progreso: ${(student.progress * 100).round()}%',
                    style: textTheme.bodyMedium),
                Text('Índice de riesgo: ${student.riskScore}',
                    style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.base),
                Text('Eventos recientes', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                ...student.events.map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text('• $event', style: textTheme.bodySmall),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
                EvalButton(
                  label: 'Anular intento',
                  variant: EvalButtonVariant.destructive,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum SessionAttemptStatus {
  inProgress('En curso', EvalBadgeVariant.primary),
  submitted('Enviado', EvalBadgeVariant.success),
  notStarted('Esperando', EvalBadgeVariant.neutral),
  highRisk('⚠ Revisar', EvalBadgeVariant.error);

  const SessionAttemptStatus(this.label, this.badgeVariant);
  final String label;
  final EvalBadgeVariant badgeVariant;
}

class StudentSession {
  const StudentSession({
    required this.name,
    required this.progress,
    required this.status,
    required this.riskScore,
    required this.riskLabel,
    required this.events,
  });

  final String name;
  final double progress;
  final SessionAttemptStatus status;
  final int riskScore;
  final String riskLabel;
  final List<String> events;
}

const _students = [
  StudentSession(
    name: 'Ana Torres',
    progress: 0.75,
    status: SessionAttemptStatus.inProgress,
    riskScore: 18,
    riskLabel: 'Bajo',
    events: ['FOCO_RECUPERADO', 'RESPUESTA_GUARDADA'],
  ),
  StudentSession(
    name: 'Luis Méndez',
    progress: 0.40,
    status: SessionAttemptStatus.highRisk,
    riskScore: 72,
    riskLabel: 'Alto',
    events: ['SEGUNDO_PLANO', 'CAMBIO_RED', 'SEGUNDO_PLANO'],
  ),
  StudentSession(
    name: 'Camila Rojas',
    progress: 1.00,
    status: SessionAttemptStatus.submitted,
    riskScore: 22,
    riskLabel: 'Moderado',
    events: ['ENVIADO'],
  ),
  StudentSession(
    name: 'Pedro Castillo',
    progress: 0,
    status: SessionAttemptStatus.notStarted,
    riskScore: 0,
    riskLabel: 'Sin datos',
    events: [],
  ),
];
